// Home dashboard
import React, { useState, useEffect } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, RefreshControl, Modal, TextInput, Alert,
  useWindowDimensions, Image,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { format, getISOWeek, getISOWeekYear } from 'date-fns';
import Svg, { Path, Defs, LinearGradient, Stop } from 'react-native-svg';
import { programsApi } from '@/services/api/programs';
import { workoutsApi } from '@/services/api/workouts';
import { progressApi } from '@/services/api/progress';
import { useAuthStore } from '@/store/useAuthStore';
import { useSettingsStore } from '@/store/useSettingsStore';
import { WorkoutTemplateResponse, BodyWeightResponse } from '@/types';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';

// ─── Trend helper ─────────────────────────────────────────────────────────────

type TrendDirection = 'up' | 'down' | 'stable' | 'none';

interface WeightTrend {
  direction: TrendDirection;
  deltaKg: number;
}

function computeWeightTrend(history: BodyWeightResponse[]): WeightTrend {
  if (history.length < 2) return { direction: 'none', deltaKg: 0 };
  // Compare latest entry to the previous one
  const latest  = history[history.length - 1];
  const prev    = history[history.length - 2];
  const deltaKg = latest.weightKg - prev.weightKg;
  const direction: TrendDirection =
    deltaKg > 0.05 ? 'up' : deltaKg < -0.05 ? 'down' : 'stable';
  return { direction, deltaKg };
}

function formatDeltaMag(deltaKg: number): string {
  const abs = Math.abs(deltaKg);
  return abs < 1
    ? `${Math.round(abs * 1000)}g`
    : `${abs.toFixed(1)}kg`;
}

/** Returns the color for the delta given optional goal context */
function getDeltaColor(
  direction: TrendDirection,
  deltaKg: number,
  goalWeight?: number,
  startWeight?: number,
): string {
  if (direction === 'stable' || direction === 'none') return Colors.textMuted;

  // No goal configured → neutral colors
  if (goalWeight === undefined || startWeight === undefined) {
    return deltaKg > 0 ? Colors.error : Colors.success;
  }

  const isMaintenance = Math.abs(goalWeight - startWeight) < 0.5;
  if (isMaintenance) return Colors.textMuted;

  const gainingGoal = goalWeight > startWeight;
  if (gainingGoal) {
    return deltaKg > 0 ? Colors.success : Colors.error;
  } else {
    return deltaKg < 0 ? Colors.success : Colors.error;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

export default function DashboardScreen() {
  const user         = useAuthStore((s) => s.user);
  const queryClient  = useQueryClient();
  const { width: windowWidth } = useWindowDimensions();
  const { weightGoal, startWeight, hydrate, isHydrated, skipped, skipWorkout } = useSettingsStore();
  const [bwModalOpen, setBwModalOpen]                         = useState(false);
  const [bwInput, setBwInput]                                 = useState('');
  const [dayPickerTemplate, setDayPickerTemplate]             = useState<WorkoutTemplateResponse | null>(null);

  useEffect(() => { if (!isHydrated) hydrate(); }, []);

  const { data: program, isLoading: programLoading, refetch } = useQuery({
    queryKey: ['activeProgram'],
    queryFn: programsApi.getActive,
  });
  const { data: sessions } = useQuery({
    queryKey: ['sessions'],
    queryFn: workoutsApi.listSessions,
  });
  const { data: bodyWeights } = useQuery({
    queryKey: ['bodyWeight'],
    queryFn: progressApi.getBodyWeightHistory,
  });

  const { mutate: logWeight } = useMutation({
    mutationFn: (kg: number) =>
      progressApi.logBodyWeight({ weightKg: kg, logDate: format(new Date(), 'yyyy-MM-dd') }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['bodyWeight'] });
      setBwModalOpen(false);
      setBwInput('');
    },
    onError: (e: any) => Alert.alert('Error', e.message),
  });

  const today   = new Date();
  const monday  = new Date(today);
  monday.setDate(today.getDate() - ((today.getDay() + 6) % 7));
  monday.setHours(0, 0, 0, 0);

  // Per-week skip: a workout cancelled "this week" disappears from the week box
  // for the current ISO week only, then returns next week.
  const weekKey = `${getISOWeekYear(monday)}-W${getISOWeek(monday)}`;
  const isSkipped = (templateId: number) => !!skipped[`${weekKey}:${templateId}`];
  const visibleTemplates = (program?.workoutTemplates ?? []).filter((t) => !isSkipped(t.id));

  const scheduledIndices = new Set(visibleTemplates.map((t) => t.dayIndex));

  const thisWeekSessions = (sessions ?? []).filter((s) => {
    const d = new Date(s.startedAt);
    return d >= monday && s.completedAt;
  });
  const todayDayIdx   = (today.getDay() + 6) % 7;
  const todayTemplate = visibleTemplates.find((t) => t.dayIndex === todayDayIdx);
  const latestWeight  = bodyWeights?.[bodyWeights.length - 1];
  const trend         = computeWeightTrend(bodyWeights ?? []);

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surfaceMuted }}>
      <ScrollView
        contentContainerStyle={{ padding: Spacing.lg, paddingBottom: 100 }}
        refreshControl={<RefreshControl refreshing={programLoading} onRefresh={refetch} />}
      >
        {/* ── Header ────────────────────────────────────────────────────────── */}
        <View style={{ flexDirection: 'row', justifyContent: 'space-between',
          alignItems: 'center', marginBottom: Spacing.lg }}>
          <View>
            <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
              {format(new Date(), 'EEEE, MMM d')}
            </Text>
            <Text style={{ fontSize: FontSize.xxl, fontWeight: FontWeight.bold,
              color: Colors.textPrimary }}>
              Hey, {user?.name?.split(' ')[0]} 👋
            </Text>
          </View>
          <TouchableOpacity
            onPress={() => router.push('/settings')}
            style={{ width: 40, height: 40, borderRadius: 20,
              backgroundColor: Colors.primaryTint, alignItems: 'center', justifyContent: 'center',
              overflow: 'hidden' }}>
            {user?.avatarUrl ? (
              <Image source={{ uri: user.avatarUrl }} style={{ width: 40, height: 40 }} />
            ) : (
              <Text style={{ fontWeight: FontWeight.bold, color: Colors.primary }}>
                {user?.name?.[0]?.toUpperCase() ?? '?'}
              </Text>
            )}
          </TouchableOpacity>
        </View>

        {/* ── Week strip ─────────────────────────────────────────────────────── */}
        {program && (
          <WeekStrip
            scheduledIndices={scheduledIndices}
            completedCount={thisWeekSessions.length}
            totalScheduled={scheduledIndices.size}
            templates={visibleTemplates}
            weekStart={monday}
            onChipPress={(tmpl) => setDayPickerTemplate(tmpl)}
          />
        )}

        {/* ── Today card ─────────────────────────────────────────────────────── */}
        {program
          ? todayTemplate
            ? <TodayCard template={todayTemplate} />
            : <RestDayCard />
          : <SetupProgramCard />}

        {/* ── Body weight ────────────────────────────────────────────────────── */}
        <BodyWeightCard
          latestWeight={latestWeight}
          history={bodyWeights ?? []}
          trend={trend}
          onLog={() => setBwModalOpen(true)}
          cardWidth={windowWidth - Spacing.lg * 2}
          weightGoal={weightGoal}
          startWeight={startWeight}
        />

        {/* ── Program overview ───────────────────────────────────────────────── */}
        {program && (
          <ProgramOverviewCard templates={program.workoutTemplates} />
        )}

        {/* ── This week sessions ─────────────────────────────────────────────── */}
        {thisWeekSessions.length > 0 && (
          <View style={{ marginTop: Spacing.lg }}>
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.semibold,
              color: Colors.textPrimary, marginBottom: Spacing.sm }}>This Week</Text>
            {thisWeekSessions.slice(0, 3).map((s) => (
              <View key={s.id} style={{
                backgroundColor: Colors.surface, borderRadius: Radius.lg,
                padding: Spacing.md, marginBottom: Spacing.sm, ...Shadow.card,
                flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
              }}>
                <View>
                  <Text style={{ fontWeight: FontWeight.medium, color: Colors.textPrimary }}>
                    {s.templateName ?? 'Workout'}
                  </Text>
                  <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
                    {format(new Date(s.startedAt), 'EEE, MMM d')}
                  </Text>
                </View>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                  <Ionicons name="checkmark-circle" size={18} color={Colors.success} />
                  <Text style={{ fontSize: FontSize.sm, color: Colors.success }}>Done</Text>
                </View>
              </View>
            ))}
          </View>
        )}
      </ScrollView>

      {/* ── Day picker modal ──────────────────────────────────────────────────── */}
      {dayPickerTemplate && (
        <DayPickerModal
          template={dayPickerTemplate}
          onClose={() => setDayPickerTemplate(null)}
          onSave={(newDay) => {
            workoutsApi.updateTemplate(dayPickerTemplate.id, { dayIndex: newDay })
              .then(() => {
                queryClient.invalidateQueries({ queryKey: ['activeProgram'] });
                queryClient.invalidateQueries({ queryKey: ['programs'] });
              })
              .catch(() => {})
              .finally(() => setDayPickerTemplate(null));
          }}
          onSkipThisWeek={() => {
            skipWorkout(weekKey, dayPickerTemplate.id);
            setDayPickerTemplate(null);
          }}
        />
      )}

      {/* ── Log body weight modal ──────────────────────────────────────────────── */}
      <Modal visible={bwModalOpen} animationType="slide" transparent>
        <View style={{ flex: 1, justifyContent: 'flex-end', backgroundColor: 'rgba(0,0,0,0.3)' }}>
          <View style={{ backgroundColor: Colors.surface, borderTopLeftRadius: Radius.xl,
            borderTopRightRadius: Radius.xl, padding: Spacing.lg, paddingBottom: 40 }}>
            <Text style={{ fontSize: FontSize.xl, fontWeight: FontWeight.bold,
              color: Colors.textPrimary, marginBottom: Spacing.md }}>Log Body Weight</Text>
            <TextInput
              value={bwInput}
              onChangeText={setBwInput}
              placeholder="e.g. 84.5"
              placeholderTextColor={Colors.textMuted}
              keyboardType="decimal-pad"
              autoFocus
              style={{
                backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
                padding: Spacing.md, fontSize: FontSize.xl, color: Colors.textPrimary,
                textAlign: 'center', borderWidth: 1, borderColor: Colors.border,
                fontWeight: FontWeight.bold,
              }}
            />
            <Text style={{ textAlign: 'center', color: Colors.textMuted,
              fontSize: FontSize.sm, marginTop: 6 }}>kg</Text>
            <TouchableOpacity
              onPress={() => {
                const kg = parseFloat(bwInput);
                if (!kg || kg < 20 || kg > 300) {
                  Alert.alert('Invalid weight', 'Enter a weight between 20 and 300 kg.');
                  return;
                }
                logWeight(kg);
              }}
              style={{ backgroundColor: Colors.primary, borderRadius: Radius.md,
                paddingVertical: 16, alignItems: 'center', marginTop: Spacing.md }}>
              <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                fontSize: FontSize.md }}>Save</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => setBwModalOpen(false)}
              style={{ alignItems: 'center', marginTop: Spacing.sm, paddingVertical: 8 }}>
              <Text style={{ color: Colors.textSecondary }}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

// ─── Week strip ───────────────────────────────────────────────────────────────

function WeekStrip({ scheduledIndices, completedCount, totalScheduled, templates, weekStart, onChipPress }: {
  scheduledIndices: Set<number>;
  completedCount: number;
  totalScheduled: number;
  templates: WorkoutTemplateResponse[];
  weekStart: Date;
  onChipPress: (template: WorkoutTemplateResponse) => void;
}) {
  const DAY_ABBR = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const todayIdx = (new Date().getDay() + 6) % 7;
  const progress = totalScheduled > 0 ? completedCount / totalScheduled : 0;
  const days     = Array.from(scheduledIndices).sort((a, b) => a - b);
  const isoWeek  = getISOWeek(weekStart);

  const dateForDayIdx = (idx: number): Date => {
    const d = new Date(weekStart);
    d.setDate(weekStart.getDate() + idx);
    return d;
  };

  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      padding: Spacing.md, marginBottom: Spacing.md, ...Shadow.card }}>
      {/* Top row: label + week number */}
      <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
        marginBottom: Spacing.sm }}>
        <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary,
          fontWeight: FontWeight.medium }}>This Week</Text>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
          <View style={{ backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
            paddingHorizontal: 8, paddingVertical: 2 }}>
            <Text style={{ fontSize: 10, color: Colors.primary,
              fontWeight: FontWeight.semibold }}>Week {isoWeek}</Text>
          </View>
        </View>
      </View>

      {/* Day chips — tappable to reschedule */}
      <View style={{ flexDirection: 'row', justifyContent: 'space-around',
        marginBottom: Spacing.sm }}>
        {days.map((idx) => {
          const isToday   = idx === todayIdx;
          const tmpl      = templates.find((t) => t.dayIndex === idx);
          const chipLabel = tmpl ? tmpl.name.split(' ').slice(0, 2).join(' ') : DAY_ABBR[idx];
          const dayDate   = dateForDayIdx(idx);

          return (
            <TouchableOpacity
              key={idx}
              onPress={() => tmpl && onChipPress(tmpl)}
              activeOpacity={tmpl ? 0.7 : 1}
              style={{ alignItems: 'center', gap: 3 }}>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>
                {DAY_ABBR[idx]}
              </Text>
              <View style={{
                minWidth: 48, paddingHorizontal: 6, paddingVertical: 6,
                borderRadius: Radius.md, alignItems: 'center', justifyContent: 'center',
                backgroundColor: isToday ? Colors.primary : Colors.primaryTint,
                borderWidth: isToday ? 0 : 1.5,
                borderColor: isToday ? 'transparent' : Colors.primary,
              }}>
                <Text style={{ fontSize: 10, fontWeight: FontWeight.bold, textAlign: 'center',
                  color: isToday ? Colors.textInverse : Colors.primary }}>
                  {chipLabel}
                </Text>
              </View>
              <Text style={{ fontSize: 9, color: isToday ? Colors.primary : Colors.textMuted,
                fontWeight: isToday ? FontWeight.semibold : FontWeight.regular }}>
                {format(dayDate, 'MMM d')}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>

      {/* Progress bar */}
      <View style={{ height: 4, backgroundColor: Colors.surfaceSubtle,
        borderRadius: 2, overflow: 'hidden' }}>
        <View style={{ height: 4, width: `${progress * 100}%`,
          backgroundColor: Colors.success, borderRadius: 2 }} />
      </View>
      <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary,
        marginTop: 4, textAlign: 'right' }}>{completedCount}/{totalScheduled} this week</Text>
    </View>
  );
}

// ─── Day picker modal ─────────────────────────────────────────────────────────

function DayPickerModal({ template, onClose, onSave, onSkipThisWeek }: {
  template: WorkoutTemplateResponse;
  onClose: () => void;
  onSave: (dayIndex: number) => void;
  onSkipThisWeek: () => void;
}) {
  const DAY_NAMES = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const [selected, setSelected] = useState(template.dayIndex);

  return (
    <Modal visible transparent animationType="fade">
      <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.45)',
        justifyContent: 'center', alignItems: 'center', padding: Spacing.lg }}>
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          padding: Spacing.lg, width: '100%', maxWidth: 340, ...Shadow.float }}>
          <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
            color: Colors.textPrimary, marginBottom: 4 }}>{template.name}</Text>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
            marginBottom: Spacing.md }}>Move to a different day of the week</Text>

          {DAY_NAMES.map((name, idx) => {
            const isSelected = idx === selected;
            return (
              <TouchableOpacity key={idx} onPress={() => setSelected(idx)}
                style={{ flexDirection: 'row', alignItems: 'center',
                  paddingVertical: 11, paddingHorizontal: Spacing.sm,
                  borderRadius: Radius.md, marginBottom: 4,
                  backgroundColor: isSelected ? Colors.primaryTint : 'transparent' }}>
                <View style={{ width: 22, height: 22, borderRadius: 11,
                  borderWidth: 2,
                  borderColor: isSelected ? Colors.primary : Colors.border,
                  backgroundColor: isSelected ? Colors.primary : 'transparent',
                  alignItems: 'center', justifyContent: 'center', marginRight: Spacing.md }}>
                  {isSelected && <Ionicons name="checkmark" size={13} color={Colors.textInverse} />}
                </View>
                <Text style={{ fontSize: FontSize.md,
                  color: isSelected ? Colors.primary : Colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.semibold : FontWeight.regular }}>
                  {name}
                </Text>
              </TouchableOpacity>
            );
          })}

          <View style={{ flexDirection: 'row', gap: Spacing.sm, marginTop: Spacing.md }}>
            <TouchableOpacity onPress={onClose}
              style={{ flex: 1, borderRadius: Radius.md, paddingVertical: 13,
                alignItems: 'center', borderWidth: 1, borderColor: Colors.border }}>
              <Text style={{ color: Colors.textSecondary, fontWeight: FontWeight.medium }}>Cancel</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => onSave(selected)}
              disabled={selected === template.dayIndex}
              style={{ flex: 1, borderRadius: Radius.md, paddingVertical: 13,
                alignItems: 'center',
                backgroundColor: selected === template.dayIndex ? Colors.surfaceSubtle : Colors.primary }}>
              <Text style={{ color: selected === template.dayIndex ? Colors.textMuted : Colors.textInverse,
                fontWeight: FontWeight.semibold }}>Save</Text>
            </TouchableOpacity>
          </View>

          {/* Cancel just this week — chip returns next week */}
          <TouchableOpacity
            onPress={onSkipThisWeek}
            style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
              gap: 6, marginTop: Spacing.sm, paddingVertical: 11, borderRadius: Radius.md,
              borderWidth: 1, borderColor: Colors.errorTint, backgroundColor: Colors.errorTint }}>
            <Ionicons name="close-circle-outline" size={16} color={Colors.error} />
            <Text style={{ color: Colors.error, fontWeight: FontWeight.medium, fontSize: FontSize.sm }}>
              Cancel this week
            </Text>
          </TouchableOpacity>
          <Text style={{ fontSize: 10, color: Colors.textMuted, textAlign: 'center', marginTop: 4 }}>
            Removes it from this week only — it returns next week.
          </Text>
        </View>
      </View>
    </Modal>
  );
}

// ─── Body weight SVG sparkline ────────────────────────────────────────────────

function BodyWeightLineGraph({ data, width }: { data: BodyWeightResponse[]; width: number }) {
  if (data.length < 2) return null;

  const W = width;
  const H = 100;
  const padT = 10; const padB = 4;

  const vals = data.map((d) => d.weightKg);
  const min  = Math.min(...vals) - 0.5;
  const max  = Math.max(...vals) + 0.5;
  const rng  = max - min || 1;
  const n    = data.length;

  const xOf = (i: number) => (i / (n - 1)) * W;
  const yOf = (v: number) => padT + (1 - (v - min) / rng) * (H - padT - padB);

  const pts = data.map((d, i) => ({ x: xOf(i), y: yOf(d.weightKg) }));

  let linePath = `M ${pts[0].x.toFixed(1)} ${pts[0].y.toFixed(1)}`;
  for (let i = 0; i < pts.length - 1; i++) {
    const dx   = (pts[i + 1].x - pts[i].x) * 0.4;
    const cp1x = pts[i].x + dx;
    const cp1y = pts[i].y;
    const cp2x = pts[i + 1].x - dx;
    const cp2y = pts[i + 1].y;
    linePath += ` C ${cp1x.toFixed(1)} ${cp1y.toFixed(1)},${cp2x.toFixed(1)} ${cp2y.toFixed(1)},${pts[i + 1].x.toFixed(1)} ${pts[i + 1].y.toFixed(1)}`;
  }

  const fillPath = `${linePath} L ${pts[pts.length - 1].x.toFixed(1)} ${H} L 0 ${H} Z`;

  return (
    <Svg width={W} height={H}>
      <Defs>
        <LinearGradient id="bwGrad" x1="0" y1="0" x2="0" y2="1">
          <Stop offset="0%" stopColor={Colors.primary} stopOpacity={0.22} />
          <Stop offset="100%" stopColor={Colors.primary} stopOpacity={0.03} />
        </LinearGradient>
      </Defs>
      <Path d={fillPath} fill="url(#bwGrad)" />
      <Path d={linePath} stroke={Colors.primary} strokeWidth={2.5}
        fill="none" strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

// ─── Body weight card ─────────────────────────────────────────────────────────

function BodyWeightCard({ latestWeight, history, trend, onLog, cardWidth, weightGoal, startWeight }: {
  latestWeight: BodyWeightResponse | undefined;
  history: BodyWeightResponse[];
  trend: WeightTrend;
  onLog: () => void;
  cardWidth: number;
  weightGoal?: number;
  startWeight?: number;
}) {
  const { direction, deltaKg } = trend;
  const trendIcon  = direction === 'up' ? 'trending-up'
    : direction === 'down' ? 'trending-down' : 'remove-outline';
  const deltaColor = getDeltaColor(direction, deltaKg, weightGoal, startWeight);
  const trendLabel = direction === 'up' ? 'Gaining'
    : direction === 'down' ? 'Losing' : direction === 'stable' ? 'Stable' : '';
  const deltaMag  = direction !== 'none' ? formatDeltaMag(deltaKg) : '';
  const arrowIcon = deltaKg >= 0 ? 'arrow-up' : 'arrow-down';
  const graphData = history.slice(-28);

  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      marginTop: Spacing.sm, ...Shadow.card, overflow: 'hidden' }}>

      {/* Padded content */}
      <View style={{ padding: Spacing.md }}>
        {/* Header */}
        <View style={{ flexDirection: 'row', alignItems: 'center',
          justifyContent: 'space-between', marginBottom: Spacing.sm }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
            <Ionicons name="body-outline" size={16} color={Colors.textSecondary} />
            <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
              fontWeight: FontWeight.medium }}>Body Weight</Text>
          </View>
          <TouchableOpacity onPress={onLog}
            style={{ flexDirection: 'row', alignItems: 'center', gap: 4,
              backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
              paddingHorizontal: 10, paddingVertical: 4 }}>
            <Ionicons name="add" size={12} color={Colors.primary} />
            <Text style={{ fontSize: FontSize.xs, color: Colors.primary,
              fontWeight: FontWeight.medium }}>Log</Text>
          </TouchableOpacity>
        </View>

        {latestWeight ? (
          <View style={{ flexDirection: 'row', alignItems: 'flex-end',
            justifyContent: 'space-between' }}>
            <View>
              <View style={{ flexDirection: 'row', alignItems: 'baseline', gap: 4 }}>
                <Text style={{ fontSize: FontSize.display, fontWeight: FontWeight.bold,
                  color: Colors.textPrimary }}>{latestWeight.weightKg}</Text>
                <Text style={{ fontSize: FontSize.md, color: Colors.textSecondary }}>kg</Text>
              </View>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>
                {format(new Date(latestWeight.logDate), 'MMM d')}
              </Text>
              {weightGoal !== undefined && (
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 4 }}>
                  <Ionicons name="flag-outline" size={11} color={Colors.primary} />
                  <Text style={{ fontSize: FontSize.xs, color: Colors.primary,
                    fontWeight: FontWeight.medium }}>
                    Goal {weightGoal}kg
                    {Math.abs(latestWeight.weightKg - weightGoal) >= 0.1
                      ? ` · ${Math.abs(latestWeight.weightKg - weightGoal).toFixed(1)}kg to go`
                      : ' · reached 🎉'}
                  </Text>
                </View>
              )}
            </View>

            {direction !== 'none' && (
              <View style={{ alignItems: 'flex-end' }}>
                {/* Trend badge */}
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4,
                  backgroundColor: direction === 'stable'
                    ? Colors.surfaceSubtle
                    : deltaColor === Colors.success ? Colors.successTint : Colors.errorTint,
                  borderRadius: Radius.full, paddingHorizontal: 10, paddingVertical: 5 }}>
                  <Ionicons name={trendIcon as any} size={14} color={deltaColor} />
                  <Text style={{ fontSize: FontSize.xs, color: deltaColor,
                    fontWeight: FontWeight.semibold }}>{trendLabel}</Text>
                </View>
                {/* Arrow + magnitude */}
                {deltaMag ? (
                  <View style={{ flexDirection: 'row', alignItems: 'center',
                    gap: 2, marginTop: 3 }}>
                    <Ionicons name={arrowIcon as any} size={10} color={deltaColor} />
                    <Text style={{ fontSize: 10, color: deltaColor }}>
                      {deltaMag} vs last week
                    </Text>
                  </View>
                ) : null}
              </View>
            )}
          </View>
        ) : (
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
            No weight logged yet. Tap Log to start.
          </Text>
        )}
      </View>

      {/* Full-width graph — no side padding, sits flush at bottom of card */}
      {latestWeight && graphData.length >= 2 && (
        <BodyWeightLineGraph data={graphData} width={cardWidth} />
      )}
    </View>
  );
}

// ─── Today's workout card ─────────────────────────────────────────────────────

function TodayCard({ template }: { template: WorkoutTemplateResponse }) {
  const muscles = [
    ...new Set(
      template.exercises
        .flatMap((te) => te.exercise.muscles.filter((m) => m.role === 'PRIMARY'))
        .map((m) => m.muscleGroupName)
    ),
  ].slice(0, 5);

  const startWorkout = () => router.push({
    pathname: '/workout/start',
    params: { templateId: String(template.id) },
  });

  return (
    <TouchableOpacity
      activeOpacity={0.85}
      onPress={startWorkout}
      style={{ borderRadius: Radius.lg, marginBottom: Spacing.md,
        overflow: 'hidden', ...Shadow.card }}>
      {/* Gradient background */}
      <View style={{ backgroundColor: Colors.primary, padding: Spacing.md }}>
        <View style={{ flexDirection: 'row', alignItems: 'center',
          justifyContent: 'space-between', marginBottom: Spacing.sm }}>
          <View>
            <Text style={{ fontSize: FontSize.xs, color: Colors.primaryLight,
              fontWeight: FontWeight.medium, textTransform: 'uppercase',
              letterSpacing: 0.5 }}>Today · Tap to start</Text>
            <Text style={{ fontSize: FontSize.xl, fontWeight: FontWeight.bold,
              color: Colors.textInverse, marginTop: 2 }}>{template.name}</Text>
          </View>
          <View style={{ width: 44, height: 44, borderRadius: 22,
            backgroundColor: 'rgba(255,255,255,0.2)', alignItems: 'center',
            justifyContent: 'center' }}>
            <Ionicons name="play" size={22} color={Colors.textInverse} />
          </View>
        </View>

        {/* Muscle chips */}
        {muscles.length > 0 && (
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginBottom: Spacing.sm }}>
            {muscles.map((m) => (
              <View key={m} style={{ backgroundColor: 'rgba(255,255,255,0.15)',
                borderRadius: Radius.full, paddingHorizontal: 10, paddingVertical: 4 }}>
                <Text style={{ fontSize: FontSize.xs, color: Colors.textInverse }}>{m}</Text>
              </View>
            ))}
          </View>
        )}
      </View>
    </TouchableOpacity>
  );
}

// ─── Rest day card ────────────────────────────────────────────────────────────

function RestDayCard() {
  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      padding: Spacing.md, marginBottom: Spacing.md, ...Shadow.card,
      flexDirection: 'row', alignItems: 'center', gap: Spacing.md }}>
      <View style={{ width: 44, height: 44, borderRadius: 22,
        backgroundColor: Colors.successTint, alignItems: 'center', justifyContent: 'center' }}>
        <Ionicons name="bed-outline" size={22} color={Colors.success} />
      </View>
      <View style={{ flex: 1 }}>
        <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
          color: Colors.textPrimary }}>Rest Day</Text>
        <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
          Recovery is part of the program. See you tomorrow.
        </Text>
      </View>
    </View>
  );
}

// ─── Setup program card ───────────────────────────────────────────────────────

function SetupProgramCard() {
  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      padding: Spacing.md, marginBottom: Spacing.md, ...Shadow.card }}>
      <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
        color: Colors.textPrimary, marginBottom: 4 }}>No active program</Text>
      <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary,
        marginBottom: Spacing.md }}>
        Create a program to start tracking your workouts.
      </Text>
      <TouchableOpacity
        onPress={() => router.push('/program/setup')}
        style={{ backgroundColor: Colors.primary, borderRadius: Radius.md,
          paddingVertical: 12, alignItems: 'center' }}>
        <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold }}>
          Create Program
        </Text>
      </TouchableOpacity>
    </View>
  );
}

// ─── Program overview card ────────────────────────────────────────────────────

function ProgramOverviewCard({ templates }: { templates: WorkoutTemplateResponse[] }) {
  const DAY_ABBR = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      padding: Spacing.md, marginTop: Spacing.sm, ...Shadow.card }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6,
        marginBottom: Spacing.sm }}>
        <Ionicons name="calendar-outline" size={16} color={Colors.textSecondary} />
        <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.medium,
          color: Colors.textSecondary }}>Weekly Schedule</Text>
      </View>
      {templates.sort((a, b) => a.dayIndex - b.dayIndex).map((t) => (
        <View key={t.id} style={{ flexDirection: 'row', alignItems: 'center',
          paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
          <View style={{ width: 36, height: 36, borderRadius: 18,
            backgroundColor: Colors.primaryTint, alignItems: 'center', justifyContent: 'center',
            marginRight: Spacing.md }}>
            <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.bold,
              color: Colors.primary }}>{DAY_ABBR[t.dayIndex]}</Text>
          </View>
          <View style={{ flex: 1 }}>
            <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.medium,
              color: Colors.textPrimary }}>{t.name}</Text>
            <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>
              {t.exercises.length} exercise{t.exercises.length !== 1 ? 's' : ''}
            </Text>
          </View>
        </View>
      ))}
    </View>
  );
}
