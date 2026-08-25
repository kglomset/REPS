import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator, Alert, Animated, Easing, Modal, ScrollView, Text,
  TextInput, TouchableOpacity, View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import DraggableFlatList, { RenderItemParams } from 'react-native-draggable-flatlist';
import { workoutsApi } from '@/services/api/workouts';
import { exercisesApi } from '@/services/api/exercises';
import { useWorkoutStore } from '@/store/useWorkoutStore';
import {
  SessionExerciseResponse, ExerciseResponse, TrainingMethod,
  ProgressionSuggestion, ProgressionTrend,
} from '@/types';
import { TrendBadge, TrendSheet, trendStyle } from '@/components/TrendBadge';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';

// ─── Types ────────────────────────────────────────────────────────────────────

interface SetRow {
  weight: string;       // actual entered/locked value; empty = not yet filled
  reps: string;
  completed: boolean;
  loggedId?: number;
  prevWeight: string;   // previous-session value shown as grayed placeholder
  prevReps: string;
}

interface ExState {
  rows: SetRow[];
  method: TrainingMethod;
  restSeconds: number;
  supersetGroupId: string | null;
}

interface WorkoutSummary {
  duration: number;
  totalSets: number;
  totalVolume: number;
  /** Name + how it compared with last time, for the completion overlay. */
  exercises: { name: string; trend?: ProgressionTrend | null }[];
}

// ─── Column flex ratios ───────────────────────────────────────────────────────
// Columns scale to screen width. kg/reps > prev > set/check.
// Total flex = 1 + 1 + 2 + 3 + 3 = 10
const COL = { set: 1, check: 1, prev: 2, kg: 3, reps: 3 };

// Standard set count for an exercise performed as myo-reps: one activation set
// plus five mini-sets. Applied whenever an exercise *becomes* myo-reps (method
// change, swap, or a newly added exercise) — a template that already specifies
// myo-reps keeps its own configured count.
const MYOREPS_DEFAULT_SETS = 6;

// Previous-session values for row `i`. Blank when that set has no history, so
// sets added beyond last session's set count simply show nothing.
function prevAt(ex: SessionExerciseResponse, i: number): Pick<SetRow, 'prevWeight' | 'prevReps'> {
  const prev = ex.previousSets[i];
  return {
    prevWeight: prev?.weightKg?.toString() ?? '',
    prevReps:   prev?.reps?.toString()     ?? '',
  };
}

// Re-derive every row's previous-session hint from its set index. Called after
// anything that changes the row list or the exercise behind it (method change,
// swap, add/remove set) so the placeholders never drift out of sync.
function withPrev(ex: SessionExerciseResponse, rows: SetRow[]): SetRow[] {
  return rows.map((r, i) => ({ ...r, ...prevAt(ex, i) }));
}

// Build the editable row state for one session exercise (fresh rows from the
// target set count, previous-session hints, and any already-logged sets).
// `opts` lets a caller pin the count/method — used when an exercise is swapped
// or added mid-session and there is no template programming to read.
function buildExState(
  ex: SessionExerciseResponse,
  opts?: { setCount?: number; method?: TrainingMethod },
): ExState {
  const method = opts?.method ?? ex.trainingMethod;
  // Never drop an already-logged set when resuming a session.
  const loggedCount = ex.sets.reduce((n, s) => Math.max(n, s.setNumber), 0);
  const count = Math.max(opts?.setCount ?? ex.targetSets ?? 3, loggedCount, 1);
  const rows: SetRow[] = Array.from({ length: count }, (_, i) => ({
    weight:    '',
    reps:      '',
    completed: false,
    ...prevAt(ex, i),
  }));
  ex.sets.forEach((s) => {
    const row = rows[s.setNumber - 1];
    if (row) {
      row.weight    = s.weightKg?.toString() ?? '';
      row.reps      = s.reps.toString();
      row.completed = true;
      row.loggedId  = s.id;
    }
  });
  return {
    rows,
    method,
    restSeconds:     ex.restSeconds ?? 120,
    supersetGroupId: ex.supersetGroupId ?? null,
  };
}

// Grow/shrink a row list to `count` rows. Existing entries are preserved, rows
// that are completed or already filled in are never dropped, and every row —
// old and new — re-reads the previous-session hint for its own set index.
function resizeRows(ex: SessionExerciseResponse, rows: SetRow[], count: number): SetRow[] {
  const filledThrough = rows.reduce(
    (n, r, i) => (r.completed || r.weight || r.reps ? i + 1 : n), 0);
  const target = Math.max(count, filledThrough, 1);
  const next = rows.length > target
    ? rows.slice(0, target)
    : [...rows, ...Array.from({ length: target - rows.length }, () => ({
        weight: '', reps: '', completed: false, prevWeight: '', prevReps: '',
      }))];
  return withPrev(ex, next);
}

// State patch for a training-method change: myo-reps standardises on 6 sets,
// every other method keeps the current count, and all rows are repopulated
// with previous-session data.
function methodChangePatch(
  ex: SessionExerciseResponse, st: ExState, method: TrainingMethod,
): Partial<ExState> {
  const count = method === 'MYOREPS' && st.method !== 'MYOREPS'
    ? MYOREPS_DEFAULT_SETS
    : st.rows.length;
  return { method, rows: resizeRows(ex, st.rows, count) };
}

// ─── Screen ───────────────────────────────────────────────────────────────────

export default function ActiveWorkoutScreen() {
  const { templateId, sessionId, date } = useLocalSearchParams<{ templateId: string; sessionId: string; date: string }>();
  const queryClient = useQueryClient();
  const {
    activeSession, startSession, setActiveSession,
    startRestTimer, stopRestTimer, tickRestTimer,
    restTimerActive, restTimerRemaining, restTimerSeconds,
  } = useWorkoutStore();

  const [isStarting, setIsStarting]         = useState(false);
  const [completing, setCompleting]         = useState(false);
  const [restEnabled, setRestEnabled]       = useState(true);
  const [addExVisible, setAddExVisible]     = useState(false);
  const [summary, setSummary]               = useState<WorkoutSummary | null>(null);
  const [cancelConfirm, setCancelConfirm]   = useState(false);
  const [supersetPickerForId, setSupersetPickerForId] = useState<number | null>(null);
  const [swapForId, setSwapForId]           = useState<number | null>(null);
  const [removeConfirmFor, setRemoveConfirmFor] = useState<SessionExerciseResponse | null>(null);
  const [exStates, setExStates]             = useState<Record<number, ExState>>({});
  const [elapsed, setElapsed]               = useState(0);
  const elapsedRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const [reorderMode, setReorderMode]       = useState(false);
  const [orderedExercises, setOrderedExercises] = useState<SessionExerciseResponse[]>([]);
  // Progression suggestions: dismissed keys + which exercise's sheet is open
  const [dismissedSuggestions, setDismissedSuggestions] = useState<Record<string, boolean>>({});
  const [suggestionFor, setSuggestionFor]   = useState<SessionExerciseResponse | null>(null);
  // Week-to-week trend: which exercise's detail sheet is open
  const [trendFor, setTrendFor]             = useState<{ name: string; trend: ProgressionTrend } | null>(null);

  // ── Session bootstrap ───────────────────────────────────────────────────────

  useEffect(() => {
    if (activeSession) return; // already have a live session in store — use it

    if (sessionId) {
      // Resume an existing in-progress session by ID
      setIsStarting(true);
      workoutsApi.getSession(Number(sessionId))
        .then((s) => setActiveSession(s))
        .finally(() => setIsStarting(false));
    } else if (templateId) {
      // Start a brand-new session from a template.
      // `date` (yyyy-MM-dd) backdates it for retrospective logging.
      setIsStarting(true);
      startSession(Number(templateId), date || undefined).finally(() => setIsStarting(false));
    }
  }, []);

  // Elapsed timer
  useEffect(() => {
    if (!activeSession) return;
    elapsedRef.current = setInterval(() => {
      setElapsed(Math.round(
        (Date.now() - new Date(activeSession.startedAt).getTime()) / 60000
      ));
    }, 30_000);
    return () => { if (elapsedRef.current) clearInterval(elapsedRef.current); };
  }, [activeSession?.id]);

  // Rest timer countdown
  useEffect(() => {
    if (!restTimerActive) return;
    const id = setInterval(() => tickRestTimer(), 1000);
    return () => clearInterval(id);
  }, [restTimerActive]);

  // Keep orderedExercises in sync when session changes
  useEffect(() => {
    if (activeSession) setOrderedExercises([...activeSession.exercises]);
  }, [activeSession?.id]);

  const saveReorder = useCallback(async (newList: SessionExerciseResponse[]) => {
    if (!activeSession) return;
    setOrderedExercises(newList);
    // Also update the active session's exercise order locally so normal view reflects it
    setActiveSession({ ...activeSession, exercises: newList });
    try {
      await workoutsApi.reorderSessionExercises(
        activeSession.id,
        newList.map((e) => e.id)
      );
    } catch (_) { /* non-critical — local order already updated */ }
  }, [activeSession]);

  // Initialise exStates when session loads
  useEffect(() => {
    if (!activeSession) return;
    const init: Record<number, ExState> = {};
    for (const ex of activeSession.exercises) {
      if (init[ex.id]) continue;
      init[ex.id] = buildExState(ex);
    }
    setExStates(init);
  }, [activeSession?.id]);

  // Swap an exercise for a different one (this session only). The session
  // exercise id is stable, so we refresh just that entry's row state.
  //
  // The slot keeps its programming across the swap: same training method and
  // same set count as before (myo-reps slots standardise on 6). Rows are then
  // rebuilt from the *new* exercise's own previous-session data, blank where it
  // has none.
  const handleSwap = useCallback(async (sessionExerciseId: number, newExerciseId: number) => {
    if (!activeSession) return;
    setSwapForId(null);
    const before = exStates[sessionExerciseId];
    try {
      const updated = await workoutsApi.swapSessionExercise(
        activeSession.id, sessionExerciseId, newExerciseId);
      setActiveSession(updated);
      setOrderedExercises([...updated.exercises]);
      const swapped = updated.exercises.find((e) => e.id === sessionExerciseId);
      if (swapped) {
        const method = before?.method ?? swapped.trainingMethod;
        const setCount = method === 'MYOREPS'
          ? MYOREPS_DEFAULT_SETS
          : (before?.rows.length ?? swapped.targetSets ?? 3);
        setExStates((prev) => ({
          ...prev,
          [sessionExerciseId]: {
            ...buildExState(swapped, { setCount, method }),
            restSeconds:     before?.restSeconds ?? swapped.restSeconds ?? 120,
            supersetGroupId: before?.supersetGroupId ?? swapped.supersetGroupId ?? null,
          },
        }));
      }
    } catch (e: any) {
      Alert.alert('Swap failed', e.message);
    }
  }, [activeSession, exStates]);

  // Add an exercise to the live session. A brand-new slot has no template
  // programming, so its set count comes from the exercise's own history
  // (falling back to the default) and every row is prefilled from it.
  const handleAddExercise = useCallback(async (exerciseId: number) => {
    if (!activeSession) return;
    setAddExVisible(false);
    const knownIds = new Set(activeSession.exercises.map((e) => e.id));
    try {
      const updated = await workoutsApi.addSessionExercise(activeSession.id, exerciseId);
      setActiveSession(updated);
      setOrderedExercises([...updated.exercises]);
      const added = updated.exercises.find((e) => !knownIds.has(e.id));
      if (added) {
        const setCount = added.previousSets.length || added.targetSets || 3;
        setExStates((prev) => ({ ...prev, [added.id]: buildExState(added, { setCount }) }));
      }
    } catch (e: any) {
      Alert.alert('Could not add exercise', e.message);
    }
  }, [activeSession]);

  // Remove an exercise from the live session (this session only — the program
  // template keeps it). If it was in a group and only one member is left, that
  // member is ungrouped too.
  const handleRemoveExercise = useCallback(async (sessionExerciseId: number) => {
    if (!activeSession) return;
    setRemoveConfirmFor(null);
    try {
      const updated = await workoutsApi.removeSessionExercise(
        activeSession.id, sessionExerciseId);
      setActiveSession(updated);
      setOrderedExercises([...updated.exercises]);
      setExStates((prev) => {
        const groupId = prev[sessionExerciseId]?.supersetGroupId;
        const next = { ...prev };
        delete next[sessionExerciseId];
        if (groupId) {
          const members = Object.keys(next).filter(
            (id) => next[Number(id)]?.supersetGroupId === groupId
          );
          if (members.length === 1) {
            const otherId = Number(members[0]);
            next[otherId] = { ...next[otherId], supersetGroupId: null };
          }
        }
        return next;
      });
    } catch (e: any) {
      Alert.alert('Could not remove exercise', e.message);
    }
  }, [activeSession]);

  // ── State helpers ───────────────────────────────────────────────────────────

  const updateExState = useCallback((exId: number, patch: Partial<ExState>) => {
    setExStates((prev) => ({ ...prev, [exId]: { ...prev[exId], ...patch } }));
  }, []);

  const handleAssignSuperset = useCallback((initiatorId: number, targetIds: number[]) => {
    const groupId = `group-${Date.now()}`;
    setExStates((prev) => {
      const next = { ...prev };
      [initiatorId, ...targetIds].forEach((id) => {
        if (next[id]) next[id] = { ...next[id], supersetGroupId: groupId };
      });
      return next;
    });
  }, []);

  // When ungrouping, if only 2 exercises remain, ungroup both
  const handleRemoveFromGroup = useCallback((exId: number) => {
    setExStates((prev) => {
      const groupId = prev[exId]?.supersetGroupId;
      const next = { ...prev, [exId]: { ...prev[exId], supersetGroupId: null } };
      if (groupId) {
        const remaining = Object.keys(prev).filter(
          (id) => Number(id) !== exId && prev[Number(id)]?.supersetGroupId === groupId
        );
        // If only 1 member left after removal, ungroup them too
        if (remaining.length === 1) {
          const otherId = Number(remaining[0]);
          next[otherId] = { ...prev[otherId], supersetGroupId: null };
        }
      }
      return next;
    });
  }, []);

  // ── Progression suggestions ─────────────────────────────────────────────────
  // Dismissals are keyed on exercise + type + message, so new data (which
  // changes the message) resurfaces the badge while repeats stay hidden.

  const dismissSuggestion = useCallback((ex: SessionExerciseResponse) => {
    setDismissedSuggestions((prev) => ({ ...prev, [suggestionKey(ex)]: true }));
    setSuggestionFor(null);
  }, []);

  /** One-tap apply: pre-fill the suggested weight on every not-yet-completed row. */
  const applySuggestion = useCallback((ex: SessionExerciseResponse) => {
    const sugg = ex.suggestion;
    const st = exStates[ex.id];
    if (sugg?.suggestedWeightKg != null && st) {
      const w = String(sugg.suggestedWeightKg);
      updateExState(ex.id, {
        rows: st.rows.map((r) => (r.completed ? r : { ...r, weight: w })),
      });
    }
    setSuggestionFor(null);
  }, [exStates, updateExState]);

  // ── Set completion (optimistic) ─────────────────────────────────────────────

  const handleSetComplete = useCallback(async (
    ex: SessionExerciseResponse,
    rowIdx: number,
    weight: string,
    reps: string,
  ) => {
    const st = exStates[ex.id];
    if (!st) return;

    // Toggle off if already complete
    if (st.rows[rowIdx]?.completed) {
      setExStates((prev) => {
        const s = prev[ex.id];
        if (!s) return prev;
        return { ...prev, [ex.id]: { ...s,
          rows: s.rows.map((r, i) => i === rowIdx ? { ...r, completed: false } : r) } };
      });
      return;
    }

    // Optimistically mark complete AND persist the resolved weight/reps so both
    // columns render in the same completed colour (a prefilled field must not
    // revert to its grey placeholder). Uses the fresh `prev`, not the closure's
    // possibly-stale rows.
    setExStates((prev) => {
      const s = prev[ex.id];
      if (!s) return prev;
      return { ...prev, [ex.id]: { ...s,
        rows: s.rows.map((r, i) => i === rowIdx ? { ...r, completed: true, weight, reps } : r) } };
    });

    // Rest timer: myo-reps use a short 10s cluster rest; everything else uses
    // the exercise's configured rest.
    if (restEnabled) {
      const restDur = st.method === 'MYOREPS' ? 15 : (st.restSeconds ?? 120);
      const groupId = st.supersetGroupId;
      if (groupId) {
        const groupExIds = activeSession!.exercises
          .filter((e) => exStates[e.id]?.supersetGroupId === groupId)
          .map((e) => e.id);
        if (ex.id === groupExIds[groupExIds.length - 1]) {
          startRestTimer(restDur);
        }
      } else {
        startRestTimer(restDur);
      }
    }

    // Log to backend in background (don't block UI)
    const parsedReps = parseInt(reps, 10) || 0;
    try {
      const result = await workoutsApi.logSet(activeSession!.id, ex.id, {
        weightKg:    weight ? parseFloat(weight) : undefined,
        reps:        parsedReps,
        setNumber:   rowIdx + 1,   // 1-based; backend upserts if it already exists
        restSeconds: st.restSeconds,
      });
      // Update with real ID from server
      setExStates((prev) => {
        const s = prev[ex.id];
        if (!s) return prev;
        return {
          ...prev,
          [ex.id]: {
            ...s,
            rows: s.rows.map((r, i) =>
              i === rowIdx ? { ...r, loggedId: result.id } : r
            ),
          },
        };
      });
    } catch (_) {
      // Silently ignore — the physical set happened; don't revert the row
    }
  }, [activeSession, exStates, restEnabled]);

  // ── Finish ──────────────────────────────────────────────────────────────────

  const handleFinish = async () => {
    if (!activeSession || completing) return;
    setCompleting(true);
    try {
      // Only count sets that were actually toggled complete
      const totalSets = Object.values(exStates).reduce(
        (acc, s) => acc + s.rows.filter((r) => r.completed).length, 0
      );
      const totalVolume = Object.values(exStates).reduce(
        (acc, s) => acc + s.rows
          .filter((r) => r.completed && r.weight)
          .reduce((a, r) => a + parseFloat(r.weight) * parseInt(r.reps || '0', 10), 0),
        0
      );
      // Only list exercises that had at least one completed set
      const logged = activeSession.exercises
        .filter((e) => exStates[e.id]?.rows.some((r) => r.completed));

      // Mark complete on server (non-blocking — sets were already logged one-by-one).
      // The response carries freshly computed trends: now that this session is
      // complete it is the one being compared against last time.
      let completed = null as Awaited<ReturnType<typeof workoutsApi.completeSession>> | null;
      try { completed = await workoutsApi.completeSession(activeSession.id); } catch {}
      queryClient.invalidateQueries({ queryKey: ['sessions'] });
      queryClient.invalidateQueries({ queryKey: ['activeProgram'] });
      queryClient.invalidateQueries({ queryKey: ['exerciseTrends'] });
      setSummary({
        duration: elapsed,
        totalSets,
        totalVolume: Math.round(totalVolume),
        exercises: logged.map((e) => ({
          name: e.exercise.name,
          trend: completed?.exercises.find((x) => x.id === e.id)?.trend ?? e.trend,
        })),
      });
    } finally {
      setCompleting(false);
    }
  };

  // ── Cancel ──────────────────────────────────────────────────────────────────

  const handleCancel = () => setCancelConfirm(true);

  const handleCancelConfirmed = () => {
    const sessionId = activeSession?.id;
    setActiveSession(null);
    stopRestTimer();
    router.dismiss();
    // Invalidate only after the DELETE completes so the refetch sees the session gone
    if (sessionId) {
      workoutsApi.cancelSession(sessionId)
        .finally(() => queryClient.invalidateQueries({ queryKey: ['sessions'] }));
    }
  };

  const handleSummaryDismiss = () => {
    setActiveSession(null);
    stopRestTimer();
    router.dismiss();
  };

  // ── Loading guard ───────────────────────────────────────────────────────────

  if (isStarting || !activeSession) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center',
        backgroundColor: Colors.surface }}>
        <ActivityIndicator size="large" color={Colors.primary} />
        <Text style={{ marginTop: Spacing.md, color: Colors.textSecondary }}>
          Loading workout…
        </Text>
      </View>
    );
  }

  const grouped = buildGroups(activeSession.exercises, exStates);

  // Suggestions still visible (not dismissed), keyed by session-exercise id
  const visibleSuggestions: Record<number, ProgressionSuggestion> = {};
  for (const ex of activeSession.exercises) {
    if (ex.suggestion && !dismissedSuggestions[suggestionKey(ex)]) {
      visibleSuggestions[ex.id] = ex.suggestion;
    }
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surfaceMuted }}>

      {/* ── Header ─────────────────────────────────────────────────────────── */}
      <View style={{ backgroundColor: Colors.surface, paddingHorizontal: Spacing.lg,
        paddingVertical: Spacing.sm, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <View>
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
              color: Colors.textPrimary }}>{activeSession.templateName ?? 'Workout'}</Text>
            <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
              {elapsed}m elapsed
            </Text>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.sm }}>
            {/* Rest timer toggle */}
            {!reorderMode && (
              <TouchableOpacity
                onPress={() => { setRestEnabled((v) => !v); if (restTimerActive) stopRestTimer(); }}
                style={{ flexDirection: 'row', alignItems: 'center', gap: 4,
                  backgroundColor: restEnabled ? Colors.primaryTint : Colors.surfaceSubtle,
                  borderRadius: Radius.full, paddingHorizontal: 10, paddingVertical: 6 }}>
                <Ionicons name="timer-outline" size={14}
                  color={restEnabled ? Colors.primary : Colors.textMuted} />
                <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.medium,
                  color: restEnabled ? Colors.primary : Colors.textMuted }}>Rest</Text>
              </TouchableOpacity>
            )}
            {/* Reorder toggle */}
            <TouchableOpacity
              onPress={() => setReorderMode((v) => !v)}
              style={{ flexDirection: 'row', alignItems: 'center', gap: 4,
                backgroundColor: reorderMode ? Colors.primary : Colors.surfaceSubtle,
                borderRadius: Radius.full, paddingHorizontal: 10, paddingVertical: 6 }}>
              <Ionicons name="reorder-three-outline" size={14}
                color={reorderMode ? Colors.textInverse : Colors.textMuted} />
            </TouchableOpacity>
            {/* Cancel */}
            {!reorderMode && (
              <TouchableOpacity onPress={handleCancel}
                style={{ paddingHorizontal: 12, paddingVertical: 6,
                  borderRadius: Radius.full, borderWidth: 1, borderColor: Colors.border }}>
                <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>Cancel</Text>
              </TouchableOpacity>
            )}
            {/* Finish */}
            {!reorderMode && (
              <TouchableOpacity onPress={handleFinish} disabled={completing}
                style={{ backgroundColor: Colors.success, borderRadius: Radius.full,
                  paddingHorizontal: 16, paddingVertical: 8, opacity: completing ? 0.7 : 1 }}>
                {completing
                  ? <ActivityIndicator size="small" color={Colors.textInverse} />
                  : <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                      fontSize: FontSize.sm }}>Finish</Text>}
              </TouchableOpacity>
            )}
          </View>
        </View>
        <RestTimerBar />
      </View>

      {/* ── Exercise list ────────────────────────────────────────────────────── */}
      {reorderMode ? (
        /* Reorder mode: lightweight draggable list */
        <View style={{ flex: 1 }}>
          <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted,
            textAlign: 'center', paddingVertical: Spacing.sm }}>
            Hold &amp; drag to reorder · tap ✓ when done
          </Text>
          <DraggableFlatList
            data={orderedExercises}
            keyExtractor={(ex) => String(ex.id)}
            onDragEnd={({ data }) => saveReorder(data)}
            contentContainerStyle={{ padding: Spacing.md, paddingBottom: 60 }}
            renderItem={({ item: ex, drag, isActive }: RenderItemParams<SessionExerciseResponse>) => (
              <View style={{
                flexDirection: 'row', alignItems: 'center',
                backgroundColor: isActive ? Colors.primaryTint : Colors.surface,
                borderRadius: Radius.lg, marginBottom: Spacing.sm,
                padding: Spacing.md, ...Shadow.card,
                borderLeftWidth: 3,
                borderLeftColor: exStates[ex.id]?.rows.every((r) => r.completed)
                  ? Colors.success : Colors.primary,
              }}>
                <TouchableOpacity onLongPress={drag} delayLongPress={100}
                  style={{ marginRight: Spacing.md, padding: 4 }}>
                  <Ionicons name="reorder-three-outline" size={24} color={Colors.textMuted} />
                </TouchableOpacity>
                <View style={{ flex: 1 }}>
                  <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
                    color: Colors.textPrimary }}>{ex.exercise.name}</Text>
                  <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>
                    {exStates[ex.id]?.rows.filter((r) => r.completed).length ?? 0}
                    /{exStates[ex.id]?.rows.length ?? 0} sets done
                  </Text>
                </View>
              </View>
            )}
          />
          <TouchableOpacity
            onPress={() => setReorderMode(false)}
            style={{ position: 'absolute', bottom: 24, left: Spacing.lg, right: Spacing.lg,
              backgroundColor: Colors.primary, borderRadius: Radius.md,
              paddingVertical: 14, alignItems: 'center' }}>
            <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
              fontSize: FontSize.md }}>Done Reordering ✓</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <ScrollView contentContainerStyle={{ padding: Spacing.md, paddingBottom: 60 }}>
          {grouped.map((group, gi) =>
            group.length === 1 ? (
              <ExerciseBlock
                key={group[0].id}
                ex={group[0]}
                exState={exStates[group[0].id]}
                onUpdateState={(p) => updateExState(group[0].id, p)}
                onSetComplete={(i, w, r) => handleSetComplete(group[0], i, w, r)}
                allSessionExercises={activeSession.exercises}
                allStates={exStates}
                onOpenSupersetPicker={() => setSupersetPickerForId(group[0].id)}
                onRemoveFromGroup={() => handleRemoveFromGroup(group[0].id)}
                onOpenSwap={() => setSwapForId(group[0].id)}
                onRemoveExercise={() => setRemoveConfirmFor(group[0])}
                suggestion={visibleSuggestions[group[0].id]}
                onOpenSuggestion={() => setSuggestionFor(group[0])}
                onOpenTrend={(t) => setTrendFor({ name: group[0].exercise.name, trend: t })}
              />
            ) : (
              <SupersetBlock
                key={gi}
                exercises={group}
                exStates={exStates}
                onUpdateState={updateExState}
                onSetComplete={handleSetComplete}
                allSessionExercises={activeSession.exercises}
                onOpenSupersetPicker={(id) => setSupersetPickerForId(id)}
                onRemoveFromGroup={handleRemoveFromGroup}
                onRemoveExercise={(ex) => setRemoveConfirmFor(ex)}
                onOpenSwap={(id) => setSwapForId(id)}
                suggestions={visibleSuggestions}
                onOpenSuggestion={(ex) => setSuggestionFor(ex)}
                onOpenTrend={(ex, t) => setTrendFor({ name: ex.exercise.name, trend: t })}
              />
            )
          )}

          <TouchableOpacity onPress={() => setAddExVisible(true)}
            style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
              gap: 8, borderRadius: Radius.lg, borderWidth: 1.5,
              borderColor: Colors.primary, borderStyle: 'dashed',
              paddingVertical: Spacing.md, marginTop: Spacing.sm }}>
            <Ionicons name="add-circle-outline" size={18} color={Colors.primary} />
            <Text style={{ color: Colors.primary, fontWeight: FontWeight.medium,
              fontSize: FontSize.sm }}>Add Exercise</Text>
          </TouchableOpacity>
        </ScrollView>
      )}

      {/* ── Modals ───────────────────────────────────────────────────────────── */}
      <AddExerciseModal
        visible={addExVisible}
        existingIds={activeSession.exercises.map((e) => e.exercise.id)}
        onAdd={handleAddExercise}
        onClose={() => setAddExVisible(false)}
      />
      {swapForId !== null && (() => {
        const cur = activeSession.exercises.find((e) => e.id === swapForId);
        return cur ? (
          <SwapExerciseModal
            current={cur}
            existingIds={activeSession.exercises.map((e) => e.exercise.id)}
            onSelect={(newExerciseId) => handleSwap(swapForId, newExerciseId)}
            onClose={() => setSwapForId(null)}
          />
        ) : null;
      })()}
      {supersetPickerForId !== null && (
        <SupersetPickerModal
          visible
          initiatorId={supersetPickerForId}
          exercises={activeSession.exercises}
          exStates={exStates}
          onAssign={(targetIds) => {
            handleAssignSuperset(supersetPickerForId, targetIds);
            setSupersetPickerForId(null);
          }}
          onClose={() => setSupersetPickerForId(null)}
        />
      )}
      {summary && (
        <WorkoutSummaryOverlay summary={summary} onDismiss={handleSummaryDismiss} />
      )}
      {trendFor && (
        <TrendSheet
          exerciseName={trendFor.name}
          trend={trendFor.trend}
          onClose={() => setTrendFor(null)}
        />
      )}
      {suggestionFor?.suggestion && (
        <SuggestionSheet
          exerciseName={suggestionFor.exercise.name}
          suggestion={suggestionFor.suggestion}
          onApply={() => applySuggestion(suggestionFor)}
          onDismiss={() => dismissSuggestion(suggestionFor)}
          onClose={() => setSuggestionFor(null)}
        />
      )}

      {/* ── Remove-exercise confirmation ────────────────────────────────────── */}
      <Modal visible={removeConfirmFor !== null} transparent animationType="fade">
        <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.45)',
          justifyContent: 'center', alignItems: 'center', padding: Spacing.lg }}>
          <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
            padding: Spacing.lg, width: '100%', maxWidth: 320, ...Shadow.float }}>
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
              color: Colors.textPrimary, marginBottom: Spacing.xs }}>
              Remove exercise?
            </Text>
            <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
              marginBottom: Spacing.lg }}>
              {removeConfirmFor?.exercise.name} and any sets logged for it will be
              dropped from this workout. Your program keeps the exercise.
            </Text>
            <TouchableOpacity
              onPress={() => removeConfirmFor && handleRemoveExercise(removeConfirmFor.id)}
              style={{ backgroundColor: Colors.error, borderRadius: Radius.md,
                paddingVertical: 14, alignItems: 'center', marginBottom: Spacing.sm }}>
              <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                fontSize: FontSize.md }}>Remove Exercise</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => setRemoveConfirmFor(null)}
              style={{ alignItems: 'center', paddingVertical: 10 }}>
              <Text style={{ color: Colors.textSecondary, fontSize: FontSize.sm }}>
                Keep It
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      {/* ── Cancel confirmation ─────────────────────────────────────────────── */}
      <Modal visible={cancelConfirm} transparent animationType="fade">
        <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.45)',
          justifyContent: 'center', alignItems: 'center', padding: Spacing.lg }}>
          <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
            padding: Spacing.lg, width: '100%', maxWidth: 320, ...Shadow.float }}>
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
              color: Colors.textPrimary, marginBottom: Spacing.xs }}>
              Cancel Workout?
            </Text>
            <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
              marginBottom: Spacing.lg }}>
              This will discard all logged sets and cannot be undone.
            </Text>
            <TouchableOpacity
              onPress={handleCancelConfirmed}
              style={{ backgroundColor: Colors.error, borderRadius: Radius.md,
                paddingVertical: 14, alignItems: 'center', marginBottom: Spacing.sm }}>
              <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                fontSize: FontSize.md }}>Discard Workout</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => setCancelConfirm(false)}
              style={{ alignItems: 'center', paddingVertical: 10 }}>
              <Text style={{ color: Colors.textSecondary, fontSize: FontSize.sm }}>
                Keep Going
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

// ─── Suggestion helpers ───────────────────────────────────────────────────────

/** Dismissal key: exercise + type + message → new data resurfaces the badge. */
function suggestionKey(ex: SessionExerciseResponse): string {
  return `${ex.exercise.id}:${ex.suggestion?.type}:${ex.suggestion?.message}`;
}

// ─── Group builder ────────────────────────────────────────────────────────────

function buildGroups(
  exercises: SessionExerciseResponse[],
  states: Record<number, ExState>,
): SessionExerciseResponse[][] {
  const groups: SessionExerciseResponse[][] = [];
  const seen = new Set<number>();
  for (const ex of exercises) {
    if (seen.has(ex.id)) continue;
    seen.add(ex.id);
    const gid = states[ex.id]?.supersetGroupId;
    if (gid) {
      const peers = exercises.filter(
        (e) => !seen.has(e.id) && states[e.id]?.supersetGroupId === gid
      );
      peers.forEach((e) => seen.add(e.id));
      groups.push([ex, ...peers]);
    } else {
      groups.push([ex]);
    }
  }
  return groups;
}

// ─── Rest timer bar ───────────────────────────────────────────────────────────

function RestTimerBar() {
  const {
    restTimerActive, restTimerRemaining, restTimerSeconds, restTimerEndsAt,
  } = useWorkoutStore();

  // The bar animates continuously to the end of the rest rather than being
  // redrawn once per tick, which is what made it look like it was stuttering.
  // Driven off restTimerEndsAt, so it does not restart on every tick and picks
  // up the real remaining time if a tick arrives late.
  const progress = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (!restTimerActive || !restTimerEndsAt || restTimerSeconds <= 0) return;
    const msLeft = Math.max(0, restTimerEndsAt - Date.now());
    progress.setValue(msLeft / (restTimerSeconds * 1000));
    const animation = Animated.timing(progress, {
      toValue: 0,
      duration: msLeft,
      easing: Easing.linear,
      // Width cannot be driven natively; the bar is 3px so the JS driver is fine.
      useNativeDriver: false,
    });
    animation.start();
    return () => animation.stop();
  }, [restTimerActive, restTimerEndsAt, restTimerSeconds]);

  if (!restTimerActive) return null;
  const mins = Math.floor(restTimerRemaining / 60);
  const secs = restTimerRemaining % 60;
  return (
    <View style={{ marginTop: 8 }}>
      <View style={{ flexDirection: 'row', justifyContent: 'space-between',
        alignItems: 'center', marginBottom: 4 }}>
        <Text style={{ fontSize: FontSize.xs, color: Colors.primary,
          fontWeight: FontWeight.medium }}>Rest</Text>
        <Text style={{ fontSize: FontSize.xs, color: Colors.primary,
          fontWeight: FontWeight.semibold, fontVariant: ['tabular-nums'] }}>
          {mins}:{secs.toString().padStart(2, '0')}
        </Text>
      </View>
      <View style={{ height: 3, backgroundColor: Colors.surfaceSubtle,
        borderRadius: 2, overflow: 'hidden' }}>
        <Animated.View style={{ height: 3, borderRadius: 2,
          backgroundColor: Colors.primary,
          width: progress.interpolate({
            inputRange: [0, 1],
            outputRange: ['0%', '100%'],
          }) }} />
      </View>
    </View>
  );
}

// ─── Muscle chips ─────────────────────────────────────────────────────────────
// PRIMARY (agonist)  = full-saturation indigo chip
// SECONDARY (synergist) = same hue, lower saturation to signal the difference

function MuscleChips({ muscles }: { muscles: SessionExerciseResponse['exercise']['muscles'] }) {
  const primary   = muscles.filter((m) => m.role === 'PRIMARY');
  const secondary = muscles.filter((m) => m.role === 'SECONDARY');
  if (!primary.length && !secondary.length) return null;
  return (
    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 4, marginTop: 4 }}>
      {primary.map((m) => (
        <View key={`p-${m.muscleGroupId}`} style={{
          backgroundColor: Colors.primary, borderRadius: Radius.full,
          paddingHorizontal: 7, paddingVertical: 2,
        }}>
          <Text style={{ fontSize: 10, color: Colors.textInverse,
            fontWeight: FontWeight.semibold }}>{m.muscleGroupName}</Text>
        </View>
      ))}
      {secondary.map((m) => (
        <View key={`s-${m.muscleGroupId}`} style={{
          backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
          paddingHorizontal: 7, paddingVertical: 2,
          borderWidth: 1, borderColor: Colors.primaryLight,
        }}>
          <Text style={{ fontSize: 10, color: Colors.primaryLight,
            fontWeight: FontWeight.medium }}>{m.muscleGroupName}</Text>
        </View>
      ))}
    </View>
  );
}

// ─── Exercise block ───────────────────────────────────────────────────────────

function ExerciseBlock({ ex, exState, onUpdateState, onSetComplete,
  allSessionExercises, allStates, onOpenSupersetPicker, onRemoveFromGroup,
  onOpenSwap, onRemoveExercise, suggestion, onOpenSuggestion, onOpenTrend }: {
  ex: SessionExerciseResponse;
  exState: ExState | undefined;
  onUpdateState: (p: Partial<ExState>) => void;
  onSetComplete: (rowIdx: number, weight: string, reps: string) => void;
  allSessionExercises: SessionExerciseResponse[];
  allStates: Record<number, ExState>;
  onOpenSupersetPicker: () => void;
  onRemoveFromGroup: () => void;
  onOpenSwap: () => void;
  onRemoveExercise: () => void;
  suggestion?: ProgressionSuggestion;
  onOpenSuggestion?: () => void;
  onOpenTrend: (trend: ProgressionTrend) => void;
}) {
  const [menuVisible, setMenuVisible] = useState(false);
  if (!exState) return null;
  const inGroup = !!exState.supersetGroupId;

  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      marginBottom: Spacing.sm, ...Shadow.card, overflow: 'hidden' }}>
      {/* Exercise header */}
      <View style={{ flexDirection: 'row', alignItems: 'flex-start', padding: Spacing.md,
        borderBottomWidth: 1, borderBottomColor: Colors.border }}>
        <View style={{ flex: 1 }}>
          <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>{ex.exercise.name}</Text>
          <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary, marginTop: 1 }}>
            {exState.rows.length} sets
            {ex.repsMin != null
              ? ` · ${ex.repsMin}${ex.repsMax != null && ex.repsMax !== ex.repsMin ? `–${ex.repsMax}` : ''} reps`
              : ''}
          </Text>
          <MuscleChips muscles={ex.exercise.muscles} />
        </View>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 2 }}>
          {/* Week-to-week trend — how last session went vs the one before */}
          {ex.trend && (
            <TrendBadge trend={ex.trend} onPress={() => onOpenTrend(ex.trend!)} />
          )}
          {suggestion && onOpenSuggestion && (
            <SuggestionBadge type={suggestion.type} onPress={onOpenSuggestion} />
          )}
          <MethodPicker
            value={exState.method}
            onChange={(m) => onUpdateState(methodChangePatch(ex, exState, m))}
          />
          <TouchableOpacity onPress={() => setMenuVisible(true)}
            style={{ padding: 8 }}
            hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
            <Ionicons name="ellipsis-vertical" size={18} color={Colors.textMuted} />
          </TouchableOpacity>
        </View>
      </View>

      {/* Sets table */}
      <View style={{ paddingHorizontal: Spacing.sm, paddingBottom: Spacing.sm }}>
        {exState.method === 'MYOREPS' ? (
          // Myo-reps: no rest chips — rest between mini-sets is a fixed ~10s,
          // started automatically when a set is checked off.
          <MyorepsTable
            ex={ex}
            rows={exState.rows}
            onRowsChange={(rows) => onUpdateState({ rows })}
            onSetComplete={onSetComplete}
          />
        ) : (
          <>
            <RestInput
              value={exState.restSeconds}
              onChange={(v) => onUpdateState({ restSeconds: v })}
            />
            <StraightSetsTable
              ex={ex}
              rows={exState.rows}
              onRowsChange={(rows) => onUpdateState({ rows })}
              onSetComplete={onSetComplete}
            />
          </>
        )}
      </View>

      {/* Exercise menu */}
      <ExerciseMenu
        visible={menuVisible}
        inGroup={inGroup}
        onClose={() => setMenuVisible(false)}
        onGroupWith={() => { setMenuVisible(false); onOpenSupersetPicker(); }}
        onRemoveFromGroup={() => { setMenuVisible(false); onRemoveFromGroup(); }}
        onSwap={() => { setMenuVisible(false); onOpenSwap(); }}
        onRemoveExercise={() => { setMenuVisible(false); onRemoveExercise(); }}
      />
    </View>
  );
}

// ─── Superset block ───────────────────────────────────────────────────────────

function SupersetBlock({ exercises, exStates, onUpdateState, onSetComplete,
  allSessionExercises, onOpenSupersetPicker, onRemoveFromGroup, onRemoveExercise,
  onOpenSwap, suggestions, onOpenSuggestion, onOpenTrend }: {
  exercises: SessionExerciseResponse[];
  exStates: Record<number, ExState>;
  onUpdateState: (exId: number, p: Partial<ExState>) => void;
  onSetComplete: (ex: SessionExerciseResponse, rowIdx: number, w: string, r: string) => void;
  allSessionExercises: SessionExerciseResponse[];
  onOpenSupersetPicker: (exId: number) => void;
  onRemoveFromGroup: (exId: number) => void;
  onRemoveExercise: (ex: SessionExerciseResponse) => void;
  onOpenSwap: (exId: number) => void;
  suggestions?: Record<number, ProgressionSuggestion>;
  onOpenSuggestion?: (ex: SessionExerciseResponse) => void;
  onOpenTrend: (ex: SessionExerciseResponse, trend: ProgressionTrend) => void;
}) {
  const label = exercises.length === 2 ? 'Superset' : 'Circle';
  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      marginBottom: Spacing.sm, ...Shadow.card, overflow: 'hidden',
      borderWidth: 1.5, borderColor: Colors.primary }}>
      <View style={{ backgroundColor: Colors.primaryTint, paddingHorizontal: Spacing.md,
        paddingVertical: 6 }}>
        <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.semibold,
          color: Colors.primary, textTransform: 'uppercase', letterSpacing: 0.5 }}>
          {label}
        </Text>
      </View>
      {exercises.map((ex, idx) => {
        const st = exStates[ex.id];
        if (!st) return null;
        return (
          <View key={ex.id}>
            {idx > 0 && (
              <View style={{ height: 1, backgroundColor: Colors.border,
                marginHorizontal: Spacing.md }} />
            )}
            <View style={{ paddingHorizontal: Spacing.md, paddingTop: Spacing.sm }}>
              <View style={{ flexDirection: 'row', alignItems: 'flex-start', marginBottom: 6 }}>
                <View style={{ flex: 1 }}>
                  <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
                    color: Colors.textPrimary }}>{ex.exercise.name}</Text>
                  <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary, marginTop: 1 }}>
                    {st.rows.length} sets
                    {ex.repsMin != null
                      ? ` · ${ex.repsMin}${ex.repsMax != null && ex.repsMax !== ex.repsMin ? `–${ex.repsMax}` : ''} reps`
                      : ''}
                  </Text>
                  <MuscleChips muscles={ex.exercise.muscles} />
                </View>
                {ex.trend && (
                  <TrendBadge
                    trend={ex.trend}
                    size={20}
                    onPress={() => onOpenTrend(ex, ex.trend!)}
                  />
                )}
                {suggestions?.[ex.id] && onOpenSuggestion && (
                  <SuggestionBadge
                    type={suggestions[ex.id].type}
                    onPress={() => onOpenSuggestion(ex)}
                  />
                )}
                {/* Same kebab as an ungrouped exercise — ungroup and delete used
                    to sit here as bare icons, crowding the trend and suggestion
                    badges and inviting mis-taps. */}
                <GroupMemberMenu
                  onSwap={() => onOpenSwap(ex.id)}
                  onRemoveFromGroup={() => onRemoveFromGroup(ex.id)}
                  onRemoveExercise={() => onRemoveExercise(ex)}
                />
              </View>
              {st.method === 'MYOREPS' ? (
                <MyorepsTable
                  ex={ex}
                  rows={st.rows}
                  onRowsChange={(rows) => onUpdateState(ex.id, { rows })}
                  onSetComplete={(i, w, r) => onSetComplete(ex, i, w, r)}
                />
              ) : (
                <StraightSetsTable
                  ex={ex}
                  rows={st.rows}
                  onRowsChange={(rows) => onUpdateState(ex.id, { rows })}
                  onSetComplete={(i, w, r) => onSetComplete(ex, i, w, r)}
                />
              )}
            </View>
          </View>
        );
      })}
    </View>
  );
}

// ─── Column header row ────────────────────────────────────────────────────────

function ColHeader() {
  return (
    <View style={{ flexDirection: 'row', paddingVertical: 4, paddingHorizontal: 4, alignItems: 'center' }}>
      <Text style={[colLabel, {flex: COL.set }]}>Set</Text>
      <Text style={[colLabel, { flex: COL.prev }]}>Prev</Text>
      <Text style={[colLabel, { flex: COL.kg }]}>kg</Text>
      <Text style={[colLabel, { flex: COL.reps }]}>Reps</Text>
      <View style={{ flex: COL.check }} />
    </View>
  );
}

const colLabel: object = {
  fontSize: FontSize.xs,
  color: Colors.textMuted,
  fontWeight: FontWeight.medium,
  textAlign: 'center',
};

// ─── Set badge + dropdown menu ────────────────────────────────────────────────
// Tapping the numbered badge opens a small dropdown with "Remove Set N".

function SetBadge({ index, completed, onRemove }: {
  index: number;
  completed: boolean;
  onRemove: () => void;
}) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <TouchableOpacity
        onPress={() => !completed && setOpen(true)}
        style={{ flex: COL.set, alignItems: 'center' }}
        activeOpacity={completed ? 1 : 0.6}
      >
        <View style={{
          width: 22, height: 22, borderRadius: 11,
          backgroundColor: completed ? Colors.success : Colors.surfaceSubtle,
          alignItems: 'center', justifyContent: 'center',
          borderWidth: completed ? 0 : 1,
          borderColor: Colors.border,
        }}>
          <Text style={{ fontSize: 11, fontWeight: FontWeight.bold,
            color: completed ? Colors.textInverse : Colors.textSecondary }}>
            {index + 1}
          </Text>
        </View>
      </TouchableOpacity>

      {/* Dropdown overlay */}
      <Modal visible={open} transparent animationType="fade">
        <TouchableOpacity
          style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.25)',
            justifyContent: 'center', alignItems: 'center' }}
          onPress={() => setOpen(false)}
          activeOpacity={1}
        >
          <View style={{
            backgroundColor: Colors.surface, borderRadius: Radius.lg,
            paddingVertical: Spacing.xs, minWidth: 190, ...Shadow.float,
          }}>
            <TouchableOpacity
              onPress={() => { setOpen(false); onRemove(); }}
              style={{ flexDirection: 'row', alignItems: 'center', gap: 10,
                paddingHorizontal: Spacing.md, paddingVertical: 12 }}>
              <Ionicons name="trash-outline" size={16} color={Colors.error} />
              <Text style={{ fontSize: FontSize.sm, color: Colors.error,
                fontWeight: FontWeight.medium }}>Remove Set {index + 1}</Text>
            </TouchableOpacity>
            <View style={{ height: 1, backgroundColor: Colors.border,
              marginHorizontal: Spacing.md }} />
            <TouchableOpacity
              onPress={() => setOpen(false)}
              style={{ alignItems: 'center', paddingVertical: 10 }}>
              <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </TouchableOpacity>
      </Modal>
    </>
  );
}

// ─── Straight sets table ──────────────────────────────────────────────────────

function StraightSetsTable({ ex, rows, onRowsChange, onSetComplete }: {
  ex: SessionExerciseResponse;
  rows: SetRow[];
  onRowsChange: (rows: SetRow[]) => void;
  onSetComplete: (rowIdx: number, weight: string, reps: string) => void;
}) {
  // Removing a set shifts the ones below it up, so re-derive every row's
  // previous-session hint against its new set index.
  const removeRow = (idx: number) => {
    onRowsChange(withPrev(ex, rows.filter((_, i) => i !== idx)));
  };

  // A new set reads its own previous-session values by set index — nothing is
  // carried over from the row above, and rows past last session's set count
  // stay blank.
  const addRow = () => {
    onRowsChange([...rows, {
      weight: '', reps: '', completed: false, ...prevAt(ex, rows.length),
    }]);
  };

  const updateRow = (idx: number, patch: Partial<SetRow>) => {
    onRowsChange(rows.map((r, i) => i === idx ? { ...r, ...patch } : r));
  };

  return (
    <View>
      <ColHeader />
      {rows.map((row, i) => {
        const prev = ex.previousSets[i];
        const prevLabel = prev
          ? `${prev.weightKg != null ? prev.weightKg : 'BW'}×${prev.reps}`
          : '—';
        return (
          <View key={i} style={{ flexDirection: 'row', alignItems: 'center',
            paddingVertical: 5, paddingHorizontal: 4, borderRadius: Radius.sm,
            backgroundColor: row.completed ? Colors.successTint : 'transparent',
            marginBottom: 2 }}>
            {/* Set number badge — tap to open remove dropdown */}
            <SetBadge index={i} completed={row.completed} onRemove={() => removeRow(i)} />
            {/* Previous set value */}
            <View style={{ flex: COL.prev, alignItems: 'center' }}>
              <Text style={{ fontSize: 11, color: Colors.textMuted, fontVariant: ['tabular-nums'] }}>
                {prevLabel}
              </Text>
            </View>
            {/* Weight input */}
            <TextInput
              value={row.weight}
              onChangeText={(v) => updateRow(i, { weight: v })}
              placeholder={row.prevWeight || '—'}
              placeholderTextColor={Colors.textMuted}
              keyboardType="decimal-pad"
              editable={!row.completed}
              style={[inputStyle, { flex: COL.kg, minWidth: 48,
                color: row.completed ? Colors.success : Colors.textPrimary }]}
            />
            {/* Reps input */}
            <TextInput
              value={row.reps}
              onChangeText={(v) => updateRow(i, { reps: v })}
              placeholder={row.prevReps || '—'}
              placeholderTextColor={Colors.textMuted}
              keyboardType="number-pad"
              editable={!row.completed}
              style={[inputStyle, { flex: COL.reps, minWidth: 44,
                color: row.completed ? Colors.success : Colors.textPrimary }]}
            />
            {/* Checkmark — fills in placeholders if user typed nothing */}
            <TouchableOpacity
              onPress={() => {
                if (!row.completed) {
                  const w = row.weight.trim() || row.prevWeight;
                  const r = row.reps.trim()   || row.prevReps;
                  if (w !== row.weight || r !== row.reps) {
                    updateRow(i, { weight: w, reps: r });
                  }
                  onSetComplete(i, w, r);
                } else {
                  onSetComplete(i, row.weight, row.reps);
                }
              }}
              style={{ flex: COL.check, alignItems: 'center' }}>
              <Ionicons
                name={row.completed ? 'checkmark-circle' : 'checkmark-circle-outline'}
                size={22}
                color={row.completed ? Colors.success : Colors.textMuted}
              />
            </TouchableOpacity>
          </View>
        );
      })}
      {/* Add set */}
      <TouchableOpacity onPress={addRow}
        style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
          gap: 4, paddingVertical: 8, marginTop: 2 }}>
        <Ionicons name="add-circle-outline" size={14} color={Colors.primary} />
        <Text style={{ fontSize: FontSize.xs, color: Colors.primary }}>Add set</Text>
      </TouchableOpacity>
    </View>
  );
}

// ─── Myo-reps table ───────────────────────────────────────────────────────────

function MyorepsTable({ ex, rows, onRowsChange, onSetComplete }: {
  ex: SessionExerciseResponse;
  rows: SetRow[];
  onRowsChange: (rows: SetRow[]) => void;
  onSetComplete: (rowIdx: number, weight: string, reps: string) => void;
}) {
  // Removing a set shifts the ones below it up, so re-derive every row's
  // previous-session hint against its new set index.
  const removeRow = (idx: number) => {
    onRowsChange(withPrev(ex, rows.filter((_, i) => i !== idx)));
  };

  // Mini-sets share the activation load, so a new set inherits the current
  // working weight, but its previous-session reps come from that set index.
  const addSet = () => {
    const activation = rows[0];
    const prev = prevAt(ex, rows.length);
    onRowsChange([...rows, {
      weight: activation?.weight || '', reps: '', completed: false,
      prevWeight: prev.prevWeight || activation?.prevWeight || '',
      prevReps:   prev.prevReps,
    }]);
  };

  const updateRow = (idx: number, patch: Partial<SetRow>) => {
    onRowsChange(rows.map((r, i) => i === idx ? { ...r, ...patch } : r));
  };

  return (
    <View>
      <ColHeader />

      {rows.map((row, i) => {
        const isFirst  = i === 0;
        const prev     = ex.previousSets[i];
        const prevLabel = prev
          ? `${prev.weightKg != null ? prev.weightKg : 'BW'}×${prev.reps}`
          : '—';

        return (
          <View key={i} style={{ flexDirection: 'row', alignItems: 'center',
            paddingVertical: 5, paddingHorizontal: 4, borderRadius: Radius.sm,
            backgroundColor: row.completed ? Colors.successTint : 'transparent',
            marginBottom: 2 }}>
            {/* Set number badge — tap to open remove dropdown */}
            <SetBadge index={i} completed={row.completed} onRemove={() => removeRow(i)} />
            {/* Previous set value */}
            <View style={{ flex: COL.prev, alignItems: 'center' }}>
              <Text style={{ fontSize: 11, color: Colors.textMuted, fontVariant: ['tabular-nums'] }}>
                {prevLabel}
              </Text>
            </View>
            {/* Weight — editable on first set; propagates weight to subsequent sets */}
            <TextInput
              value={row.weight}
              onChangeText={(v) => {
                if (isFirst) {
                  // propagate actual weight to all rows
                  onRowsChange(rows.map((r) => ({ ...r, weight: v })));
                } else {
                  onRowsChange(rows.map((r, j) => j === i ? { ...r, weight: v } : r));
                }
              }}
              placeholder={row.prevWeight || '—'}
              placeholderTextColor={Colors.textMuted}
              keyboardType="decimal-pad"
              editable={isFirst && !row.completed}
              style={[inputStyle, { flex: COL.kg, minWidth: 48,
                color: row.completed ? Colors.success : isFirst ? Colors.textPrimary : Colors.textMuted,
                opacity: isFirst ? 1 : 0.7 }]}
            />
            {/* Reps */}
            <TextInput
              value={row.reps}
              onChangeText={(v) => onRowsChange(rows.map((r, j) => j === i ? { ...r, reps: v } : r))}
              placeholder={row.prevReps || '—'}
              placeholderTextColor={Colors.textMuted}
              keyboardType="number-pad"
              editable={!row.completed}
              style={[inputStyle, { flex: COL.reps, minWidth: 44,
                color: row.completed ? Colors.success : Colors.textPrimary }]}
            />
            {/* Checkmark — fills placeholder on first tap */}
            <TouchableOpacity
              onPress={() => {
                if (!row.completed) {
                  const w = row.weight.trim() || row.prevWeight;
                  const r = row.reps.trim()   || row.prevReps;
                  if (isFirst && w !== row.weight) {
                    // propagate resolved weight to all rows
                    onRowsChange(rows.map((ro, j) =>
                      j === i ? { ...ro, weight: w, reps: r } : { ...ro, weight: w }
                    ));
                  } else if (w !== row.weight || r !== row.reps) {
                    onRowsChange(rows.map((ro, j) => j === i ? { ...ro, weight: w, reps: r } : ro));
                  }
                  onSetComplete(i, w, r);
                } else {
                  onSetComplete(i, row.weight, row.reps);
                }
              }}
              style={{ flex: COL.check, alignItems: 'center' }}>
              <Ionicons
                name={row.completed ? 'checkmark-circle' : 'checkmark-circle-outline'}
                size={22}
                color={row.completed ? Colors.success : Colors.textMuted}
              />
            </TouchableOpacity>
          </View>
        );
      })}

      {/* Add set */}
      <TouchableOpacity onPress={addSet}
        style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
          gap: 4, paddingVertical: 8, marginTop: 2 }}>
        <Ionicons name="add-circle-outline" size={14} color={Colors.primary} />
        <Text style={{ fontSize: FontSize.xs, color: Colors.primary }}>Add set</Text>
      </TouchableOpacity>
    </View>
  );
}

const inputStyle: object = {
  height: 32,
  backgroundColor: Colors.surfaceMuted,
  borderRadius: Radius.sm,
  textAlign: 'center',
  fontSize: FontSize.sm,
  fontWeight: FontWeight.semibold,
  borderWidth: 1,
  borderColor: Colors.border,
  marginHorizontal: 2,
};

// ─── Method picker ────────────────────────────────────────────────────────────

const METHOD_LABELS: Record<TrainingMethod, string> = {
  STRAIGHT_SETS: 'Straight',
  MYOREPS:       'Myo-reps',
  SUPERSET:      'Superset',
  TRISET:        'Circle',
  DROP_SET:      'Drop set',
};

function MethodPicker({ value, onChange }: {
  value: TrainingMethod;
  onChange: (m: TrainingMethod) => void;
}) {
  const [open, setOpen] = useState(false);
  const methods: TrainingMethod[] = ['STRAIGHT_SETS', 'MYOREPS', 'DROP_SET'];

  return (
    <>
      <TouchableOpacity onPress={() => setOpen(true)}
        style={{ flexDirection: 'row', alignItems: 'center', gap: 4,
          backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
          paddingHorizontal: 10, paddingVertical: 5 }}>
        <Text style={{ fontSize: FontSize.xs, color: Colors.primary,
          fontWeight: FontWeight.medium }}>{METHOD_LABELS[value]}</Text>
        <Ionicons name="chevron-down" size={12} color={Colors.primary} />
      </TouchableOpacity>

      <Modal visible={open} transparent animationType="fade">
        <TouchableOpacity style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.4)',
          justifyContent: 'center', alignItems: 'center' }}
          onPress={() => setOpen(false)} activeOpacity={1}>
          <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
            padding: Spacing.sm, width: 200, ...Shadow.float }}>
            {methods.map((m) => (
              <TouchableOpacity key={m} onPress={() => { onChange(m); setOpen(false); }}
                style={{ flexDirection: 'row', alignItems: 'center', gap: 10,
                  paddingVertical: 12, paddingHorizontal: Spacing.md,
                  borderRadius: Radius.md,
                  backgroundColor: m === value ? Colors.primaryTint : 'transparent' }}>
                {m === value && (
                  <Ionicons name="checkmark" size={14} color={Colors.primary} />
                )}
                {m !== value && <View style={{ width: 14 }} />}
                <Text style={{ fontSize: FontSize.sm,
                  color: m === value ? Colors.primary : Colors.textPrimary,
                  fontWeight: m === value ? FontWeight.semibold : FontWeight.regular }}>
                  {METHOD_LABELS[m]}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </TouchableOpacity>
      </Modal>
    </>
  );
}

// ─── Rest input ───────────────────────────────────────────────────────────────

const REST_OPTIONS = [60, 90, 120, 180];

function RestInput({ value, onChange }: { value: number; onChange: (v: number) => void }) {
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6,
      paddingHorizontal: 4, paddingTop: 8, paddingBottom: 4 }}>
      <Ionicons name="timer-outline" size={12} color={Colors.textMuted} />
      {REST_OPTIONS.map((s) => (
        <TouchableOpacity key={s} onPress={() => onChange(s)}
          style={{ paddingHorizontal: 8, paddingVertical: 3, borderRadius: Radius.full,
            backgroundColor: value === s ? Colors.primary : Colors.surfaceMuted,
            borderWidth: 1, borderColor: value === s ? Colors.primary : Colors.border }}>
          <Text style={{ fontSize: 10, fontWeight: FontWeight.medium,
            color: value === s ? Colors.textInverse : Colors.textSecondary }}>
            {s < 60 ? `${s}s` : `${s / 60}m`}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );
}

// ─── Exercise menu ────────────────────────────────────────────────────────────

function ExerciseMenu({ visible, inGroup, onClose, onGroupWith, onRemoveFromGroup,
  onSwap, onRemoveExercise }: {
  visible: boolean;
  inGroup: boolean;
  onClose: () => void;
  onGroupWith: () => void;
  onRemoveFromGroup: () => void;
  onSwap: () => void;
  onRemoveExercise: () => void;
}) {
  return (
    <Modal visible={visible} transparent animationType="fade">
      <TouchableOpacity style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.4)',
        justifyContent: 'flex-end' }}
        onPress={onClose} activeOpacity={1}>
        <View style={{ backgroundColor: Colors.surface, borderTopLeftRadius: Radius.xl,
          borderTopRightRadius: Radius.xl, padding: Spacing.md, paddingBottom: 32 }}>
          <TouchableOpacity onPress={onSwap}
            style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.md,
              padding: Spacing.md, borderRadius: Radius.md }}>
            <Ionicons name="swap-horizontal" size={20} color={Colors.textPrimary} />
            <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary }}>
              Swap exercise…
            </Text>
          </TouchableOpacity>
          {!inGroup && (
            <TouchableOpacity onPress={onGroupWith}
              style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.md,
                padding: Spacing.md, borderRadius: Radius.md }}>
              <Ionicons name="git-merge-outline" size={20} color={Colors.textPrimary} />
              <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary }}>
                Group with exercise…
              </Text>
            </TouchableOpacity>
          )}
          {inGroup && (
            <TouchableOpacity onPress={onRemoveFromGroup}
              style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.md,
                padding: Spacing.md, borderRadius: Radius.md }}>
              <Ionicons name="git-pull-request-outline" size={20} color={Colors.error} />
              <Text style={{ fontSize: FontSize.md, color: Colors.error }}>
                Remove from group
              </Text>
            </TouchableOpacity>
          )}
          <View style={{ height: 1, backgroundColor: Colors.border,
            marginVertical: Spacing.xs, marginHorizontal: Spacing.md }} />
          <TouchableOpacity onPress={onRemoveExercise}
            style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.md,
              padding: Spacing.md, borderRadius: Radius.md }}>
            <Ionicons name="trash-outline" size={20} color={Colors.error} />
            <Text style={{ fontSize: FontSize.md, color: Colors.error }}>
              Remove from workout
            </Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={onClose}
            style={{ alignItems: 'center', paddingTop: Spacing.sm }}>
            <Text style={{ color: Colors.textSecondary, fontSize: FontSize.sm }}>Cancel</Text>
          </TouchableOpacity>
        </View>
      </TouchableOpacity>
    </Modal>
  );
}

/**
 * Kebab for one member of a superset or circle. Same actions as the standalone
 * exercise menu, minus "group with" — it is already in a group.
 */
function GroupMemberMenu({ onSwap, onRemoveFromGroup, onRemoveExercise }: {
  onSwap: () => void;
  onRemoveFromGroup: () => void;
  onRemoveExercise: () => void;
}) {
  const [visible, setVisible] = useState(false);
  const close = () => setVisible(false);
  return (
    <>
      <TouchableOpacity onPress={() => setVisible(true)}
        style={{ paddingHorizontal: 6, paddingVertical: 4 }}
        hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
        <Ionicons name="ellipsis-vertical" size={16} color={Colors.textMuted} />
      </TouchableOpacity>
      <ExerciseMenu
        visible={visible}
        inGroup
        onClose={close}
        onGroupWith={close}
        onRemoveFromGroup={() => { close(); onRemoveFromGroup(); }}
        onSwap={() => { close(); onSwap(); }}
        onRemoveExercise={() => { close(); onRemoveExercise(); }}
      />
    </>
  );
}

// ─── Progression suggestion badge + sheet ─────────────────────────────────────
// One progression variable at a time, reps before weight: the badge only shows
// when the algorithm has something actionable (add weight / deload / swap).

const SUGGESTION_STYLES: Record<ProgressionSuggestion['type'], {
  icon: keyof typeof Ionicons.glyphMap; color: string; tint: string; title: string;
}> = {
  INCREASE_WEIGHT: { icon: 'trending-up',    color: Colors.success, tint: Colors.successTint, title: 'Increase weight' },
  DELOAD:          { icon: 'trending-down',  color: Colors.warning, tint: Colors.warningTint, title: 'Deload' },
  SWAP_EXERCISE:   { icon: 'swap-horizontal', color: Colors.primary, tint: Colors.primaryTint, title: 'Try a variation' },
};

function SuggestionBadge({ type, onPress }: {
  type: ProgressionSuggestion['type'];
  onPress: () => void;
}) {
  const s = SUGGESTION_STYLES[type];
  return (
    <TouchableOpacity
      onPress={onPress}
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
      style={{
        width: 24, height: 24, borderRadius: 12,
        backgroundColor: s.tint, borderWidth: 1, borderColor: s.color,
        alignItems: 'center', justifyContent: 'center',
      }}>
      <Ionicons name={s.icon} size={13} color={s.color} />
    </TouchableOpacity>
  );
}

function SuggestionSheet({ exerciseName, suggestion, onApply, onDismiss, onClose }: {
  exerciseName: string;
  suggestion: ProgressionSuggestion;
  onApply: () => void;
  onDismiss: () => void;
  onClose: () => void;
}) {
  const s = SUGGESTION_STYLES[suggestion.type];
  const canApply = suggestion.suggestedWeightKg != null;

  return (
    <Modal visible transparent animationType="slide">
      <TouchableOpacity
        style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.4)', justifyContent: 'flex-end' }}
        onPress={onClose} activeOpacity={1}>
        <TouchableOpacity activeOpacity={1} style={{
          backgroundColor: Colors.surface, borderTopLeftRadius: Radius.xl,
          borderTopRightRadius: Radius.xl, padding: Spacing.lg, paddingBottom: 36 }}>

          {/* Header */}
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.sm,
            marginBottom: Spacing.xs }}>
            <View style={{ width: 32, height: 32, borderRadius: 16,
              backgroundColor: s.tint, alignItems: 'center', justifyContent: 'center' }}>
              <Ionicons name={s.icon} size={17} color={s.color} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.bold,
                color: Colors.textPrimary }}>{s.title}</Text>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary }}>
                {exerciseName}
              </Text>
            </View>
          </View>

          {/* Why */}
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
            marginBottom: Spacing.md }}>
            {suggestion.message}
          </Text>

          {/* Swap alternatives (informational — swap is done in the program editor) */}
          {suggestion.type === 'SWAP_EXERCISE' && (suggestion.alternatives?.length ?? 0) > 0 && (
            <View style={{ marginBottom: Spacing.md }}>
              <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.semibold,
                color: Colors.textMuted, textTransform: 'uppercase', letterSpacing: 0.5,
                marginBottom: 6 }}>Alternatives</Text>
              {suggestion.alternatives!.map((alt) => (
                <View key={alt.id} style={{ flexDirection: 'row', alignItems: 'center',
                  gap: 8, paddingVertical: 6 }}>
                  <Ionicons name="barbell-outline" size={14} color={Colors.textMuted} />
                  <Text style={{ fontSize: FontSize.sm, color: Colors.textPrimary }}>
                    {alt.name}
                  </Text>
                </View>
              ))}
              <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 4 }}>
                Swap it in from your program's edit screen when you're ready.
              </Text>
            </View>
          )}

          {/* Apply */}
          {canApply && (
            <TouchableOpacity onPress={onApply}
              style={{ backgroundColor: s.color, borderRadius: Radius.md,
                paddingVertical: 14, alignItems: 'center', marginBottom: Spacing.sm }}>
              <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                fontSize: FontSize.md }}>
                Use {suggestion.suggestedWeightKg} kg for remaining sets
              </Text>
            </TouchableOpacity>
          )}

          {/* Dismiss */}
          <TouchableOpacity onPress={onDismiss}
            style={{ alignItems: 'center', paddingVertical: 10 }}>
            <Text style={{ color: Colors.textSecondary, fontSize: FontSize.sm }}>
              Dismiss
            </Text>
          </TouchableOpacity>
        </TouchableOpacity>
      </TouchableOpacity>
    </Modal>
  );
}

// ─── Superset picker modal ────────────────────────────────────────────────────

function SupersetPickerModal({ visible, initiatorId, exercises, exStates, onAssign, onClose }: {
  visible: boolean;
  initiatorId: number;
  exercises: SessionExerciseResponse[];
  exStates: Record<number, ExState>;
  onAssign: (targetIds: number[]) => void;
  onClose: () => void;
}) {
  const [selected, setSelected] = useState<Set<number>>(new Set());
  const initiatorGroupId = exStates[initiatorId]?.supersetGroupId;

  // Resulting group size = initiator + existing group peers + newly selected.
  const existingPeers = initiatorGroupId
    ? exercises.filter((e) => e.id !== initiatorId
        && exStates[e.id]?.supersetGroupId === initiatorGroupId
        && !selected.has(e.id)).length
    : 0;
  const resultingSize = 1 + existingPeers + selected.size;

  const eligible = exercises.filter(
    (e) => e.id !== initiatorId &&
      (exStates[e.id]?.supersetGroupId == null ||
       exStates[e.id]?.supersetGroupId === initiatorGroupId)
  );

  const toggle = (id: number) => {
    setSelected((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet">
      <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surface }}>
        <View style={{ flexDirection: 'row', alignItems: 'center',
          padding: Spacing.md, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
          <TouchableOpacity onPress={onClose} style={{ padding: 4, marginRight: Spacing.sm }}>
            <Ionicons name="close" size={22} color={Colors.textPrimary} />
          </TouchableOpacity>
          <Text style={{ flex: 1, fontSize: FontSize.md, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>Group with…</Text>
          {selected.size > 0 && (
            <TouchableOpacity
              onPress={() => onAssign([...selected])}
              style={{ backgroundColor: Colors.primary, borderRadius: Radius.full,
                paddingHorizontal: 14, paddingVertical: 6 }}>
              <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                fontSize: FontSize.sm }}>
                {resultingSize <= 2 ? 'Create Superset' : 'Create Circle'}
              </Text>
            </TouchableOpacity>
          )}
        </View>
        <ScrollView>
          {eligible.map((e) => {
            const sel = selected.has(e.id);
            return (
              <TouchableOpacity key={e.id} onPress={() => toggle(e.id)}
                style={{ flexDirection: 'row', alignItems: 'center',
                  padding: Spacing.md, borderBottomWidth: 1, borderBottomColor: Colors.border,
                  backgroundColor: sel ? Colors.primaryTint : 'transparent' }}>
                <View style={{ width: 22, height: 22, borderRadius: 11,
                  borderWidth: 2, borderColor: sel ? Colors.primary : Colors.border,
                  backgroundColor: sel ? Colors.primary : 'transparent',
                  alignItems: 'center', justifyContent: 'center', marginRight: Spacing.md }}>
                  {sel && <Ionicons name="checkmark" size={14} color={Colors.textInverse} />}
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary,
                    fontWeight: FontWeight.medium }}>{e.exercise.name}</Text>
                  <MuscleChips muscles={e.exercise.muscles} />
                </View>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </SafeAreaView>
    </Modal>
  );
}

// ─── Add exercise modal ───────────────────────────────────────────────────────

function AddExerciseModal({ visible, existingIds, onAdd, onClose }: {
  visible: boolean;
  existingIds: number[];
  onAdd: (exerciseId: number) => void;
  onClose: () => void;
}) {
  const [search, setSearch] = useState('');
  const { data: allExercises } = useQuery({
    queryKey: ['exercises'],
    queryFn: exercisesApi.list,
  });

  const filtered = (allExercises ?? []).filter(
    (e) => !existingIds.includes(e.id) &&
      e.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet">
      <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surface }}>
        <View style={{ flexDirection: 'row', alignItems: 'center',
          padding: Spacing.md, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
          <TouchableOpacity onPress={onClose} style={{ padding: 4, marginRight: Spacing.sm }}>
            <Ionicons name="close" size={22} color={Colors.textPrimary} />
          </TouchableOpacity>
          <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>Add Exercise</Text>
        </View>
        <View style={{ paddingHorizontal: Spacing.md, paddingVertical: Spacing.sm }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8,
            backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
            paddingHorizontal: 12, borderWidth: 1, borderColor: Colors.border }}>
            <Ionicons name="search" size={16} color={Colors.textMuted} />
            <TextInput value={search} onChangeText={setSearch}
              placeholder="Search exercises…" placeholderTextColor={Colors.textMuted}
              style={{ flex: 1, paddingVertical: 10, fontSize: FontSize.md,
                color: Colors.textPrimary }} />
          </View>
        </View>
        <ScrollView>
          {filtered.map((ex) => (
            <TouchableOpacity key={ex.id}
              onPress={() => onAdd(ex.id)}
              style={{ flexDirection: 'row', alignItems: 'center',
                padding: Spacing.md, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
              <View style={{ flex: 1 }}>
                <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary,
                  fontWeight: FontWeight.medium }}>{ex.name}</Text>
                <MuscleChips muscles={ex.muscles} />
              </View>
              <Ionicons name="add-circle-outline" size={22} color={Colors.primary} />
            </TouchableOpacity>
          ))}
        </ScrollView>
      </SafeAreaView>
    </Modal>
  );
}

// ─── Swap exercise modal ──────────────────────────────────────────────────────
// Pick a replacement for one exercise. Exercises sharing a primary muscle group
// are surfaced first (and tagged "Similar"); the rest follow alphabetically.

function SwapExerciseModal({ current, existingIds, onSelect, onClose }: {
  current: SessionExerciseResponse;
  existingIds: number[];
  onSelect: (exerciseId: number) => void;
  onClose: () => void;
}) {
  const [search, setSearch] = useState('');
  const { data: allExercises } = useQuery({
    queryKey: ['exercises'],
    queryFn: exercisesApi.list,
  });

  const currentPrimary = new Set(
    current.exercise.muscles.filter((m) => m.role === 'PRIMARY').map((m) => m.muscleGroupId)
  );
  const sharesPrimary = (ex: { muscles: SessionExerciseResponse['exercise']['muscles'] }) =>
    ex.muscles.some((m) => m.role === 'PRIMARY' && currentPrimary.has(m.muscleGroupId));

  const q = search.toLowerCase();
  const candidates = (allExercises ?? []).filter(
    (e) => e.id !== current.exercise.id &&
      !existingIds.includes(e.id) &&
      e.name.toLowerCase().includes(q)
  );
  const sorted = [...candidates].sort((a, b) => {
    const rank = (Number(!sharesPrimary(a))) - (Number(!sharesPrimary(b)));
    return rank !== 0 ? rank : a.name.localeCompare(b.name);
  });

  return (
    <Modal visible animationType="slide" presentationStyle="pageSheet" onRequestClose={onClose}>
      <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surface }}>
        <View style={{ flexDirection: 'row', alignItems: 'center',
          padding: Spacing.md, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
          <TouchableOpacity onPress={onClose} style={{ padding: 4, marginRight: Spacing.sm }}>
            <Ionicons name="close" size={22} color={Colors.textPrimary} />
          </TouchableOpacity>
          <View style={{ flex: 1 }}>
            <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
              color: Colors.textPrimary }}>Swap exercise</Text>
            <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary }}>
              Replacing {current.exercise.name} · this workout only
            </Text>
          </View>
        </View>
        <View style={{ paddingHorizontal: Spacing.md, paddingVertical: Spacing.sm }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8,
            backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
            paddingHorizontal: 12, borderWidth: 1, borderColor: Colors.border }}>
            <Ionicons name="search" size={16} color={Colors.textMuted} />
            <TextInput value={search} onChangeText={setSearch}
              placeholder="Search exercises…" placeholderTextColor={Colors.textMuted}
              style={{ flex: 1, paddingVertical: 10, fontSize: FontSize.md,
                color: Colors.textPrimary }} />
          </View>
        </View>
        <ScrollView>
          {sorted.map((ex) => {
            const similar = sharesPrimary(ex);
            return (
              <TouchableOpacity key={ex.id}
                onPress={() => onSelect(ex.id)}
                style={{ flexDirection: 'row', alignItems: 'center',
                  padding: Spacing.md, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
                <View style={{ flex: 1 }}>
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                    <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary,
                      fontWeight: FontWeight.medium }}>{ex.name}</Text>
                    {similar && (
                      <View style={{ backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
                        paddingHorizontal: 8, paddingVertical: 2 }}>
                        <Text style={{ fontSize: 10, color: Colors.primary,
                          fontWeight: FontWeight.semibold }}>Similar</Text>
                      </View>
                    )}
                  </View>
                  <MuscleChips muscles={ex.muscles} />
                </View>
                <Ionicons name="swap-horizontal" size={20} color={Colors.primary} />
              </TouchableOpacity>
            );
          })}
          {sorted.length === 0 && (
            <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
              textAlign: 'center', marginTop: Spacing.lg }}>No exercises found.</Text>
          )}
        </ScrollView>
      </SafeAreaView>
    </Modal>
  );
}

// ─── Workout summary overlay ──────────────────────────────────────────────────

function WorkoutSummaryOverlay({ summary, onDismiss }: {
  summary: WorkoutSummary;
  onDismiss: () => void;
}) {
  return (
    <Modal visible transparent animationType="fade">
      <TouchableOpacity style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.6)',
        justifyContent: 'center', alignItems: 'center', padding: Spacing.xl }}
        activeOpacity={1} onPress={onDismiss}>
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          padding: Spacing.xl, width: '100%', ...Shadow.float }}>
          {/* Trophy */}
          <View style={{ alignItems: 'center', marginBottom: Spacing.lg }}>
            <View style={{ width: 72, height: 72, borderRadius: 36,
              backgroundColor: Colors.successTint, alignItems: 'center',
              justifyContent: 'center', marginBottom: Spacing.md }}>
              <Ionicons name="trophy-outline" size={36} color={Colors.success} />
            </View>
            <Text style={{ fontSize: FontSize.xxl, fontWeight: FontWeight.bold,
              color: Colors.textPrimary }}>Workout Complete!</Text>
          </View>

          {/* Stats row */}
          <View style={{ flexDirection: 'row', justifyContent: 'space-around',
            marginBottom: Spacing.lg }}>
            <StatPill label="Duration" value={`${summary.duration}m`} icon="time-outline" />
            <StatPill label="Sets" value={String(summary.totalSets)} icon="layers-outline" />
            <StatPill label="Volume" value={`${summary.totalVolume}kg`} icon="barbell-outline" />
          </View>

          {/* Exercises — with how each one compared to last time */}
          {summary.exercises.length > 0 && (
            <View style={{ backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
              padding: Spacing.md, marginBottom: Spacing.lg }}>
              {summary.exercises.slice(0, 5).map((e) => {
                const t = e.trend ? trendStyle(e.trend.direction) : null;
                return (
                  <View key={e.name} style={{ flexDirection: 'row', alignItems: 'center',
                    gap: 8, marginBottom: 4 }}>
                    <Ionicons name="checkmark-circle" size={14} color={Colors.success} />
                    <Text style={{ flex: 1, fontSize: FontSize.sm,
                      color: Colors.textPrimary }}>{e.name}</Text>
                    {t && e.trend && (
                      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 3 }}>
                        <Ionicons name={t.icon} size={12} color={t.color} />
                        <Text style={{ fontSize: FontSize.xs, color: t.color,
                          fontWeight: FontWeight.medium }}>{e.trend.headline}</Text>
                      </View>
                    )}
                  </View>
                );
              })}
              {summary.exercises.length > 5 && (
                <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 2 }}>
                  +{summary.exercises.length - 5} more
                </Text>
              )}
            </View>
          )}

          <TouchableOpacity onPress={onDismiss}
            style={{ backgroundColor: Colors.success, borderRadius: Radius.md,
              paddingVertical: 14, alignItems: 'center' }}>
            <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.bold,
              fontSize: FontSize.md }}>Back to Home</Text>
          </TouchableOpacity>
        </View>
      </TouchableOpacity>
    </Modal>
  );
}

function StatPill({ label, value, icon }: { label: string; value: string; icon: string }) {
  return (
    <View style={{ alignItems: 'center' }}>
      <View style={{ width: 48, height: 48, borderRadius: 24,
        backgroundColor: Colors.primaryTint, alignItems: 'center',
        justifyContent: 'center', marginBottom: 4 }}>
        <Ionicons name={icon as any} size={20} color={Colors.primary} />
      </View>
      <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
        color: Colors.textPrimary }}>{value}</Text>
      <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>{label}</Text>
    </View>
  );
}
