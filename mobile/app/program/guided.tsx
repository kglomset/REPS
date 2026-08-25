import React, { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator, Modal, ScrollView, Text, TextInput, TouchableOpacity, View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { programsApi } from '@/services/api/programs';
import { exercisesApi } from '@/services/api/exercises';
import {
  TrainingGoal, TrainingMethod, FitnessLevel, ExerciseResponse,
  ExerciseMuscleResponse, SplitOptionResponse, ProgramDraftResponse,
  DraftDay, DraftExercise,
} from '@/types';
import { VolumeSlider, VolumeBand } from '@/components/VolumeSlider';
import { weeklyVolume, formatSets, MuscleVolume } from '@/utils/volume';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';

// ─── Guided program builder ───────────────────────────────────────────────────
// Goal → volume → frequency → split → myo-reps → exercises → name.
//
// Each step explains the parameter before asking for it, because these are the
// three things that actually shape a program and the old wizard hid all of them
// behind a "beginner / intermediate / advanced" label.
//
// Generation lives on the backend (POST /programs/draft); this screen renders the
// proposal, lets every part of it be changed, and only then creates the program.
// Design doc: docs/program-builder-design.md

type Step = 'goal' | 'volume' | 'frequency' | 'split' | 'myoreps' | 'exercises' | 'name';
const STEPS: Step[] = ['goal', 'volume', 'frequency', 'split', 'myoreps', 'exercises', 'name'];

const VOLUME_MIN = 5;
const VOLUME_MAX = 30;

const VOLUME_BANDS: VolumeBand[] = [
  { label: 'Beginner', min: 5, max: 10 },
  { label: 'Intermediate', min: 10, max: 20 },
  { label: 'Advanced', min: 15, max: 30 },
];

/** The program still carries a FitnessLevel; derive it from the volume chosen. */
function levelFor(weeklySets: number): FitnessLevel {
  if (weeklySets < 10) return 'BEGINNER';
  if (weeklySets < 16) return 'INTERMEDIATE';
  return 'ADVANCED';
}

const GOALS: { value: TrainingGoal; title: string; summary: string; points: string[] }[] = [
  {
    value: 'STRENGTH',
    title: 'Stronger',
    summary: 'Move the most weight you can. Size follows, but it is not the target.',
    points: [
      'More sets, fewer reps — mostly 4–6 on the main lifts',
      'Stop further from failure, so quality stays high across every set',
      'Compound movements first and foremost',
      'Longer rests, so expect longer sessions',
    ],
  },
  {
    value: 'HYPERTROPHY',
    title: 'Bigger & stronger',
    summary: 'Build muscle while still getting stronger on the big lifts.',
    points: [
      'Reps across the 4–12 band — compounds low, isolations high',
      'Sets taken closer to failure',
      'Sets, reps and effort mixed rather than held constant',
      'Shorter rests, so sessions stay tighter',
    ],
  },
];

const METHOD_LABELS: Partial<Record<TrainingMethod, string>> = {
  STRAIGHT_SETS: 'Straight',
  MYOREPS: 'Myo-reps',
  DROP_SET: 'Drop set',
};
const EDITABLE_METHODS: TrainingMethod[] = ['STRAIGHT_SETS', 'MYOREPS', 'DROP_SET'];

const DAY_NAMES = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

export default function GuidedProgramScreen() {
  const params = useLocalSearchParams<{ goal?: string }>();
  const queryClient = useQueryClient();

  const [step, setStep] = useState<Step>('goal');
  const [goal, setGoal] = useState<TrainingGoal>(
    params.goal === 'STRENGTH' ? 'STRENGTH' : 'HYPERTROPHY'
  );
  const [weeklySets, setWeeklySets] = useState(12);
  const [daysPerWeek, setDaysPerWeek] = useState(4);
  const [splitId, setSplitId] = useState<string | null>(null);
  const [recommendMyoreps, setRecommendMyoreps] = useState(false);
  const [name, setName] = useState('My Training Program');

  // The generated draft, made editable. Null until the exercises step loads it.
  const [draft, setDraft] = useState<ProgramDraftResponse | null>(null);
  const [drafting, setDrafting] = useState(false);
  const [draftError, setDraftError] = useState<string | null>(null);
  const [creating, setCreating] = useState(false);
  const [addExerciseForDay, setAddExerciseForDay] = useState<number | null>(null);

  const { data: splits } = useQuery({
    queryKey: ['splits', daysPerWeek],
    queryFn: () => programsApi.getSplits(daysPerWeek),
  });

  // Changing the frequency invalidates whatever split was chosen for the old one.
  useEffect(() => { setSplitId(null); }, [daysPerWeek]);

  const chosenSplit: SplitOptionResponse | undefined = useMemo(
    () => (splits ?? []).find((s) => s.id === splitId) ?? (splits ?? [])[0],
    [splits, splitId]
  );

  const generate = async () => {
    setDrafting(true);
    setDraftError(null);
    try {
      const result = await programsApi.draft({
        goal, weeklySetsPerMuscle: weeklySets, daysPerWeek,
        splitId: chosenSplit?.id, recommendMyoreps,
      });
      setDraft(result);
    } catch (e: any) {
      setDraftError(e?.message ?? 'Could not build a program from those answers.');
    } finally {
      setDrafting(false);
    }
  };

  const next = async () => {
    const i = STEPS.indexOf(step);
    const target = STEPS[Math.min(i + 1, STEPS.length - 1)];
    if (target === 'exercises') await generate();
    setStep(target);
  };

  const back = () => {
    const i = STEPS.indexOf(step);
    if (i === 0) { router.back(); return; }
    setStep(STEPS[i - 1]);
  };

  // ── Draft editing ───────────────────────────────────────────────────────

  const patchExercise = (dayIdx: number, exIdx: number, patch: Partial<DraftExercise>) => {
    setDraft((prev) => prev && ({
      ...prev,
      days: prev.days.map((d, i) => i !== dayIdx ? d : {
        ...d,
        exercises: d.exercises.map((e, j) => j === exIdx ? { ...e, ...patch } : e),
      }),
    }));
  };

  const removeExercise = (dayIdx: number, exIdx: number) => {
    setDraft((prev) => prev && ({
      ...prev,
      days: prev.days.map((d, i) => i !== dayIdx ? d : {
        ...d, exercises: d.exercises.filter((_, j) => j !== exIdx),
      }),
    }));
  };

  const addExercise = (dayIdx: number, exercise: ExerciseResponse) => {
    const compound = exercise.movementPattern === 'COMPOUND';
    // Match what the generator would have prescribed for this movement.
    const [repsMin, repsMax, restSeconds] = goal === 'STRENGTH'
      ? (compound ? [4, 6, 240] : [6, 10, 150])
      : (compound ? [5, 8, 180] : [8, 12, 90]);
    setDraft((prev) => prev && ({
      ...prev,
      days: prev.days.map((d, i) => i !== dayIdx ? d : {
        ...d,
        exercises: [...d.exercises, {
          exerciseId: exercise.id,
          name: exercise.name,
          movementPattern: exercise.movementPattern ?? 'ISOLATION',
          sets: goal === 'STRENGTH' ? 4 : 3,
          repsMin, repsMax, restSeconds,
          trainingMethod: 'STRAIGHT_SETS' as TrainingMethod,
        }],
      }),
    }));
    setAddExerciseForDay(null);
  };

  const handleCreate = async () => {
    if (!draft || creating) return;
    setCreating(true);
    try {
      await programsApi.create({
        name: name.trim() || 'My Training Program',
        fitnessLevel: levelFor(weeklySets),
        goal,
        strengthDaysPerWeek: daysPerWeek,
        cardioDaysPerWeek: 0,
        weeklySetsPerMuscle: weeklySets,
        days: draft.days.map((d) => ({
          name: d.name,
          dayIndex: d.dayIndex,
          exercises: d.exercises.map((e) => ({
            exerciseId: e.exerciseId,
            sets: e.sets,
            reps: e.repsMin,
            repsMin: e.repsMin,
            repsMax: e.repsMax,
            restSeconds: e.restSeconds,
            trainingMethod: e.trainingMethod,
          })),
        })),
      });
      queryClient.invalidateQueries({ queryKey: ['activeProgram'] });
      queryClient.invalidateQueries({ queryKey: ['programs'] });
      router.replace('/(tabs)/');
    } catch (e: any) {
      setDraftError(e?.message ?? 'Could not create the program.');
      setCreating(false);
    }
  };

  // ── Render ──────────────────────────────────────────────────────────────

  const stepIndex = STEPS.indexOf(step);
  const canContinue =
    step === 'exercises' ? !!draft && draft.days.some((d) => d.exercises.length > 0) : true;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surfaceMuted }}>
      {/* Header + progress */}
      <View style={{ backgroundColor: Colors.surface, paddingHorizontal: Spacing.lg,
        paddingVertical: Spacing.sm, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.sm }}>
          <TouchableOpacity onPress={back} style={{ padding: 4 }}>
            <Ionicons name="chevron-back" size={22} color={Colors.textPrimary} />
          </TouchableOpacity>
          <Text style={{ flex: 1, fontSize: FontSize.lg, fontWeight: FontWeight.bold,
            color: Colors.textPrimary }}>Build my program</Text>
          <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>
            {stepIndex + 1} / {STEPS.length}
          </Text>
        </View>
        <View style={{ flexDirection: 'row', gap: 3, marginTop: Spacing.sm }}>
          {STEPS.map((s, i) => (
            <View key={s} style={{ flex: 1, height: 3, borderRadius: 2,
              backgroundColor: i <= stepIndex ? Colors.primary : Colors.surfaceSubtle }} />
          ))}
        </View>
      </View>

      <ScrollView contentContainerStyle={{ padding: Spacing.lg, paddingBottom: 100 }}>
        {step === 'goal' && <GoalStep value={goal} onChange={setGoal} />}

        {step === 'volume' && (
          <VolumeStep value={weeklySets} onChange={setWeeklySets} />
        )}

        {step === 'frequency' && (
          <FrequencyStep value={daysPerWeek} onChange={setDaysPerWeek} weeklySets={weeklySets} />
        )}

        {step === 'split' && (
          <SplitStep
            splits={splits ?? []}
            selectedId={chosenSplit?.id ?? null}
            onSelect={setSplitId}
          />
        )}

        {step === 'myoreps' && (
          <MyorepsStep value={recommendMyoreps} onChange={setRecommendMyoreps} />
        )}

        {step === 'exercises' && (
          <ExercisesStep
            draft={draft}
            loading={drafting}
            error={draftError}
            weeklySets={weeklySets}
            onRegenerate={generate}
            onPatch={patchExercise}
            onRemove={removeExercise}
            onAdd={(dayIdx) => setAddExerciseForDay(dayIdx)}
          />
        )}

        {step === 'name' && (
          <NameStep
            name={name}
            onChange={setName}
            goal={goal}
            weeklySets={weeklySets}
            daysPerWeek={daysPerWeek}
            splitName={draft?.splitName ?? chosenSplit?.name ?? ''}
            longestSessionMinutes={draft?.longestSessionMinutes ?? 0}
            error={draftError}
          />
        )}
      </ScrollView>

      {/* Footer */}
      <View style={{ position: 'absolute', bottom: 0, left: 0, right: 0,
        backgroundColor: Colors.surface, borderTopWidth: 1, borderTopColor: Colors.border,
        padding: Spacing.lg, paddingBottom: Spacing.lg + 8 }}>
        <TouchableOpacity
          onPress={step === 'name' ? handleCreate : next}
          disabled={!canContinue || drafting || creating}
          style={{ backgroundColor: Colors.primary, borderRadius: Radius.md,
            paddingVertical: 15, alignItems: 'center',
            opacity: !canContinue || drafting || creating ? 0.6 : 1 }}>
          {drafting || creating
            ? <ActivityIndicator color={Colors.textInverse} />
            : <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                fontSize: FontSize.md }}>
                {step === 'name' ? 'Create Program' : step === 'exercises' ? 'Looks good →' : 'Continue →'}
              </Text>}
        </TouchableOpacity>
      </View>

      {addExerciseForDay !== null && draft && (
        <AddExerciseModal
          existingIds={draft.days[addExerciseForDay].exercises.map((e) => e.exerciseId)}
          onSelect={(ex) => addExercise(addExerciseForDay, ex)}
          onClose={() => setAddExerciseForDay(null)}
        />
      )}
    </SafeAreaView>
  );
}

// ─── Step 1: goal ─────────────────────────────────────────────────────────────

function GoalStep({ value, onChange }: {
  value: TrainingGoal;
  onChange: (g: TrainingGoal) => void;
}) {
  return (
    <View>
      <StepHeading
        title="What are you training for?"
        body="This is the one answer that changes everything else — how many reps you do, how hard each set is taken, and how much of your session is spent on the big lifts."
      />
      {GOALS.map((g) => {
        const active = g.value === value;
        return (
          <TouchableOpacity key={g.value} onPress={() => onChange(g.value)} activeOpacity={0.8}
            style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
              padding: Spacing.md, marginBottom: Spacing.md, ...Shadow.card,
              borderWidth: 2, borderColor: active ? Colors.primary : 'transparent' }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.sm }}>
              <Text style={{ flex: 1, fontSize: FontSize.lg, fontWeight: FontWeight.bold,
                color: active ? Colors.primary : Colors.textPrimary }}>{g.title}</Text>
              {active && <Ionicons name="checkmark-circle" size={22} color={Colors.primary} />}
            </View>
            <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 4 }}>
              {g.summary}
            </Text>
            <View style={{ marginTop: Spacing.sm, gap: 5 }}>
              {g.points.map((p) => (
                <View key={p} style={{ flexDirection: 'row', gap: 8 }}>
                  <Ionicons name="ellipse" size={6} color={Colors.textMuted}
                    style={{ marginTop: 6 }} />
                  <Text style={{ flex: 1, fontSize: FontSize.sm, color: Colors.textSecondary,
                    lineHeight: 19 }}>{p}</Text>
                </View>
              ))}
            </View>
          </TouchableOpacity>
        );
      })}
    </View>
  );
}

// ─── Step 2: volume ───────────────────────────────────────────────────────────

function VolumeStep({ value, onChange }: { value: number; onChange: (v: number) => void }) {
  return (
    <View>
      <StepHeading
        title="How much work per muscle?"
        body="Weekly sets per muscle group is the honest measure of training volume — more useful than a &quot;beginner or advanced&quot; label, because it is the number you can actually act on."
      />
      <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
        padding: Spacing.lg, ...Shadow.card, marginBottom: Spacing.md }}>
        <VolumeSlider value={value} min={VOLUME_MIN} max={VOLUME_MAX}
          onChange={onChange} bands={VOLUME_BANDS} />
      </View>

      <InfoCard icon="information-circle-outline" title="These ranges overlap on purpose">
        They are not hard intervals tied to how long you have trained. An advanced
        lifter can keep making good progress at the low end, and a beginner who
        jumps straight to the top of the scale mostly buys themselves fatigue.
      </InfoCard>

      <InfoCard icon="time-outline" title="Volume is paid for in time">
        A higher number means longer sessions, more sessions per week, or both.
        The next two steps turn this into an actual weekly schedule, and you will
        see the session length before anything is saved.
      </InfoCard>
    </View>
  );
}

// ─── Step 3: frequency ────────────────────────────────────────────────────────

function FrequencyStep({ value, onChange, weeklySets }: {
  value: number;
  onChange: (v: number) => void;
  weeklySets: number;
}) {
  const perSession = Math.round((weeklySets / value) * 10) / 10;
  return (
    <View>
      <StepHeading
        title="How many days a week?"
        body="Be honest about what fits your week. Training four days you actually turn up for beats six you skip."
      />
      <View style={{ flexDirection: 'row', gap: Spacing.sm, marginBottom: Spacing.lg }}>
        {[1, 2, 3, 4, 5, 6].map((d) => {
          const active = d === value;
          return (
            <TouchableOpacity key={d} onPress={() => onChange(d)}
              style={{ flex: 1, aspectRatio: 1, borderRadius: Radius.md,
                alignItems: 'center', justifyContent: 'center',
                backgroundColor: active ? Colors.primary : Colors.surface,
                borderWidth: 1, borderColor: active ? Colors.primary : Colors.border }}>
              <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
                color: active ? Colors.textInverse : Colors.textPrimary }}>{d}</Text>
            </TouchableOpacity>
          );
        })}
      </View>

      <InfoCard icon="calculator-outline" title={`About ${perSession} sets per muscle, per session`}>
        {`Your ${weeklySets} weekly sets spread across ${value} ${value === 1 ? 'day' : 'days'} — assuming a split that trains each muscle every session. The next step shows which splits fit, and most of them train a muscle more than once a week, which brings that number down.`}
      </InfoCard>
    </View>
  );
}

// ─── Step 4: split ────────────────────────────────────────────────────────────

function SplitStep({ splits, selectedId, onSelect }: {
  splits: SplitOptionResponse[];
  selectedId: string | null;
  onSelect: (id: string) => void;
}) {
  return (
    <View>
      <StepHeading
        title="Pick a split"
        body="A split decides which muscles you train on which day, and how often each one comes around. Hitting a muscle twice a week or more generally beats once, so those are listed first."
      />
      {splits.map((s) => {
        const active = s.id === selectedId;
        return (
          <TouchableOpacity key={s.id} onPress={() => onSelect(s.id)} activeOpacity={0.8}
            style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
              padding: Spacing.md, marginBottom: Spacing.sm, ...Shadow.card,
              borderWidth: 2, borderColor: active ? Colors.primary : 'transparent' }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.sm }}>
              <Text style={{ flex: 1, fontSize: FontSize.md, fontWeight: FontWeight.semibold,
                color: active ? Colors.primary : Colors.textPrimary }}>{s.name}</Text>
              {s.minWeeklyFrequency >= 2 && (
                <View style={{ backgroundColor: Colors.successTint, borderRadius: Radius.full,
                  paddingHorizontal: 8, paddingVertical: 3 }}>
                  <Text style={{ fontSize: 10, color: Colors.success,
                    fontWeight: FontWeight.semibold }}>
                    {s.minWeeklyFrequency}× / week
                  </Text>
                </View>
              )}
              {active && <Ionicons name="checkmark-circle" size={20} color={Colors.primary} />}
            </View>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 4, marginTop: 8 }}>
              {s.dayNames.map((d, i) => (
                <View key={`${d}-${i}`} style={{ backgroundColor: Colors.surfaceMuted,
                  borderRadius: Radius.sm, paddingHorizontal: 8, paddingVertical: 3 }}>
                  <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary }}>
                    {DAY_NAMES[i] ?? ''} · {d}
                  </Text>
                </View>
              ))}
            </View>
          </TouchableOpacity>
        );
      })}
      {splits.length === 0 && (
        <ActivityIndicator color={Colors.primary} style={{ marginTop: Spacing.lg }} />
      )}
    </View>
  );
}

// ─── Step 5: myo-reps ─────────────────────────────────────────────────────────

function MyorepsStep({ value, onChange }: { value: boolean; onChange: (v: boolean) => void }) {
  return (
    <View>
      <StepHeading
        title="Want myo-reps suggested?"
        body="A myo-rep set is one hard activation set taken near failure, then a handful of short cluster sets with only seconds of rest between them. It buys most of the stimulus of several straight sets in a fraction of the time."
      />

      <TouchableOpacity onPress={() => onChange(!value)} activeOpacity={0.8}
        style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.md,
          backgroundColor: Colors.surface, borderRadius: Radius.lg, padding: Spacing.md,
          ...Shadow.card, borderWidth: 2,
          borderColor: value ? Colors.primary : 'transparent', marginBottom: Spacing.md }}>
        <View style={{ width: 26, height: 26, borderRadius: 7, borderWidth: 2,
          borderColor: value ? Colors.primary : Colors.border,
          backgroundColor: value ? Colors.primary : 'transparent',
          alignItems: 'center', justifyContent: 'center' }}>
          {value && <Ionicons name="checkmark" size={17} color={Colors.textInverse} />}
        </View>
        <View style={{ flex: 1 }}>
          <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>Suggest myo-reps where they save time</Text>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 }}>
            You can still switch any exercise back on the next screen.
          </Text>
        </View>
      </TouchableOpacity>

      <InfoCard icon="options-outline" title="Where they get used">
        Isolation work only, and never the first exercise of a session — so every
        workout still opens with a compound movement done as straight sets. A
        squat or a bench press is never turned into a myo-rep set.
      </InfoCard>

      <InfoCard icon="alert-circle-outline" title="They are not free">
        Each cluster is taken close to failure, so they cost more per set than
        straight sets do. Worth it when time is short; not something to apply to
        a whole session.
      </InfoCard>
    </View>
  );
}

// ─── Step 6: exercises ────────────────────────────────────────────────────────

function ExercisesStep({ draft, loading, error, weeklySets, onRegenerate, onPatch, onRemove, onAdd }: {
  draft: ProgramDraftResponse | null;
  loading: boolean;
  error: string | null;
  weeklySets: number;
  onRegenerate: () => void;
  onPatch: (dayIdx: number, exIdx: number, patch: Partial<DraftExercise>) => void;
  onRemove: (dayIdx: number, exIdx: number) => void;
  onAdd: (dayIdx: number) => void;
}) {
  const [openDay, setOpenDay] = useState<number>(0);

  // The draft's volume figures are a snapshot from generation time. Recompute
  // them from what is actually on screen, so removing an exercise or switching
  // one to myo-reps moves the bars straight away. Cached query — the
  // add-exercise sheet asks for the same list.
  const { data: library } = useQuery({ queryKey: ['exercises'], queryFn: exercisesApi.list });

  const musclesByExercise = useMemo(() => {
    const map: Record<number, ExerciseMuscleResponse[]> = {};
    (library ?? []).forEach((e) => { map[e.id] = e.muscles; });
    return map;
  }, [library]);

  const livePlanned = useMemo(() => {
    if (!draft || !library) return null;
    return weeklyVolume(draft.days.flatMap((d) => d.exercises.map((e) => ({
      muscles: musclesByExercise[e.exerciseId] ?? [],
      method: e.trainingMethod,
      sets: e.sets,
    }))));
  }, [draft, library, musclesByExercise]);

  if (loading) {
    return (
      <View style={{ paddingVertical: 60, alignItems: 'center' }}>
        <ActivityIndicator size="large" color={Colors.primary} />
        <Text style={{ marginTop: Spacing.md, color: Colors.textSecondary }}>
          Putting your week together…
        </Text>
      </View>
    );
  }
  if (error || !draft) {
    return (
      <View style={{ paddingVertical: 40, alignItems: 'center' }}>
        <Ionicons name="warning-outline" size={32} color={Colors.warning} />
        <Text style={{ marginTop: Spacing.sm, color: Colors.textSecondary,
          textAlign: 'center' }}>{error ?? 'No program was generated.'}</Text>
        <TouchableOpacity onPress={onRegenerate}
          style={{ marginTop: Spacing.md, paddingHorizontal: 18, paddingVertical: 10,
            borderRadius: Radius.full, borderWidth: 1, borderColor: Colors.primary }}>
          <Text style={{ color: Colors.primary, fontWeight: FontWeight.medium }}>Try again</Text>
        </TouchableOpacity>
      </View>
    );
  }

  // Where the split simply cannot absorb the volume asked for, say so rather
  // than shipping a program that quietly misses the target. Measured on TOTAL
  // volume, because that is what the generator was told to fill — judging this
  // on direct sets alone would flag arms and rear delts on every sane program,
  // since they are largely trained by the presses and rows already in the week.
  const short = draft.weeklyVolume.filter(
    (v) => (livePlanned?.[v.name]?.total ?? v.plannedSets) < v.targetSets - 2.5);

  return (
    <View>
      <StepHeading
        title="Your week"
        body={`${draft.splitName} — ${draft.days.length} sessions, the longest about ${draft.longestSessionMinutes} minutes. Change anything you like before it is saved.`}
      />

      {short.length > 0 && (
        <InfoCard icon="alert-circle-outline" title="Some muscles land short of target" warning>
          {`${short.map((v) => v.name).join(', ')} come in under ${weeklySets} sets a week on this split. Adding a training day or easing the volume back would close the gap — or leave it, and add the sets yourself as you go.`}
        </InfoCard>
      )}

      {draft.days.map((day, dayIdx) => (
        <DayCard
          key={`${day.name}-${dayIdx}`}
          day={day}
          expanded={openDay === dayIdx}
          onToggle={() => setOpenDay(openDay === dayIdx ? -1 : dayIdx)}
          onPatch={(exIdx, patch) => onPatch(dayIdx, exIdx, patch)}
          onRemove={(exIdx) => onRemove(dayIdx, exIdx)}
          onAdd={() => onAdd(dayIdx)}
        />
      ))}

      <VolumeReadout volume={draft.weeklyVolume} planned={livePlanned}
        target={weeklySets} />
    </View>
  );
}

function DayCard({ day, expanded, onToggle, onPatch, onRemove, onAdd }: {
  day: DraftDay;
  expanded: boolean;
  onToggle: () => void;
  onPatch: (exIdx: number, patch: Partial<DraftExercise>) => void;
  onRemove: (exIdx: number) => void;
  onAdd: () => void;
}) {
  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      marginBottom: Spacing.sm, ...Shadow.card, overflow: 'hidden' }}>
      <TouchableOpacity onPress={onToggle} activeOpacity={0.7}
        style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md }}>
        <View style={{ flex: 1 }}>
          <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>
            {DAY_NAMES[day.dayIndex] ?? ''} · {day.name}
          </Text>
          <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary, marginTop: 2 }}>
            {day.exercises.length} exercises · ~{day.estimatedMinutes} min
          </Text>
        </View>
        <Ionicons name={expanded ? 'chevron-up' : 'chevron-down'} size={18}
          color={Colors.textMuted} />
      </TouchableOpacity>

      {expanded && (
        <View style={{ paddingHorizontal: Spacing.md, paddingBottom: Spacing.md }}>
          {day.exercises.map((ex, exIdx) => (
            <View key={`${ex.exerciseId}-${exIdx}`}
              style={{ borderTopWidth: 1, borderTopColor: Colors.border,
                paddingVertical: Spacing.sm }}>
              <View style={{ flexDirection: 'row', alignItems: 'flex-start', gap: 6 }}>
                <View style={{ flex: 1 }}>
                  <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
                    color: Colors.textPrimary }}>{ex.name}</Text>
                  <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 2 }}>
                    {ex.movementPattern === 'COMPOUND' ? 'Compound' : 'Isolation'}
                    {' · '}{ex.repsMin}–{ex.repsMax} reps
                    {' · '}{ex.restSeconds >= 60 ? `${Math.round(ex.restSeconds / 60)}m` : `${ex.restSeconds}s`} rest
                  </Text>
                </View>
                <TouchableOpacity onPress={() => onRemove(exIdx)} style={{ padding: 4 }}
                  hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
                  <Ionicons name="close-circle-outline" size={18} color={Colors.textMuted} />
                </TouchableOpacity>
              </View>

              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: 8 }}>
                {/* Sets stepper */}
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6,
                  backgroundColor: Colors.surfaceMuted, borderRadius: Radius.full,
                  paddingHorizontal: 6, paddingVertical: 3 }}>
                  <TouchableOpacity onPress={() => onPatch(exIdx, { sets: Math.max(1, ex.sets - 1) })}
                    hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
                    <Ionicons name="remove" size={14} color={Colors.textSecondary} />
                  </TouchableOpacity>
                  <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.semibold,
                    color: Colors.textPrimary, minWidth: 34, textAlign: 'center' }}>
                    {ex.sets} sets
                  </Text>
                  <TouchableOpacity onPress={() => onPatch(exIdx, { sets: Math.min(10, ex.sets + 1) })}
                    hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
                    <Ionicons name="add" size={14} color={Colors.textSecondary} />
                  </TouchableOpacity>
                </View>

                {/* Method */}
                {EDITABLE_METHODS.map((m) => {
                  const active = ex.trainingMethod === m;
                  return (
                    <TouchableOpacity key={m}
                      onPress={() => onPatch(exIdx, {
                        trainingMethod: m,
                        // Myo-reps are one activation set plus five clusters.
                        sets: m === 'MYOREPS' ? 6 : (ex.trainingMethod === 'MYOREPS' ? 3 : ex.sets),
                      })}
                      style={{ paddingHorizontal: 9, paddingVertical: 5,
                        borderRadius: Radius.full,
                        backgroundColor: active ? Colors.primaryTint : Colors.surfaceMuted,
                        borderWidth: 1,
                        borderColor: active ? Colors.primary : Colors.border }}>
                      <Text style={{ fontSize: 10, fontWeight: FontWeight.medium,
                        color: active ? Colors.primary : Colors.textSecondary }}>
                        {METHOD_LABELS[m]}
                      </Text>
                    </TouchableOpacity>
                  );
                })}
              </View>
            </View>
          ))}

          <TouchableOpacity onPress={onAdd}
            style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
              gap: 6, marginTop: Spacing.sm, paddingVertical: 10, borderRadius: Radius.md,
              borderWidth: 1.5, borderStyle: 'dashed', borderColor: Colors.primary }}>
            <Ionicons name="add-circle-outline" size={16} color={Colors.primary} />
            <Text style={{ fontSize: FontSize.sm, color: Colors.primary,
              fontWeight: FontWeight.medium }}>Add exercise</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
}

function VolumeReadout({ volume, planned, target }: {
  volume: ProgramDraftResponse['weeklyVolume'];
  /** Live totals recomputed from the edited draft; null until the library loads. */
  planned: Record<string, MuscleVolume> | null;
  target: number;
}) {
  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      padding: Spacing.md, marginTop: Spacing.sm, ...Shadow.card }}>
      <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
        color: Colors.textPrimary, marginBottom: 4 }}>
        Weekly sets per muscle · target {target}
      </Text>
      <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted,
        marginBottom: Spacing.sm }}>
        Direct sets · total including indirect work, where a muscle worked as a
        secondary counts half a set and a myo-rep exercise counts as 3. Bars track
        the total, which is what the target is filled against.
      </Text>
      {volume.map((v) => {
        const live = planned?.[v.name];
        const total = live?.total ?? v.plannedSets;
        const ratio = v.targetSets > 0 ? Math.min(1.4, total / v.targetSets) : 0;
        const directRatio = v.targetSets > 0 && live
          ? Math.min(1.4, live.direct / v.targetSets) : 0;
        const short = total < v.targetSets - 2.5;
        const over = total > v.targetSets + 2.5;
        const color = short ? Colors.warning : over ? Colors.primaryLight : Colors.success;
        return (
          <View key={v.slug} style={{ flexDirection: 'row', alignItems: 'center',
            gap: Spacing.sm, marginBottom: 5 }}>
            <Text style={{ width: 82, fontSize: FontSize.xs,
              color: Colors.textSecondary }} numberOfLines={1}>{v.name}</Text>
            <View style={{ flex: 1, height: 5, borderRadius: 3,
              backgroundColor: Colors.surfaceSubtle, overflow: 'hidden' }}>
              {/* Pale = total including indirect work; solid = direct sets */}
              <View style={{ height: 5, borderRadius: 3, opacity: 0.4,
                width: `${Math.min(100, (ratio / 1.4) * 100)}%`, backgroundColor: color }} />
              {directRatio > 0 && (
                <View style={{ position: 'absolute', left: 0, top: 0, bottom: 0,
                  width: `${Math.min(100, (directRatio / 1.4) * 100)}%`,
                  backgroundColor: color, borderRadius: 3 }} />
              )}
            </View>
            <Text style={{ width: 66, fontSize: FontSize.xs, textAlign: 'right',
              color: Colors.textSecondary, fontVariant: ['tabular-nums'] }}>
              {live ? `${formatSets(live.direct)} · ${formatSets(live.total)}`
                    : formatSets(v.plannedSets)}
            </Text>
          </View>
        );
      })}
    </View>
  );
}

// ─── Step 7: name ─────────────────────────────────────────────────────────────

function NameStep({ name, onChange, goal, weeklySets, daysPerWeek, splitName,
  longestSessionMinutes, error }: {
  name: string;
  onChange: (v: string) => void;
  goal: TrainingGoal;
  weeklySets: number;
  daysPerWeek: number;
  splitName: string;
  longestSessionMinutes: number;
  error: string | null;
}) {
  return (
    <View>
      <StepHeading title="Name it" body="That is everything. Give the program a name and it becomes your active plan." />
      <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
        padding: Spacing.md, ...Shadow.card, marginBottom: Spacing.md }}>
        <TextInput
          value={name}
          onChangeText={onChange}
          placeholder="My Training Program"
          placeholderTextColor={Colors.textMuted}
          style={{ fontSize: FontSize.md, color: Colors.textPrimary,
            borderBottomWidth: 1, borderBottomColor: Colors.border, paddingVertical: 8 }}
        />
        <View style={{ marginTop: Spacing.md, gap: 8 }}>
          <SummaryRow label="Goal"
            value={goal === 'STRENGTH' ? 'Stronger' : 'Bigger & stronger'} />
          <SummaryRow label="Volume" value={`${weeklySets} sets / muscle / week`} />
          <SummaryRow label="Schedule" value={`${daysPerWeek}× per week · ${splitName}`} />
          <SummaryRow label="Longest session" value={`~${longestSessionMinutes} min`} />
        </View>
      </View>
      {error && (
        <InfoCard icon="warning-outline" title="Something went wrong" warning>{error}</InfoCard>
      )}
    </View>
  );
}

// ─── Add-exercise modal ───────────────────────────────────────────────────────

function AddExerciseModal({ existingIds, onSelect, onClose }: {
  existingIds: number[];
  onSelect: (ex: ExerciseResponse) => void;
  onClose: () => void;
}) {
  const [search, setSearch] = useState('');
  const { data: exercises } = useQuery({ queryKey: ['exercises'], queryFn: exercisesApi.list });

  const filtered = (exercises ?? []).filter(
    (e) => !existingIds.includes(e.id) && e.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Modal visible animationType="slide" presentationStyle="pageSheet" onRequestClose={onClose}>
      <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surface }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md,
          borderBottomWidth: 1, borderBottomColor: Colors.border }}>
          <TouchableOpacity onPress={onClose} style={{ padding: 4, marginRight: Spacing.sm }}>
            <Ionicons name="close" size={22} color={Colors.textPrimary} />
          </TouchableOpacity>
          <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>Add exercise</Text>
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
            <TouchableOpacity key={ex.id} onPress={() => onSelect(ex)}
              style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md,
                borderBottomWidth: 1, borderBottomColor: Colors.border }}>
              <View style={{ flex: 1 }}>
                <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary,
                  fontWeight: FontWeight.medium }}>{ex.name}</Text>
                <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 2 }}>
                  {ex.movementPattern === 'COMPOUND' ? 'Compound' : 'Isolation'}
                  {' · '}
                  {ex.muscles.filter((m) => m.role === 'PRIMARY')
                    .map((m) => m.muscleGroupName).join(', ')}
                </Text>
              </View>
              <Ionicons name="add-circle-outline" size={22} color={Colors.primary} />
            </TouchableOpacity>
          ))}
        </ScrollView>
      </SafeAreaView>
    </Modal>
  );
}

// ─── Shared bits ──────────────────────────────────────────────────────────────

function StepHeading({ title, body }: { title: string; body: string }) {
  return (
    <View style={{ marginBottom: Spacing.lg }}>
      <Text style={{ fontSize: FontSize.xxl, fontWeight: FontWeight.bold,
        color: Colors.textPrimary }}>{title}</Text>
      <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
        lineHeight: 21, marginTop: 6 }}>{body}</Text>
    </View>
  );
}

function InfoCard({ icon, title, children, warning }: {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  children: React.ReactNode;
  warning?: boolean;
}) {
  const color = warning ? Colors.warning : Colors.primary;
  const tint = warning ? Colors.warningTint : Colors.primaryTint;
  return (
    <View style={{ flexDirection: 'row', gap: Spacing.sm, backgroundColor: tint,
      borderRadius: Radius.md, padding: Spacing.md, marginBottom: Spacing.sm }}>
      <Ionicons name={icon} size={18} color={color} style={{ marginTop: 1 }} />
      <View style={{ flex: 1 }}>
        <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
          color: Colors.textPrimary }}>{title}</Text>
        <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
          lineHeight: 19, marginTop: 3 }}>{children}</Text>
      </View>
    </View>
  );
}

function SummaryRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={{ flexDirection: 'row', justifyContent: 'space-between', gap: Spacing.md }}>
      <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>{label}</Text>
      <Text style={{ flex: 1, fontSize: FontSize.sm, fontWeight: FontWeight.medium,
        color: Colors.textPrimary, textAlign: 'right' }}>{value}</Text>
    </View>
  );
}
