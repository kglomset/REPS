import React, { useState, useEffect } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity,
  ActivityIndicator, Alert, TextInput, Modal,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { programsApi } from '@/services/api/programs';
import { workoutsApi } from '@/services/api/workouts';
import { exercisesApi } from '@/services/api/exercises';
import { FitnessLevel, TrainingGoal, TrainingMethod, ExerciseResponse } from '@/types';
import {
  weeklyVolume, describeVolume, MuscleVolume, EMPTY_VOLUME,
} from '@/utils/volume';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';

// ─── Types ────────────────────────────────────────────────────────────────────

// 'guided' is not in here: it routes to its own screen (app/program/guided.tsx)
// rather than rendering inside this one.
type Mode = 'diy' | 'standalone';
interface DiyExercise {
  exercise: ExerciseResponse;
  sets: number;
  reps: number;
  method: TrainingMethod;
  supersetGroupId?: string | null;
}

interface DiyDay {
  name: string;
  dayIndex: number;
  templateId?: number;
  exercises: DiyExercise[];
}

// Evidence-based weekly set ranges per muscle group, by training status
const WEEKLY_SETS_GUIDE: Record<FitnessLevel, Array<{ muscle: string; min: number; max: number }>> = {
  BEGINNER: [
    { muscle: 'Chest',       min: 6,  max: 10 },
    { muscle: 'Back',        min: 6,  max: 10 },
    { muscle: 'Shoulders',   min: 6,  max: 8  },
    { muscle: 'Quadriceps',  min: 6,  max: 10 },
    { muscle: 'Hamstrings',  min: 4,  max: 8  },
    { muscle: 'Glutes',      min: 4,  max: 8  },
    { muscle: 'Biceps',      min: 4,  max: 8  },
    { muscle: 'Triceps',     min: 4,  max: 8  },
    { muscle: 'Abs',         min: 4,  max: 8  },
    { muscle: 'Calves',      min: 4,  max: 8  },
  ],
  INTERMEDIATE: [
    { muscle: 'Chest',       min: 10, max: 14 },
    { muscle: 'Back',        min: 10, max: 14 },
    { muscle: 'Shoulders',   min: 8,  max: 12 },
    { muscle: 'Quadriceps',  min: 10, max: 14 },
    { muscle: 'Hamstrings',  min: 8,  max: 12 },
    { muscle: 'Glutes',      min: 6,  max: 10 },
    { muscle: 'Biceps',      min: 8,  max: 12 },
    { muscle: 'Triceps',     min: 8,  max: 12 },
    { muscle: 'Abs',         min: 6,  max: 10 },
    { muscle: 'Calves',      min: 6,  max: 10 },
  ],
  ADVANCED: [
    { muscle: 'Chest',       min: 14, max: 20 },
    { muscle: 'Back',        min: 14, max: 20 },
    { muscle: 'Shoulders',   min: 12, max: 16 },
    { muscle: 'Quadriceps',  min: 14, max: 20 },
    { muscle: 'Hamstrings',  min: 12, max: 16 },
    { muscle: 'Glutes',      min: 8,  max: 12 },
    { muscle: 'Biceps',      min: 12, max: 16 },
    { muscle: 'Triceps',     min: 12, max: 16 },
    { muscle: 'Abs',         min: 8,  max: 12 },
    { muscle: 'Calves',      min: 8,  max: 12 },
  ],
};

/**
 * Granular DB muscle groups rolled up into the aggregates shown in the
 * volume guide. Tapping an aggregate row reveals the per-muscle breakdown.
 */
const ROLLUP_PARTS: Record<string, string[]> = {
  Shoulders: ['Front Delts', 'Side Delts', 'Rear Delts', 'Traps'],
  Back:      ['Upper Back', 'Lats', 'Lower Back'],
  Abs:       ['Abdominals', 'Obliques'],
};

/**
 * How an aggregate's headline number is derived from its parts:
 * 'max' shows the most-trained sub-muscle (summing per-head sets would
 * overstate volume against the target range), 'sum' adds them up.
 */
const AGGREGATE_DISPLAY: Record<string, 'sum' | 'max'> = {
  Shoulders: 'max',
  Back:      'max',
  Abs:       'sum',
};

// ─── Root screen: mode picker ─────────────────────────────────────────────────

export default function ProgramSetupScreen() {
  const { edit } = useLocalSearchParams<{ edit?: string }>();
  const [mode, setMode] = useState<Mode | null>(null);

  if (edit) return <DiyBuilder editProgramId={Number(edit)} />;
  if (!mode) return <ModePicker onSelect={setMode} />;
  if (mode === 'standalone') return <StandaloneBuilder />;
  return <DiyBuilder />;
}

// ─── Mode picker ──────────────────────────────────────────────────────────────

function ModePicker({ onSelect }: { onSelect: (m: Mode) => void }) {
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surface }}>
      <View style={{ flexDirection: 'row', alignItems: 'center',
        padding: Spacing.md, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
        <TouchableOpacity onPress={() => router.back()} style={{ padding: 4, marginRight: Spacing.sm }}>
          <Ionicons name="chevron-back" size={24} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
          color: Colors.textPrimary }}>New Program</Text>
      </View>
      <ScrollView contentContainerStyle={{ padding: Spacing.lg }}>
        <Text style={{ fontSize: FontSize.xxl, fontWeight: FontWeight.bold,
          color: Colors.textPrimary, marginBottom: 6 }}>How do you want to start?</Text>
        <Text style={{ fontSize: FontSize.md, color: Colors.textSecondary,
          marginBottom: Spacing.xl }}>
          Be walked through the decisions that shape a program, or lay one out
          yourself.
        </Text>

        <TouchableOpacity onPress={() => router.push('/program/guided')}
          style={{ borderRadius: Radius.xl, padding: Spacing.lg, marginBottom: Spacing.md,
            backgroundColor: Colors.primary, ...Shadow.float }}>
          <View style={{ width: 44, height: 44, borderRadius: 22,
            backgroundColor: 'rgba(255,255,255,0.2)', alignItems: 'center',
            justifyContent: 'center', marginBottom: Spacing.md }}>
            <Ionicons name="compass-outline" size={22} color={Colors.textInverse} />
          </View>
          <Text style={{ fontSize: FontSize.xl, fontWeight: FontWeight.bold,
            color: Colors.textInverse }}>Guide me through it</Text>
          <Text style={{ fontSize: FontSize.sm, color: Colors.primaryLight, marginTop: 4 }}>
            Set your goal, how much volume you want and how many days you can
            train. Each step explains what it changes, and you edit the result
            before anything is saved.
          </Text>
          <View style={{ flexDirection: 'row', alignItems: 'center', flexWrap: 'wrap',
            gap: 6, marginTop: Spacing.md }}>
            {['Goal', 'Volume', 'Days', 'Split', 'Exercises'].map((s, i) => (
              <React.Fragment key={s}>
                <View style={{ backgroundColor: 'rgba(255,255,255,0.15)',
                  borderRadius: Radius.full, paddingHorizontal: 8, paddingVertical: 3 }}>
                  <Text style={{ fontSize: 10, color: Colors.textInverse }}>{s}</Text>
                </View>
                {i < 4 && <Ionicons name="arrow-forward" size={10} color={Colors.primaryLight} />}
              </React.Fragment>
            ))}
          </View>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => onSelect('diy')}
          style={{ borderRadius: Radius.xl, padding: Spacing.lg, marginBottom: Spacing.md,
            backgroundColor: Colors.surface, borderWidth: 2, borderColor: Colors.primary,
            ...Shadow.card }}>
          <View style={{ width: 44, height: 44, borderRadius: 22,
            backgroundColor: Colors.primaryTint, alignItems: 'center',
            justifyContent: 'center', marginBottom: Spacing.md }}>
            <Ionicons name="construct-outline" size={22} color={Colors.primary} />
          </View>
          <Text style={{ fontSize: FontSize.xl, fontWeight: FontWeight.bold,
            color: Colors.textPrimary }}>Build it myself</Text>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 4 }}>
            Pick your own days, exercises and structure from an empty page.
          </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => onSelect('standalone')}
          style={{ borderRadius: Radius.xl, padding: Spacing.lg,
            backgroundColor: Colors.surface, borderWidth: 1, borderColor: Colors.border,
            ...Shadow.card }}>
          <View style={{ width: 44, height: 44, borderRadius: 22,
            backgroundColor: Colors.surfaceMuted, alignItems: 'center',
            justifyContent: 'center', marginBottom: Spacing.md }}>
            <Ionicons name="flash-outline" size={22} color={Colors.textSecondary} />
          </View>
          <Text style={{ fontSize: FontSize.xl, fontWeight: FontWeight.bold,
            color: Colors.textPrimary }}>Standalone Session</Text>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 4 }}>
            A one-off workout — no days, no calendar. Ideal for travelling or when
            you can't follow your program.
          </Text>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}

// ─── DIY builder ──────────────────────────────────────────────────────────────

const DAY_NAMES_MAP = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const DEFAULT_DAY_INDICES = [0, 1, 3, 4]; // Mon/Tue/Thu/Fri

// Rep range references shown as hints (not editable)
const REP_RANGE_HINT: Record<TrainingGoal, string> = {
  STRENGTH: '3–6',
  HYPERTROPHY: '8–12',
};

function defaultSetsReps(goal: TrainingGoal): { sets: number; reps: number } {
  return goal === 'STRENGTH'
    ? { sets: 5, reps: 4 }
    : { sets: 3, reps: 10 };
}

function DiyBuilder({ editProgramId }: { editProgramId?: number }) {
  const queryClient = useQueryClient();
  const [programName, setProgramName]           = useState('My Program');
  const [fitnessLevel, setFitnessLevel]         = useState<FitnessLevel>('INTERMEDIATE');
  const [goal, setGoal]                         = useState<TrainingGoal>('HYPERTROPHY');
  const [days, setDays]                         = useState<DiyDay[]>(
    DEFAULT_DAY_INDICES.map((idx) => ({
      name: `Day ${idx + 1}`,
      dayIndex: idx,
      exercises: [],
    }))
  );
  const [editingDayIdx, setEditingDayIdx] = useState<number | null>(null);
  const [exSearch, setExSearch]           = useState('');
  const [guideOpen, setGuideOpen]         = useState(true);

  const { data: allExercises } = useQuery({
    queryKey: ['exercises'],
    queryFn: exercisesApi.list,
  });

  const { mutate: create, isPending } = useMutation({
    mutationFn: () => programsApi.create({
      name: programName,
      fitnessLevel,
      goal,
      strengthDaysPerWeek: days.length,
      cardioDaysPerWeek: 0,
      days: days.map((d) => ({
        name: d.name,
        dayIndex: d.dayIndex,
        exercises: d.exercises.map((e) => ({
          exerciseId: e.exercise.id,
          sets: e.sets,
          reps: e.reps,
          trainingMethod: e.method,
          supersetGroupId: e.supersetGroupId ?? null,
        })),
      })),
    }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['activeProgram'] });
      queryClient.invalidateQueries({ queryKey: ['programs'] });
      router.replace('/(tabs)/');
    },
    onError: (e: Error) => Alert.alert('Error', e.message),
  });

  const isEdit = editProgramId != null;
  const [initialized, setInitialized] = useState(false);

  const { data: fetchedProgram } = useQuery({
    queryKey: ['program', editProgramId],
    queryFn: () => programsApi.get(editProgramId as number),
    enabled: isEdit,
  });
  // The active program is already loaded with its exercises on other screens;
  // use it as a reliable source when editing it, falling back to fetch-by-id.
  const { data: activeProgram } = useQuery({
    queryKey: ['activeProgram'],
    queryFn: programsApi.getActive,
    enabled: isEdit,
  });
  const editProgram = !isEdit
    ? undefined
    : (fetchedProgram && fetchedProgram.workoutTemplates?.length
        ? fetchedProgram
        : (activeProgram && activeProgram.id === editProgramId ? activeProgram : fetchedProgram));

  useEffect(() => {
    if (!isEdit || !editProgram || initialized) return;
    setProgramName(editProgram.name);
    setFitnessLevel(editProgram.fitnessLevel);
    setGoal(editProgram.goal);
    setDays(
      [...editProgram.workoutTemplates]
        .sort((a, b) => a.dayIndex - b.dayIndex)
        .map((t) => ({
          name: t.name,
          dayIndex: t.dayIndex,
          templateId: t.id,
          exercises: t.exercises
            .slice()
            .sort((a, b) => a.exerciseOrder - b.exerciseOrder)
            .map((te) => ({
              exercise: te.exercise,
              sets: te.sets,
              reps: te.repsMin ?? 10,
              method: te.trainingMethod,
              supersetGroupId: te.supersetGroupId ?? null,
            })),
        }))
    );
    setInitialized(true);
  }, [isEdit, editProgram, initialized]);

  const { mutate: saveEdit, isPending: isSaving } = useMutation({
    mutationFn: () => programsApi.updateStructure(editProgramId as number, {
      name: programName,
      days: days.map((d) => ({
        templateId: d.templateId,
        name: d.name,
        dayIndex: d.dayIndex,
        exercises: d.exercises.map((e) => ({
          exerciseId: e.exercise.id,
          sets: e.sets,
          reps: e.reps,
          trainingMethod: e.method,
          supersetGroupId: e.supersetGroupId ?? null,
        })),
      })),
    }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['activeProgram'] });
      queryClient.invalidateQueries({ queryKey: ['programs'] });
      queryClient.invalidateQueries({ queryKey: ['program', editProgramId] });
      router.back();
    },
    onError: (e: Error) => Alert.alert('Error', e.message),
  });

  const toggleDay = (idx: number) => {
    setDays((prev) => {
      const has = prev.some((d) => d.dayIndex === idx);
      if (has) return prev.filter((d) => d.dayIndex !== idx);
      return [...prev, { name: DAY_NAMES_MAP[idx], dayIndex: idx, exercises: [] }]
        .sort((a, b) => a.dayIndex - b.dayIndex);
    });
  };

  const renameDay = (dayIndex: number, name: string) => {
    setDays((prev) => prev.map((d) => (d.dayIndex === dayIndex ? { ...d, name } : d)));
  };

  /** Move a workout to another weekday (no-op if the target day is taken). */
  const moveDayIndex = (from: number, to: number) => {
    setDays((prev) => {
      if (from === to || prev.some((d) => d.dayIndex === to)) return prev;
      return prev
        .map((d) => (d.dayIndex === from ? { ...d, dayIndex: to } : d))
        .sort((a, b) => a.dayIndex - b.dayIndex);
    });
    setEditingDayIdx((cur) => (cur === from ? to : cur));
  };

  const addExercise = (dayIndex: number, ex: ExerciseResponse) => {
    setDays((prev) =>
      prev.map((d) =>
        d.dayIndex === dayIndex && !d.exercises.find((e) => e.exercise.id === ex.id)
          ? { ...d, exercises: [...d.exercises, { exercise: ex, ...defaultSetsReps(goal), method: 'STRAIGHT_SETS' }] }
          : d
      )
    );
  };

  const removeExercise = (dayIndex: number, exId: number) => {
    setDays((prev) =>
      prev.map((d) =>
        d.dayIndex === dayIndex
          ? { ...d, exercises: d.exercises.filter((e) => e.exercise.id !== exId) }
          : d
      )
    );
  };

  const updateExerciseParam = (
    dayIndex: number,
    exId: number,
    patch: Partial<Pick<DiyExercise, 'sets' | 'reps' | 'method'>>
  ) => {
    setDays((prev) =>
      prev.map((d) =>
        d.dayIndex === dayIndex
          ? {
              ...d,
              exercises: d.exercises.map((e) =>
                e.exercise.id === exId ? { ...e, ...patch } : e
              ),
            }
          : d
      )
    );
  };

  const moveExercise = (dayIndex: number, idx: number, dir: -1 | 1) => {
    setDays((prev) =>
      prev.map((d) => {
        if (d.dayIndex !== dayIndex) return d;
        const arr = [...d.exercises];
        const j = idx + dir;
        if (j < 0 || j >= arr.length) return d;
        [arr[idx], arr[j]] = [arr[j], arr[idx]];
        return { ...d, exercises: arr };
      })
    );
  };

  const filtered = (allExercises ?? []).filter((e) =>
    e.name.toLowerCase().includes(exSearch.toLowerCase())
  );

  // Weekly sets per muscle across all days, on the same rules the guided
  // builder and the backend allocator use: a primary muscle banks the full
  // set, a secondary banks half, and a myo-reps exercise counts as 3.
  const currentVolume = weeklyVolume(
    days.flatMap((day) => day.exercises.map((de) => ({
      muscles: de.exercise.muscles,
      method: de.method,
      sets: de.sets,
    })))
  );

  const editingDay = editingDayIdx !== null
    ? days.find((d) => d.dayIndex === editingDayIdx) : null;

  // ── Day exercise editor ─────────────────────────────────────────────────────
  if (editingDay) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surface }}>
        {/* Header */}
        <View style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md,
          borderBottomWidth: 1, borderBottomColor: Colors.border }}>
          <TouchableOpacity onPress={() => { setEditingDayIdx(null); setExSearch(''); }}
            style={{ padding: 4, marginRight: Spacing.sm }}>
            <Ionicons name="chevron-back" size={24} color={Colors.textPrimary} />
          </TouchableOpacity>
          <Text style={{ flex: 1, fontSize: FontSize.md, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>{editingDay.name}</Text>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
            {editingDay.exercises.length} selected
          </Text>
        </View>

        {/* One scroll for the whole editor: selected list never overlaps the add list */}
        <ScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingBottom: 40 }}
          keyboardShouldPersistTaps="handled">
          {/* Workout name + weekday */}
          <View style={{ paddingHorizontal: Spacing.lg, paddingTop: Spacing.md,
            paddingBottom: Spacing.md, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
            <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted,
              fontWeight: FontWeight.medium, marginBottom: 6 }}>WORKOUT NAME</Text>
            <TextInput
              value={editingDay.name}
              onChangeText={(v) => renameDay(editingDay.dayIndex, v)}
              placeholder="e.g. Push, Upper A"
              placeholderTextColor={Colors.textMuted}
              style={{ backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
                paddingHorizontal: Spacing.md, paddingVertical: 10,
                fontSize: FontSize.md, color: Colors.textPrimary,
                borderWidth: 1, borderColor: Colors.border, marginBottom: Spacing.md }}
            />
            <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted,
              fontWeight: FontWeight.medium, marginBottom: 6 }}>DAY</Text>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
              {DAY_NAMES_MAP.map((dn, idx) => {
                const current  = idx === editingDay.dayIndex;
                const occupied = !current && days.some((d) => d.dayIndex === idx);
                return (
                  <TouchableOpacity key={idx}
                    disabled={current || occupied}
                    onPress={() => moveDayIndex(editingDay.dayIndex, idx)}
                    style={{ width: 40, height: 40, borderRadius: 20,
                      alignItems: 'center', justifyContent: 'center',
                      opacity: occupied ? 0.35 : 1,
                      backgroundColor: current ? Colors.primary : Colors.surfaceMuted,
                      borderWidth: 1,
                      borderColor: current ? Colors.primary : Colors.border }}>
                    <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.bold,
                      color: current ? Colors.textInverse : Colors.textSecondary }}>{dn}</Text>
                  </TouchableOpacity>
                );
              })}
            </View>
            <Text style={{ fontSize: 10, color: Colors.textMuted, marginTop: 6 }}>
              Greyed-out days already have a workout.
            </Text>
          </View>

          {/* Selected exercises */}
          {editingDay.exercises.length > 0 && (
            <View style={{ borderBottomWidth: 1, borderBottomColor: Colors.border }}>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted,
                fontWeight: FontWeight.medium, paddingHorizontal: Spacing.lg,
                paddingTop: Spacing.md, paddingBottom: 6 }}>
                SELECTED EXERCISES
              </Text>
              {editingDay.exercises.map((de, idx) => (
                <View key={de.exercise.id} style={{
                  paddingHorizontal: Spacing.lg, paddingVertical: 10,
                  borderTopWidth: 1, borderTopColor: Colors.border,
                  backgroundColor: Colors.surface,
                }}>
                  {/* Exercise name + reorder (up/down) + remove */}
                  <View style={{ flexDirection: 'row', alignItems: 'center',
                    justifyContent: 'space-between', marginBottom: 6 }}>
                    <View style={{ flexDirection: 'row', alignItems: 'center', marginRight: 6 }}>
                      <TouchableOpacity
                        disabled={idx === 0}
                        onPress={() => moveExercise(editingDay.dayIndex, idx, -1)}
                        hitSlop={{ top: 6, bottom: 6, left: 4, right: 4 }}
                        style={{ paddingHorizontal: 1, opacity: idx === 0 ? 0.25 : 1 }}>
                        <Ionicons name="chevron-up" size={18} color={Colors.textMuted} />
                      </TouchableOpacity>
                      <TouchableOpacity
                        disabled={idx === editingDay.exercises.length - 1}
                        onPress={() => moveExercise(editingDay.dayIndex, idx, 1)}
                        hitSlop={{ top: 6, bottom: 6, left: 4, right: 4 }}
                        style={{ paddingHorizontal: 1,
                          opacity: idx === editingDay.exercises.length - 1 ? 0.25 : 1 }}>
                        <Ionicons name="chevron-down" size={18} color={Colors.textMuted} />
                      </TouchableOpacity>
                    </View>
                    <View style={{ flex: 1, marginRight: Spacing.sm }}>
                      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                        <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
                          color: Colors.textPrimary }}>{de.exercise.name}</Text>
                        <GroupBadge items={editingDay.exercises} groupId={de.supersetGroupId} />
                      </View>
                      <Text style={{ fontSize: 10, color: Colors.textMuted, marginTop: 1 }}>
                        {de.exercise.muscles.filter((m) => m.role === 'PRIMARY')
                          .map((m) => m.muscleGroupName).join(', ')}
                      </Text>
                    </View>
                    <GroupControls
                      items={editingDay.exercises}
                      exId={de.exercise.id}
                      onChange={(next) => setDays((prev) => prev.map((d) =>
                        d.dayIndex === editingDay.dayIndex ? { ...d, exercises: next } : d))}
                    />
                    <TouchableOpacity
                      onPress={() => removeExercise(editingDay.dayIndex, de.exercise.id)}
                      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                      style={{ marginLeft: 4 }}>
                      <Ionicons name="close-circle-outline" size={20} color={Colors.textMuted} />
                    </TouchableOpacity>
                  </View>

                  {/* Sets + Reps controls */}
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.lg }}>
                    {/* Sets stepper */}
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                      <Text style={{ fontSize: 10, color: Colors.textMuted,
                        fontWeight: FontWeight.medium }}>SETS</Text>
                      <TouchableOpacity
                        onPress={() => updateExerciseParam(editingDay.dayIndex, de.exercise.id,
                          { sets: Math.max(1, de.sets - 1) })}>
                        <Ionicons name="remove-circle-outline" size={22} color={Colors.primary} />
                      </TouchableOpacity>
                      <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.bold,
                        color: Colors.textPrimary, minWidth: 18, textAlign: 'center' }}>
                        {de.sets}
                      </Text>
                      <TouchableOpacity
                        onPress={() => updateExerciseParam(editingDay.dayIndex, de.exercise.id,
                          { sets: Math.min(10, de.sets + 1) })}>
                        <Ionicons name="add-circle-outline" size={22} color={Colors.primary} />
                      </TouchableOpacity>
                    </View>

                    {/* Reps input */}
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                      <Text style={{ fontSize: 10, color: Colors.textMuted,
                        fontWeight: FontWeight.medium }}>REPS</Text>
                      <TextInput
                        value={String(de.reps)}
                        onChangeText={(v) => {
                          const n = parseInt(v, 10);
                          if (!isNaN(n) && n > 0 && n <= 50) {
                            updateExerciseParam(editingDay.dayIndex, de.exercise.id, { reps: n });
                          }
                        }}
                        keyboardType="number-pad"
                        style={{
                          width: 44, height: 30, backgroundColor: Colors.surfaceMuted,
                          borderRadius: Radius.sm, textAlign: 'center',
                          fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
                          color: Colors.textPrimary, borderWidth: 1, borderColor: Colors.border,
                        }}
                      />
                      <Text style={{ fontSize: 10, color: Colors.textMuted }}>
                        rec {REP_RANGE_HINT[goal]}
                      </Text>
                    </View>

                    {/* Preview */}
                    <View style={{ backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
                      paddingHorizontal: 10, paddingVertical: 3 }}>
                      <Text style={{ fontSize: 10, color: Colors.primary,
                        fontWeight: FontWeight.semibold }}>
                        {de.sets} × {de.reps}
                      </Text>
                    </View>
                  </View>

                  {/* Per-exercise training method */}
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 8 }}>
                    <Text style={{ fontSize: 10, color: Colors.textMuted,
                      fontWeight: FontWeight.medium }}>METHOD</Text>
                    {([
                      { value: 'STRAIGHT_SETS', label: 'Straight' },
                      { value: 'MYOREPS',       label: 'Myo-reps' },
                    ] as { value: TrainingMethod; label: string }[]).map(({ value, label }) => {
                      const active = de.method === value;
                      return (
                        <TouchableOpacity key={value}
                          onPress={() => updateExerciseParam(editingDay.dayIndex, de.exercise.id, { method: value })}
                          style={{ paddingHorizontal: 10, paddingVertical: 4, borderRadius: Radius.full,
                            backgroundColor: active ? Colors.primary : Colors.surfaceMuted,
                            borderWidth: 1, borderColor: active ? Colors.primary : Colors.border }}>
                          <Text style={{ fontSize: 10, fontWeight: FontWeight.semibold,
                            color: active ? Colors.textInverse : Colors.textSecondary }}>{label}</Text>
                        </TouchableOpacity>
                      );
                    })}
                  </View>
                </View>
              ))}
            </View>
          )}

          {/* Exercise search */}
          <View style={{ paddingHorizontal: Spacing.md, paddingTop: Spacing.md,
            paddingBottom: Spacing.sm }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8,
              backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md, paddingHorizontal: 12,
              borderWidth: 1, borderColor: Colors.border }}>
              <Ionicons name="search" size={16} color={Colors.textMuted} />
              <TextInput value={exSearch} onChangeText={setExSearch}
                placeholder="Search exercises to add…" placeholderTextColor={Colors.textMuted}
                style={{ flex: 1, paddingVertical: 10, fontSize: FontSize.md,
                  color: Colors.textPrimary }} />
            </View>
          </View>

          {/* Add list */}
          {filtered.map((ex) => {
            const added = editingDay.exercises.some((e) => e.exercise.id === ex.id);
            return (
              <TouchableOpacity key={ex.id}
                onPress={() => added
                  ? removeExercise(editingDay.dayIndex, ex.id)
                  : addExercise(editingDay.dayIndex, ex)}
                style={{ flexDirection: 'row', alignItems: 'center',
                  paddingVertical: 12, paddingHorizontal: Spacing.lg,
                  borderBottomWidth: 1, borderBottomColor: Colors.border,
                  backgroundColor: added ? Colors.primaryTint : 'transparent' }}>
                <View style={{ flex: 1 }}>
                  <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary,
                    fontWeight: FontWeight.medium }}>{ex.name}</Text>
                  <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 2 }}>
                    {ex.muscles.filter((m) => m.role === 'PRIMARY')
                      .map((m) => m.muscleGroupName).join(', ')}
                  </Text>
                </View>
                <Ionicons
                  name={added ? 'checkmark-circle' : 'add-circle-outline'}
                  size={22} color={added ? Colors.primary : Colors.textMuted} />
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </SafeAreaView>
    );
  }

  // ── Main builder view ───────────────────────────────────────────────────────
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surface }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md,
        borderBottomWidth: 1, borderBottomColor: Colors.border }}>
        <TouchableOpacity onPress={() => router.back()}
          style={{ padding: 4, marginRight: Spacing.sm }}>
          <Ionicons name="chevron-back" size={24} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
          color: Colors.textPrimary }}>{isEdit ? 'Edit Program' : 'Build from Scratch'}</Text>
      </View>

      <ScrollView contentContainerStyle={{ padding: Spacing.lg, paddingBottom: 120 }}>
        {/* Program name */}
        <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
          fontWeight: FontWeight.medium, marginBottom: 6 }}>Program Name</Text>
        <TextInput value={programName} onChangeText={setProgramName}
          style={{ backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
            paddingHorizontal: Spacing.md, paddingVertical: 12,
            fontSize: FontSize.lg, color: Colors.textPrimary,
            borderWidth: 1, borderColor: Colors.border, marginBottom: Spacing.lg }} />

        {!isEdit && (<>
        {/* Level */}
        <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
          fontWeight: FontWeight.medium, marginBottom: 8 }}>Fitness Level</Text>
        <View style={{ flexDirection: 'row', gap: 8, marginBottom: Spacing.lg }}>
          {(['BEGINNER', 'INTERMEDIATE', 'ADVANCED'] as FitnessLevel[]).map((l) => (
            <TouchableOpacity key={l} onPress={() => setFitnessLevel(l)}
              style={{ flex: 1, paddingVertical: 10, alignItems: 'center', borderRadius: Radius.md,
                backgroundColor: fitnessLevel === l ? Colors.primary : Colors.surfaceMuted,
                borderWidth: 1, borderColor: fitnessLevel === l ? Colors.primary : Colors.border }}>
              <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.semibold,
                color: fitnessLevel === l ? Colors.textInverse : Colors.textSecondary }}>
                {l.charAt(0) + l.slice(1).toLowerCase()}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

          </>)}

        {/* Training days — also editable for existing programs (add/remove workout days) */}
        <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
          fontWeight: FontWeight.medium, marginBottom: 8 }}>Training Days</Text>
        <View style={{ flexDirection: 'row', justifyContent: 'space-between',
          marginBottom: Spacing.lg }}>
          {DAY_NAMES_MAP.map((name, idx) => {
            const active = days.some((d) => d.dayIndex === idx);
            return (
              <TouchableOpacity key={idx} onPress={() => toggleDay(idx)}
                style={{ width: 40, height: 40, borderRadius: 20,
                  alignItems: 'center', justifyContent: 'center',
                  backgroundColor: active ? Colors.primary : Colors.surfaceMuted,
                  borderWidth: 1, borderColor: active ? Colors.primary : Colors.border }}>
                <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.bold,
                  color: active ? Colors.textInverse : Colors.textSecondary }}>{name}</Text>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Day tiles */}
        {days.map((day) => (
          <TouchableOpacity key={day.dayIndex}
            onPress={() => { setEditingDayIdx(day.dayIndex); setExSearch(''); }}
            style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
              padding: Spacing.md, marginBottom: Spacing.sm, ...Shadow.card,
              flexDirection: 'row', alignItems: 'center' }}>
            <View style={{ width: 36, height: 36, borderRadius: 18,
              backgroundColor: Colors.primaryTint, alignItems: 'center',
              justifyContent: 'center', marginRight: Spacing.md }}>
              <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.bold,
                color: Colors.primary }}>{DAY_NAMES_MAP[day.dayIndex]}</Text>
            </View>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
                color: Colors.textPrimary }}>{day.name}</Text>
              {day.exercises.length === 0 ? (
                <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
                  Tap to add exercises
                </Text>
              ) : (
                <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
                  {day.exercises.map((e) => `${e.exercise.name} (${e.sets}×${e.reps})`).join(' · ')}
                </Text>
              )}
            </View>
            <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
          </TouchableOpacity>
        ))}

        {/* Weekly volume guidelines */}
        <VolumeGuide
          fitnessLevel={fitnessLevel}
          currentVolume={currentVolume}
          open={guideOpen}
          onToggle={() => setGuideOpen((v) => !v)}
        />
      </ScrollView>

      <View style={{ position: 'absolute', bottom: 0, left: 0, right: 0,
        backgroundColor: Colors.surface, padding: Spacing.lg,
        borderTopWidth: 1, borderTopColor: Colors.border }}>
        <TouchableOpacity onPress={() => (isEdit ? saveEdit() : create())}
          disabled={isPending || isSaving || days.length === 0}
          style={{ backgroundColor: Colors.primary, borderRadius: Radius.md,
            paddingVertical: 16, alignItems: 'center',
            opacity: isPending || isSaving || days.length === 0 ? 0.6 : 1 }}>
          {(isPending || isSaving)
            ? <ActivityIndicator color={Colors.textInverse} />
            : <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                fontSize: FontSize.md }}>{isEdit ? 'Save Changes →' : 'Create Program →'}</Text>}
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

// ─── Weekly volume guidelines panel ──────────────────────────────────────────

function VolumeGuide({ fitnessLevel, currentVolume, open, onToggle }: {
  fitnessLevel: FitnessLevel;
  currentVolume: Record<string, MuscleVolume>;
  open: boolean;
  onToggle: () => void;
}) {
  const guide = WEEKLY_SETS_GUIDE[fitnessLevel];
  const [expandedGroups, setExpandedGroups] = useState<Record<string, boolean>>({});

  return (
    <View style={{ backgroundColor: Colors.surfaceMuted, borderRadius: Radius.lg,
      borderWidth: 1, borderColor: Colors.border, marginTop: Spacing.md,
      overflow: 'hidden' }}>
      {/* Header */}
      <TouchableOpacity onPress={onToggle}
        style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md }}>
        <View style={{ width: 28, height: 28, borderRadius: 14,
          backgroundColor: Colors.primaryTint, alignItems: 'center', justifyContent: 'center',
          marginRight: Spacing.sm }}>
          <Ionicons name="bar-chart-outline" size={14} color={Colors.primary} />
        </View>
        <View style={{ flex: 1 }}>
          <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>Weekly Volume Guidelines</Text>
          <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary }}>
            {fitnessLevel.charAt(0) + fitnessLevel.slice(1).toLowerCase()} · read-only reference
          </Text>
        </View>
        <Ionicons name={open ? 'chevron-up' : 'chevron-down'} size={16} color={Colors.textMuted} />
      </TouchableOpacity>

      {open && (
        <View style={{ paddingHorizontal: Spacing.md, paddingBottom: Spacing.md }}>
          <View style={{ height: 1, backgroundColor: Colors.border, marginBottom: Spacing.sm }} />
          <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginBottom: Spacing.sm }}>
            Target sets per muscle group per week. Bars show your current plan.
          </Text>
          {guide.map(({ muscle, min, max }) => {
            const parts = ROLLUP_PARTS[muscle];
            // Include exercises tagged with the aggregate group itself
            const partValues = parts
              ? [...parts.map((p) => currentVolume[p] ?? EMPTY_VOLUME),
                 currentVolume[muscle] ?? EMPTY_VOLUME]
              : [];
            const pick = (field: 'direct' | 'total') => AGGREGATE_DISPLAY[muscle] === 'max'
              ? Math.max(...partValues.map((v) => v[field]))
              : partValues.reduce((a, v) => a + v[field], 0);
            const current: MuscleVolume = parts
              ? { direct: pick('direct'), total: pick('total') }
              : currentVolume[muscle] ?? EMPTY_VOLUME;
            const isOpen   = !!expandedGroups[muscle];
            // Judged on DIRECT sets: these target ranges are direct-set advice,
            // and counting indirect work against them reads every pressing
            // program as over-training its front delts.
            const inRange  = current.direct >= min && current.direct <= max;
            const over     = current.direct > max;
            const barColor = over ? Colors.warning : inRange ? Colors.success : Colors.primary;
            const fillPct  = Math.min(current.direct / max, 1.2); // allow slight overflow visually
            const totalPct = Math.min(current.total / max, 1.2);

            return (
              <View key={muscle} style={{ marginBottom: 10 }}>
                <TouchableOpacity
                  disabled={!parts}
                  onPress={() => setExpandedGroups((prev) => ({ ...prev, [muscle]: !prev[muscle] }))}
                  style={{ flexDirection: 'row', justifyContent: 'space-between',
                    alignItems: 'center', marginBottom: 3 }}>
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 3 }}>
                    <Text style={{ fontSize: FontSize.xs, color: Colors.textPrimary,
                      fontWeight: FontWeight.medium }}>{muscle}</Text>
                    {parts && (
                      <Ionicons name={isOpen ? 'chevron-up' : 'chevron-down'}
                        size={11} color={Colors.textMuted} />
                    )}
                  </View>
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                    {current.total > 0 && (
                      <Text style={{ fontSize: 10,
                        color: over ? Colors.warning : inRange ? Colors.success : Colors.textMuted,
                        fontWeight: FontWeight.semibold }}>
                        {describeVolume(current)}
                      </Text>
                    )}
                    <Text style={{ fontSize: 10, color: Colors.textMuted }}>
                      target {min}–{max}
                    </Text>
                  </View>
                </TouchableOpacity>
                {/* Guide range bar */}
                <View style={{ height: 6, backgroundColor: Colors.surfaceSubtle,
                  borderRadius: 3, overflow: 'hidden' }}>
                  {/* Target zone shading */}
                  <View style={{
                    position: 'absolute', left: `${(min / max) * 100}%` as any,
                    right: 0, top: 0, bottom: 0,
                    backgroundColor: Colors.successTint, borderRadius: 3,
                  }} />
                  {/* Total including indirect work, ghosted behind the direct bar */}
                  {current.total > current.direct && (
                    <View style={{
                      position: 'absolute', left: 0, top: 0, bottom: 0,
                      width: `${Math.min(totalPct * 100, 100)}%`,
                      backgroundColor: Colors.primaryLight, opacity: 0.45, borderRadius: 3,
                    }} />
                  )}
                  {/* Direct sets — what the target range is measured against */}
                  {current.direct > 0 && (
                    <View style={{
                      height: 6, width: `${Math.min(fillPct * 100, 100)}%`,
                      backgroundColor: barColor, borderRadius: 3,
                    }} />
                  )}
                </View>
                {/* Granular breakdown for grouped muscles */}
                {parts && isOpen && (
                  <View style={{ marginTop: 6, marginLeft: 6, paddingLeft: Spacing.sm,
                    borderLeftWidth: 2, borderLeftColor: Colors.border }}>
                    {parts.map((p) => (
                      <View key={p} style={{ flexDirection: 'row',
                        justifyContent: 'space-between', paddingVertical: 2 }}>
                        <Text style={{ fontSize: 10, color: Colors.textSecondary }}>{p}</Text>
                        <Text style={{ fontSize: 10, fontWeight: FontWeight.semibold,
                          color: (currentVolume[p]?.total ?? 0) > 0
                            ? Colors.textPrimary : Colors.textMuted }}>
                          {describeVolume(currentVolume[p] ?? EMPTY_VOLUME)}
                        </Text>
                      </View>
                    ))}
                  </View>
                )}
              </View>
            );
          })}
          <Text style={{ fontSize: 10, color: Colors.textMuted, marginTop: 4 }}>
            Green = in range · Blue = building up · Yellow = above max{'\n'}
            Bars and colours track DIRECT sets — the ones these ranges are written
            for. The pale bar behind adds indirect work: a muscle worked as a
            secondary counts half a set, so a bench press also feeds your triceps
            and front delts. Myo-reps count as 3 sets.{'\n'}
            Shoulders, Back and Abs group several muscles — tap them for the
            breakdown. Shoulders and Back show their most-trained muscle; Abs sums.
          </Text>
        </View>
      )}
    </View>
  );
}

// ─── Exercise grouping (superset / circle) ────────────────────────────────────
// Two grouped exercises = a Superset; more than two = a Circle.

function groupSize(items: DiyExercise[], groupId?: string | null): number {
  if (!groupId) return 0;
  return items.filter((e) => e.supersetGroupId === groupId).length;
}

function GroupBadge({ items, groupId }: { items: DiyExercise[]; groupId?: string | null }) {
  const size = groupSize(items, groupId);
  if (size < 2) return null;
  return (
    <View style={{ backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
      paddingHorizontal: 8, paddingVertical: 2 }}>
      <Text style={{ fontSize: 9, color: Colors.primary, fontWeight: FontWeight.semibold,
        textTransform: 'uppercase', letterSpacing: 0.3 }}>
        {size === 2 ? 'Superset' : 'Circle'}
      </Text>
    </View>
  );
}

function assignGroup(items: DiyExercise[], initiatorId: number, targetIds: number[]): DiyExercise[] {
  const existing = items.find((e) => e.exercise.id === initiatorId)?.supersetGroupId;
  const groupId = existing ?? `group-${Date.now()}`;
  const ids = new Set<number>([initiatorId, ...targetIds]);
  return items.map((e) => (ids.has(e.exercise.id) ? { ...e, supersetGroupId: groupId } : e));
}

function ungroup(items: DiyExercise[], exId: number): DiyExercise[] {
  const groupId = items.find((e) => e.exercise.id === exId)?.supersetGroupId;
  let next = items.map((e) => (e.exercise.id === exId ? { ...e, supersetGroupId: null } : e));
  if (groupId) {
    const remaining = next.filter((e) => e.supersetGroupId === groupId);
    if (remaining.length === 1) {
      next = next.map((e) => (e.supersetGroupId === groupId ? { ...e, supersetGroupId: null } : e));
    }
  }
  return next;
}

/** Three-dots menu + picker to group an exercise into a superset/circle. */
function GroupControls({ items, exId, onChange }: {
  items: DiyExercise[];
  exId: number;
  onChange: (next: DiyExercise[]) => void;
}) {
  const [menu, setMenu] = useState(false);
  const [picker, setPicker] = useState(false);
  const [selected, setSelected] = useState<Set<number>>(new Set());

  const me = items.find((e) => e.exercise.id === exId);
  const inGroup = !!me?.supersetGroupId;
  const myGroup = me?.supersetGroupId;

  const eligible = items.filter((e) => e.exercise.id !== exId
    && (e.supersetGroupId == null || e.supersetGroupId === myGroup));

  const existingPeers = myGroup
    ? items.filter((e) => e.exercise.id !== exId && e.supersetGroupId === myGroup).length
    : 0;
  const resultingSize = 1 + existingPeers + selected.size;

  const toggle = (id: number) => setSelected((prev) => {
    const n = new Set(prev);
    n.has(id) ? n.delete(id) : n.add(id);
    return n;
  });

  return (
    <>
      <TouchableOpacity onPress={() => setMenu(true)}
        hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }} style={{ paddingHorizontal: 2 }}>
        <Ionicons name="ellipsis-vertical" size={18} color={Colors.textMuted} />
      </TouchableOpacity>

      {/* Bottom-sheet menu */}
      <Modal visible={menu} transparent animationType="fade">
        <TouchableOpacity style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.4)',
          justifyContent: 'flex-end' }} activeOpacity={1} onPress={() => setMenu(false)}>
          <View style={{ backgroundColor: Colors.surface, borderTopLeftRadius: Radius.xl,
            borderTopRightRadius: Radius.xl, padding: Spacing.md, paddingBottom: 32 }}>
            {!inGroup && (
              <TouchableOpacity
                onPress={() => { setMenu(false); setSelected(new Set()); setPicker(true); }}
                style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.md,
                  padding: Spacing.md }}>
                <Ionicons name="git-merge-outline" size={20} color={Colors.textPrimary} />
                <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary }}>
                  Group with exercise…
                </Text>
              </TouchableOpacity>
            )}
            {inGroup && (
              <>
                <TouchableOpacity
                  onPress={() => { setMenu(false); setSelected(new Set()); setPicker(true); }}
                  style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.md,
                    padding: Spacing.md }}>
                  <Ionicons name="add-circle-outline" size={20} color={Colors.textPrimary} />
                  <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary }}>
                    Add to group…
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={() => { setMenu(false); onChange(ungroup(items, exId)); }}
                  style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.md,
                    padding: Spacing.md }}>
                  <Ionicons name="git-pull-request-outline" size={20} color={Colors.error} />
                  <Text style={{ fontSize: FontSize.md, color: Colors.error }}>
                    Remove from group
                  </Text>
                </TouchableOpacity>
              </>
            )}
            <TouchableOpacity onPress={() => setMenu(false)}
              style={{ alignItems: 'center', paddingTop: Spacing.sm }}>
              <Text style={{ color: Colors.textSecondary, fontSize: FontSize.sm }}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </TouchableOpacity>
      </Modal>

      {/* Picker */}
      <Modal visible={picker} animationType="slide" presentationStyle="pageSheet">
        <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surface }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md,
            borderBottomWidth: 1, borderBottomColor: Colors.border }}>
            <TouchableOpacity onPress={() => setPicker(false)}
              style={{ padding: 4, marginRight: Spacing.sm }}>
              <Ionicons name="close" size={22} color={Colors.textPrimary} />
            </TouchableOpacity>
            <Text style={{ flex: 1, fontSize: FontSize.md, fontWeight: FontWeight.semibold,
              color: Colors.textPrimary }}>Group with…</Text>
            {selected.size > 0 && (
              <TouchableOpacity
                onPress={() => { onChange(assignGroup(items, exId, [...selected])); setPicker(false); }}
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
            {eligible.length === 0 && (
              <Text style={{ padding: Spacing.lg, color: Colors.textMuted, fontSize: FontSize.sm }}>
                Add more exercises to this workout first.
              </Text>
            )}
            {eligible.map((e) => {
              const sel = selected.has(e.exercise.id);
              return (
                <TouchableOpacity key={e.exercise.id} onPress={() => toggle(e.exercise.id)}
                  style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md,
                    borderBottomWidth: 1, borderBottomColor: Colors.border,
                    backgroundColor: sel ? Colors.primaryTint : 'transparent' }}>
                  <View style={{ width: 22, height: 22, borderRadius: 11, borderWidth: 2,
                    borderColor: sel ? Colors.primary : Colors.border,
                    backgroundColor: sel ? Colors.primary : 'transparent',
                    alignItems: 'center', justifyContent: 'center', marginRight: Spacing.md }}>
                    {sel && <Ionicons name="checkmark" size={14} color={Colors.textInverse} />}
                  </View>
                  <Text style={{ flex: 1, fontSize: FontSize.md, color: Colors.textPrimary,
                    fontWeight: FontWeight.medium }}>{e.exercise.name}</Text>
                </TouchableOpacity>
              );
            })}
          </ScrollView>
        </SafeAreaView>
      </Modal>
    </>
  );
}

// ─── Reusable exercise list editor (used by standalone builder) ───────────────

function ExerciseRowsEditor({ items, onChange, allExercises, goal }: {
  items: DiyExercise[];
  onChange: (next: DiyExercise[]) => void;
  allExercises: ExerciseResponse[];
  goal: TrainingGoal;
}) {
  const [search, setSearch] = useState('');

  const add = (ex: ExerciseResponse) => {
    if (items.some((e) => e.exercise.id === ex.id)) return;
    onChange([...items, { exercise: ex, ...defaultSetsReps(goal), method: 'STRAIGHT_SETS', supersetGroupId: null }]);
  };
  const remove = (exId: number) => onChange(items.filter((e) => e.exercise.id !== exId));
  const patch = (exId: number, p: Partial<DiyExercise>) =>
    onChange(items.map((e) => (e.exercise.id === exId ? { ...e, ...p } : e)));
  const move = (idx: number, dir: -1 | 1) => {
    const arr = [...items];
    const j = idx + dir;
    if (j < 0 || j >= arr.length) return;
    [arr[idx], arr[j]] = [arr[j], arr[idx]];
    onChange(arr);
  };

  const filtered = allExercises.filter((e) =>
    e.name.toLowerCase().includes(search.toLowerCase()));

  return (
    <>
      {items.length > 0 && (
        <View style={{ borderBottomWidth: 1, borderBottomColor: Colors.border }}>
          <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted,
            fontWeight: FontWeight.medium, paddingHorizontal: Spacing.lg,
            paddingTop: Spacing.md, paddingBottom: 6 }}>SELECTED EXERCISES</Text>
          {items.map((de, idx) => (
            <View key={de.exercise.id} style={{ paddingHorizontal: Spacing.lg, paddingVertical: 10,
              borderTopWidth: 1, borderTopColor: Colors.border, backgroundColor: Colors.surface }}>
              <View style={{ flexDirection: 'row', alignItems: 'center',
                justifyContent: 'space-between', marginBottom: 6 }}>
                <View style={{ flexDirection: 'row', alignItems: 'center', marginRight: 6 }}>
                  <TouchableOpacity disabled={idx === 0} onPress={() => move(idx, -1)}
                    hitSlop={{ top: 6, bottom: 6, left: 4, right: 4 }}
                    style={{ paddingHorizontal: 1, opacity: idx === 0 ? 0.25 : 1 }}>
                    <Ionicons name="chevron-up" size={18} color={Colors.textMuted} />
                  </TouchableOpacity>
                  <TouchableOpacity disabled={idx === items.length - 1} onPress={() => move(idx, 1)}
                    hitSlop={{ top: 6, bottom: 6, left: 4, right: 4 }}
                    style={{ paddingHorizontal: 1, opacity: idx === items.length - 1 ? 0.25 : 1 }}>
                    <Ionicons name="chevron-down" size={18} color={Colors.textMuted} />
                  </TouchableOpacity>
                </View>
                <View style={{ flex: 1, marginRight: Spacing.sm }}>
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                    <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
                      color: Colors.textPrimary }}>{de.exercise.name}</Text>
                    <GroupBadge items={items} groupId={de.supersetGroupId} />
                  </View>
                  <Text style={{ fontSize: 10, color: Colors.textMuted, marginTop: 1 }}>
                    {de.exercise.muscles.filter((m) => m.role === 'PRIMARY')
                      .map((m) => m.muscleGroupName).join(', ')}
                  </Text>
                </View>
                <GroupControls items={items} exId={de.exercise.id} onChange={onChange} />
                <TouchableOpacity onPress={() => remove(de.exercise.id)}
                  hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }} style={{ marginLeft: 4 }}>
                  <Ionicons name="close-circle-outline" size={20} color={Colors.textMuted} />
                </TouchableOpacity>
              </View>

              <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.lg }}>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                  <Text style={{ fontSize: 10, color: Colors.textMuted,
                    fontWeight: FontWeight.medium }}>SETS</Text>
                  <TouchableOpacity onPress={() => patch(de.exercise.id, { sets: Math.max(1, de.sets - 1) })}>
                    <Ionicons name="remove-circle-outline" size={22} color={Colors.primary} />
                  </TouchableOpacity>
                  <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.bold,
                    color: Colors.textPrimary, minWidth: 18, textAlign: 'center' }}>{de.sets}</Text>
                  <TouchableOpacity onPress={() => patch(de.exercise.id, { sets: Math.min(10, de.sets + 1) })}>
                    <Ionicons name="add-circle-outline" size={22} color={Colors.primary} />
                  </TouchableOpacity>
                </View>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                  <Text style={{ fontSize: 10, color: Colors.textMuted,
                    fontWeight: FontWeight.medium }}>REPS</Text>
                  <TextInput value={String(de.reps)}
                    onChangeText={(v) => {
                      const n = parseInt(v, 10);
                      if (!isNaN(n) && n > 0 && n <= 50) patch(de.exercise.id, { reps: n });
                    }}
                    keyboardType="number-pad"
                    style={{ width: 44, height: 30, backgroundColor: Colors.surfaceMuted,
                      borderRadius: Radius.sm, textAlign: 'center', fontSize: FontSize.sm,
                      fontWeight: FontWeight.semibold, color: Colors.textPrimary,
                      borderWidth: 1, borderColor: Colors.border }} />
                  <Text style={{ fontSize: 10, color: Colors.textMuted }}>rec {REP_RANGE_HINT[goal]}</Text>
                </View>
                <View style={{ backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
                  paddingHorizontal: 10, paddingVertical: 3 }}>
                  <Text style={{ fontSize: 10, color: Colors.primary,
                    fontWeight: FontWeight.semibold }}>{de.sets} × {de.reps}</Text>
                </View>
              </View>

              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 8 }}>
                <Text style={{ fontSize: 10, color: Colors.textMuted,
                  fontWeight: FontWeight.medium }}>METHOD</Text>
                {([
                  { value: 'STRAIGHT_SETS', label: 'Straight' },
                  { value: 'MYOREPS', label: 'Myo-reps' },
                ] as { value: TrainingMethod; label: string }[]).map(({ value, label }) => {
                  const active = de.method === value;
                  return (
                    <TouchableOpacity key={value}
                      onPress={() => patch(de.exercise.id, { method: value })}
                      style={{ paddingHorizontal: 10, paddingVertical: 4, borderRadius: Radius.full,
                        backgroundColor: active ? Colors.primary : Colors.surfaceMuted,
                        borderWidth: 1, borderColor: active ? Colors.primary : Colors.border }}>
                      <Text style={{ fontSize: 10, fontWeight: FontWeight.semibold,
                        color: active ? Colors.textInverse : Colors.textSecondary }}>{label}</Text>
                    </TouchableOpacity>
                  );
                })}
              </View>
            </View>
          ))}
        </View>
      )}

      <View style={{ paddingHorizontal: Spacing.md, paddingTop: Spacing.md, paddingBottom: Spacing.sm }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8,
          backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md, paddingHorizontal: 12,
          borderWidth: 1, borderColor: Colors.border }}>
          <Ionicons name="search" size={16} color={Colors.textMuted} />
          <TextInput value={search} onChangeText={setSearch}
            placeholder="Search exercises to add…" placeholderTextColor={Colors.textMuted}
            style={{ flex: 1, paddingVertical: 10, fontSize: FontSize.md, color: Colors.textPrimary }} />
        </View>
      </View>

      {filtered.map((ex) => {
        const added = items.some((e) => e.exercise.id === ex.id);
        return (
          <TouchableOpacity key={ex.id} onPress={() => (added ? remove(ex.id) : add(ex))}
            style={{ flexDirection: 'row', alignItems: 'center', paddingVertical: 12,
              paddingHorizontal: Spacing.lg, borderBottomWidth: 1, borderBottomColor: Colors.border,
              backgroundColor: added ? Colors.primaryTint : 'transparent' }}>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary,
                fontWeight: FontWeight.medium }}>{ex.name}</Text>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 2 }}>
                {ex.muscles.filter((m) => m.role === 'PRIMARY')
                  .map((m) => m.muscleGroupName).join(', ')}
              </Text>
            </View>
            <Ionicons name={added ? 'checkmark-circle' : 'add-circle-outline'}
              size={22} color={added ? Colors.primary : Colors.textMuted} />
          </TouchableOpacity>
        );
      })}
    </>
  );
}

// ─── Standalone session builder ───────────────────────────────────────────────

function StandaloneBuilder() {
  const queryClient = useQueryClient();
  const [name, setName] = useState('Standalone Workout');
  const [exercises, setExercises] = useState<DiyExercise[]>([]);

  const { data: allExercises } = useQuery({
    queryKey: ['exercises'],
    queryFn: exercisesApi.list,
  });

  const { mutate: create, isPending } = useMutation({
    mutationFn: () => workoutsApi.createStandalone({
      name,
      exercises: exercises.map((e) => ({
        exerciseId: e.exercise.id,
        sets: e.sets,
        reps: e.reps,
        trainingMethod: e.method,
        supersetGroupId: e.supersetGroupId ?? null,
      })),
    }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['standalone'] });
      router.replace('/(tabs)/workouts');
    },
    onError: (e: Error) => Alert.alert('Error', e.message),
  });

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surface }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md,
        borderBottomWidth: 1, borderBottomColor: Colors.border }}>
        <TouchableOpacity onPress={() => router.back()} style={{ padding: 4, marginRight: Spacing.sm }}>
          <Ionicons name="chevron-back" size={24} color={Colors.textPrimary} />
        </TouchableOpacity>
        <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
          color: Colors.textPrimary }}>Standalone Session</Text>
      </View>

      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingBottom: 120 }}
        keyboardShouldPersistTaps="handled">
        <View style={{ padding: Spacing.lg, paddingBottom: Spacing.sm }}>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
            fontWeight: FontWeight.medium, marginBottom: 6 }}>Workout Name</Text>
          <TextInput value={name} onChangeText={setName}
            style={{ backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
              paddingHorizontal: Spacing.md, paddingVertical: 12, fontSize: FontSize.lg,
              color: Colors.textPrimary, borderWidth: 1, borderColor: Colors.border }} />
          <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginTop: Spacing.sm }}>
            A one-off workout — no training days or weekly volume. Started and logged
            like any other session.
          </Text>
        </View>

        <ExerciseRowsEditor
          items={exercises}
          onChange={setExercises}
          allExercises={allExercises ?? []}
          goal="HYPERTROPHY"
        />
      </ScrollView>

      <View style={{ position: 'absolute', bottom: 0, left: 0, right: 0,
        backgroundColor: Colors.surface, padding: Spacing.lg,
        borderTopWidth: 1, borderTopColor: Colors.border }}>
        <TouchableOpacity onPress={() => create()}
          disabled={isPending || exercises.length === 0}
          style={{ backgroundColor: Colors.primary, borderRadius: Radius.md,
            paddingVertical: 16, alignItems: 'center',
            opacity: isPending || exercises.length === 0 ? 0.6 : 1 }}>
          {isPending
            ? <ActivityIndicator color={Colors.textInverse} />
            : <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                fontSize: FontSize.md }}>Save Standalone Session →</Text>}
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

// ─── Shared sub-components ────────────────────────────────────────────────────

function StepContainer({ title, subtitle, children }: {
  title: string; subtitle: string; children: React.ReactNode;
}) {
  return (
    <View>
      <Text style={{ fontSize: FontSize.xxl, fontWeight: FontWeight.bold,
        color: Colors.textPrimary, marginBottom: 6 }}>{title}</Text>
      {subtitle ? (
        <Text style={{ fontSize: FontSize.md, color: Colors.textSecondary,
          marginBottom: Spacing.lg }}>{subtitle}</Text>
      ) : (
        <View style={{ marginBottom: Spacing.md }} />
      )}
      {children}
    </View>
  );
}

function OptionCard({ title, subtitle, selected, onPress, icon }: {
  title: string; subtitle: string; selected: boolean; onPress: () => void; icon?: string;
}) {
  return (
    <TouchableOpacity onPress={onPress} style={{
      borderRadius: Radius.lg, padding: Spacing.md, marginBottom: Spacing.sm,
      backgroundColor: selected ? Colors.primaryTint : Colors.surfaceMuted,
      borderWidth: 2, borderColor: selected ? Colors.primary : 'transparent',
      flexDirection: 'row', alignItems: 'center',
    }}>
      {icon && (
        <View style={{ width: 40, height: 40, borderRadius: 20,
          backgroundColor: selected ? Colors.primary : Colors.surfaceSubtle,
          alignItems: 'center', justifyContent: 'center', marginRight: Spacing.md }}>
          <Ionicons name={icon as any} size={20}
            color={selected ? Colors.textInverse : Colors.textSecondary} />
        </View>
      )}
      <View style={{ flex: 1 }}>
        <Text style={{ fontWeight: FontWeight.semibold, fontSize: FontSize.md,
          color: selected ? Colors.primary : Colors.textPrimary }}>{title}</Text>
        <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
          marginTop: 2 }}>{subtitle}</Text>
      </View>
      {selected && <Ionicons name="checkmark-circle" size={20} color={Colors.primary} />}
    </TouchableOpacity>
  );
}

function SummaryRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
      paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
      <Text style={{ fontSize: FontSize.md, color: Colors.textSecondary }}>{label}</Text>
      <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
        color: Colors.textPrimary }}>{value}</Text>
    </View>
  );
}
