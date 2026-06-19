import React from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, RefreshControl,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useQuery, useQueries } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { format, startOfMonth, getDaysInMonth, addMonths, subMonths } from 'date-fns';
import { programsApi } from '@/services/api/programs';
import { workoutsApi } from '@/services/api/workouts';
import { ProgramResponse, WorkoutSessionResponse } from '@/types';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';

const DAY_LABELS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

export default function WorkoutsScreen() {
  const { data: program, isLoading, refetch } = useQuery({
    queryKey: ['activeProgram'],
    queryFn: programsApi.getActive,
  });

  const { data: sessions } = useQuery({
    queryKey: ['sessions'],
    queryFn: workoutsApi.listSessions,
  });

  const eightDaysAgo = new Date();
  eightDaysAgo.setDate(eightDaysAgo.getDate() - 8);
  const recentSessions = (sessions ?? []).filter((s) => new Date(s.startedAt) >= eightDaysAgo);

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surfaceMuted }}>
      <ScrollView contentContainerStyle={{ padding: Spacing.lg, paddingBottom: 100 }}
        refreshControl={<RefreshControl refreshing={isLoading} onRefresh={refetch} />}>

        <View style={{ flexDirection: 'row', justifyContent: 'space-between',
          alignItems: 'center', marginBottom: Spacing.lg }}>
          <Text style={{ fontSize: FontSize.xxl, fontWeight: FontWeight.bold,
            color: Colors.textPrimary }}>Workouts</Text>
          <TouchableOpacity onPress={() => router.push('/program/setup')}
            style={{ flexDirection: 'row', alignItems: 'center', gap: 4,
              backgroundColor: Colors.primaryTint, paddingHorizontal: 12,
              paddingVertical: 8, borderRadius: Radius.full }}>
            <Ionicons name="add" size={16} color={Colors.primary} />
            <Text style={{ fontSize: FontSize.sm, color: Colors.primary,
              fontWeight: FontWeight.medium }}>New Program</Text>
          </TouchableOpacity>
        </View>

        {/* Active program schedule */}
        {program ? (
          <>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between',
              alignItems: 'center', marginBottom: Spacing.sm }}>
              <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.semibold,
                color: Colors.textPrimary }}>{program.name}</Text>
              <View style={{ flexDirection: 'row', gap: 4, alignItems: 'center' }}>
                <View style={{ width: 8, height: 8, borderRadius: 4,
                  backgroundColor: Colors.success }} />
                <Text style={{ fontSize: FontSize.xs, color: Colors.success }}>Active</Text>
              </View>
            </View>

            {program.workoutTemplates.map((template) => (
              <TouchableOpacity
                key={template.id}
                onPress={() => router.push({
                  pathname: '/workout/start',
                  params: { templateId: template.id },
                })}
                style={{
                  backgroundColor: Colors.surface, borderRadius: Radius.lg,
                  padding: Spacing.md, marginBottom: Spacing.sm, ...Shadow.card,
                  flexDirection: 'row', alignItems: 'center',
                }}
              >
                {/* Day badge */}
                <View style={{
                  width: 44, height: 44, borderRadius: Radius.md, backgroundColor: Colors.primaryTint,
                  alignItems: 'center', justifyContent: 'center', marginRight: Spacing.md,
                }}>
                  <Text style={{ fontSize: FontSize.xs, color: Colors.primary,
                    fontWeight: FontWeight.bold }}>{DAY_LABELS[template.dayIndex]}</Text>
                </View>

                <View style={{ flex: 1 }}>
                  <Text style={{ fontWeight: FontWeight.semibold, color: Colors.textPrimary,
                    fontSize: FontSize.md }}>{template.name}</Text>
                  <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 }}>
                    {template.exercises.length} exercises · {template.exercises
                      .reduce((acc, e) => acc + e.sets, 0)} sets
                  </Text>
                </View>
                <Ionicons name="chevron-forward" size={18} color={Colors.textMuted} />
              </TouchableOpacity>
            ))}
          </>
        ) : (
          <View style={{ alignItems: 'center', paddingVertical: Spacing.xxl }}>
            <Ionicons name="barbell-outline" size={48} color={Colors.textMuted} />
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.semibold,
              color: Colors.textPrimary, marginTop: Spacing.md }}>No Active Program</Text>
            <Text style={{ fontSize: FontSize.md, color: Colors.textSecondary, marginTop: 4,
              textAlign: 'center' }}>
              Create a program to get your personalised training week.
            </Text>
            <TouchableOpacity onPress={() => router.push('/program/setup')}
              style={{ backgroundColor: Colors.primary, borderRadius: Radius.md,
                paddingVertical: 12, paddingHorizontal: Spacing.xl, marginTop: Spacing.lg }}>
              <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold }}>
                Create Program
              </Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Program insights — between the program and recent sessions */}
        {program && (
          <ProgramDetailsCard program={program} sessions={sessions ?? []} />
        )}

        {/* Workout log — calendar to browse any past day */}
        {sessions && sessions.length > 0 && (
          <WorkoutCalendar sessions={sessions} />
        )}

        {/* Recent sessions — last 8 days */}
        {recentSessions.length > 0 && (
          <>
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.semibold,
              color: Colors.textPrimary, marginTop: Spacing.xl, marginBottom: 2 }}>
              Recent Sessions
            </Text>
            <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginBottom: Spacing.sm }}>
              Last 8 days · tap to review
            </Text>
            {recentSessions.map((s) => {
              const inProgress = !s.completedAt;
              return (
                <TouchableOpacity
                  key={s.id}
                  onPress={() => (inProgress
                    ? router.push({ pathname: '/workout/start', params: { templateId: s.templateId ?? '', sessionId: s.id } })
                    : router.push({ pathname: '/workout/view', params: { sessionId: String(s.id) } }))}
                  style={{
                    backgroundColor: Colors.surface, borderRadius: Radius.lg,
                    padding: Spacing.md, marginBottom: Spacing.sm, ...Shadow.card,
                    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
                    ...(inProgress ? { borderWidth: 1, borderColor: Colors.warning } : {}),
                  }}
                >
                  <View style={{ flex: 1 }}>
                    <Text style={{ fontWeight: FontWeight.medium, color: Colors.textPrimary }}>
                      {s.templateName ?? 'Custom Workout'}
                    </Text>
                    <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
                      {format(new Date(s.startedAt), 'EEE, MMM d · h:mm a')}
                    </Text>
                  </View>
                  {s.completedAt
                    ? <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                        <Ionicons name="checkmark-circle" size={20} color={Colors.success} />
                        <Ionicons name="chevron-forward" size={16} color={Colors.textMuted} />
                      </View>
                    : <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                        <View style={{ backgroundColor: Colors.warningTint, paddingHorizontal: 8,
                          paddingVertical: 3, borderRadius: Radius.full }}>
                          <Text style={{ fontSize: FontSize.xs, color: Colors.warning }}>In Progress</Text>
                        </View>
                        <Ionicons name="chevron-forward" size={16} color={Colors.warning} />
                      </View>
                  }
                </TouchableOpacity>
              );
            })}
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

// ─── Program insights / details ───────────────────────────────────────────────

function ProgramDetailsCard({ program, sessions }: {
  program: ProgramResponse;
  sessions: WorkoutSessionResponse[];
}) {
  // ── Weekly sets + training frequency per muscle group (primary movers) ──
  const setsByMuscle: Record<string, number> = {};
  const daysByMuscle: Record<string, Set<number>> = {};
  for (const t of program.workoutTemplates) {
    for (const te of t.exercises) {
      for (const m of te.exercise.muscles.filter((mu) => mu.role === 'PRIMARY')) {
        setsByMuscle[m.muscleGroupName] = (setsByMuscle[m.muscleGroupName] ?? 0) + te.sets;
        (daysByMuscle[m.muscleGroupName] ??= new Set()).add(t.dayIndex);
      }
    }
  }
  const muscleRows = Object.keys(setsByMuscle)
    .map((name) => ({ name, sets: setsByMuscle[name], freq: daysByMuscle[name].size }))
    .sort((a, b) => b.sets - a.sets);

  // ── Average completed-workout duration ──
  const completed = sessions.filter((s) => s.completedAt);
  const durations = completed
    .map((s) => (new Date(s.completedAt as string).getTime() - new Date(s.startedAt).getTime()) / 60000)
    .filter((d) => d > 0 && d < 300);
  const avgMins = durations.length
    ? Math.round(durations.reduce((a, b) => a + b, 0) / durations.length)
    : null;

  // ── Strength trend from per-session training volume (recent completed) ──
  const recent = completed.slice(0, 8); // sessions arrive newest-first
  const detailQueries = useQueries({
    queries: recent.map((s) => ({
      queryKey: ['sessionDetail', s.id],
      queryFn: () => workoutsApi.getSession(s.id),
      staleTime: 60_000,
    })),
  });
  const volumes = detailQueries
    .map((q, i) => {
      const d = q.data as WorkoutSessionResponse | undefined;
      if (!d) return null;
      let vol = 0;
      for (const ex of d.exercises) {
        for (const st of ex.sets) {
          if (st.weightKg != null) vol += st.weightKg * st.reps;
        }
      }
      return { date: new Date(recent[i].startedAt).getTime(), vol };
    })
    .filter((v): v is { date: number; vol: number } => v != null && v.vol > 0)
    .sort((a, b) => a.date - b.date); // oldest -> newest

  const loadingTrend = detailQueries.some((q) => q.isLoading);
  let trend: 'up' | 'down' | 'flat' | 'none' = 'none';
  let trendPct = 0;
  if (volumes.length >= 2) {
    const half = Math.floor(volumes.length / 2);
    const older = volumes.slice(0, half);
    const newer = volumes.slice(half);
    const avgOld = older.reduce((a, b) => a + b.vol, 0) / older.length;
    const avgNew = newer.reduce((a, b) => a + b.vol, 0) / newer.length;
    trendPct = avgOld > 0 ? ((avgNew - avgOld) / avgOld) * 100 : 0;
    trend = trendPct > 3 ? 'up' : trendPct < -3 ? 'down' : 'flat';
  }
  const maxVol = Math.max(1, ...volumes.map((v) => v.vol));

  const trendColor = trend === 'up' ? Colors.success
    : trend === 'down' ? Colors.error : Colors.textMuted;
  const trendLabel = trend === 'up' ? 'Getting stronger'
    : trend === 'down' ? 'Getting weaker'
    : trend === 'flat' ? 'Holding steady' : 'Not enough data';
  const trendIcon = trend === 'up' ? 'trending-up'
    : trend === 'down' ? 'trending-down' : 'remove-outline';

  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      padding: Spacing.md, marginTop: Spacing.lg, ...Shadow.card }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: Spacing.sm }}>
        <Ionicons name="analytics-outline" size={16} color={Colors.textSecondary} />
        <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
          color: Colors.textSecondary }}>Program Insights</Text>
      </View>

      {/* Top stats: training days + avg duration + strength trend */}
      <View style={{ flexDirection: 'row', gap: Spacing.sm, marginBottom: Spacing.md }}>
        <StatTile
          label="Days / week"
          value={String(program.strengthDaysPerWeek)}
          icon="calendar-outline" />
        <StatTile
          label="Avg workout"
          value={avgMins != null ? `${avgMins}m` : '-'}
          icon="time-outline" />
        <View style={{ flex: 1, backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
          padding: Spacing.sm, alignItems: 'center' }}>
          <Ionicons name={trendIcon as any} size={18} color={trendColor} />
          <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.bold, color: trendColor,
            marginTop: 2 }}>
            {trend === 'up' ? `+${Math.round(trendPct)}%`
              : trend === 'down' ? `${Math.round(trendPct)}%`
              : trend === 'flat' ? '+-0%' : '-'}
          </Text>
          <Text style={{ fontSize: 9, color: Colors.textMuted }}>strength</Text>
        </View>
      </View>

      {/* Strength trend explanation + mini volume bars */}
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: 6 }}>
        <Ionicons name={trendIcon as any} size={14} color={trendColor} />
        <Text style={{ fontSize: FontSize.xs, color: trendColor, fontWeight: FontWeight.semibold }}>
          {loadingTrend && volumes.length === 0 ? 'Analysing...' : trendLabel}
        </Text>
        {volumes.length >= 2 && (
          <Text style={{ fontSize: 10, color: Colors.textMuted }}>· by training volume</Text>
        )}
      </View>
      {volumes.length >= 2 && (
        <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 3, height: 36,
          marginBottom: Spacing.md }}>
          {volumes.map((v, i) => (
            <View key={i} style={{ flex: 1, height: `${Math.max(8, (v.vol / maxVol) * 100)}%`,
              backgroundColor: i === volumes.length - 1 ? trendColor : Colors.primaryTint,
              borderRadius: 2 }} />
          ))}
        </View>
      )}

      {/* Weekly sets + frequency per muscle group */}
      <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, fontWeight: FontWeight.medium,
        marginBottom: 6 }}>WEEKLY SETS · FREQUENCY PER MUSCLE</Text>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
        {muscleRows.map((m) => (
          <View key={m.name} style={{ width: '50%', flexDirection: 'row',
            justifyContent: 'space-between', alignItems: 'center', paddingVertical: 3, paddingRight: Spacing.sm }}>
            <Text style={{ fontSize: FontSize.xs, color: Colors.textPrimary }} numberOfLines={1}>
              {m.name}
            </Text>
            <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary,
              fontWeight: FontWeight.medium, fontVariant: ['tabular-nums'] }}>
              {m.sets} · {m.freq}x
            </Text>
          </View>
        ))}
      </View>
    </View>
  );
}

function StatTile({ label, value, icon }: { label: string; value: string; icon: string }) {
  return (
    <View style={{ flex: 1, backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
      padding: Spacing.sm, alignItems: 'center' }}>
      <Ionicons name={icon as any} size={18} color={Colors.primary} />
      <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.bold, color: Colors.textPrimary,
        marginTop: 2 }}>{value}</Text>
      <Text style={{ fontSize: 9, color: Colors.textMuted }}>{label}</Text>
    </View>
  );
}

// ─── Workout log calendar ─────────────────────────────────────────────────────

function WorkoutCalendar({ sessions }: { sessions: WorkoutSessionResponse[] }) {
  const [month, setMonth] = React.useState(startOfMonth(new Date()));

  // Map each day -> a completed session (latest that day)
  const byDay: Record<string, WorkoutSessionResponse> = {};
  for (const s of sessions) {
    if (!s.completedAt) continue;
    const key = format(new Date(s.startedAt), 'yyyy-MM-dd');
    const ex = byDay[key];
    if (!ex || new Date(s.startedAt) > new Date(ex.startedAt)) byDay[key] = s;
  }

  const daysInMonth = getDaysInMonth(month);
  const firstDow = (startOfMonth(month).getDay() + 6) % 7; // 0 = Monday
  const cells: (Date | null)[] = [];
  for (let i = 0; i < firstDow; i++) cells.push(null);
  for (let d = 1; d <= daysInMonth; d++) cells.push(new Date(month.getFullYear(), month.getMonth(), d));
  while (cells.length % 7 !== 0) cells.push(null);

  const today = new Date();
  const isToday = (d: Date) => d.toDateString() === today.toDateString();
  const WEEK = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      padding: Spacing.md, marginTop: Spacing.lg, ...Shadow.card }}>
      {/* Header */}
      <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
        marginBottom: Spacing.sm }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
          <Ionicons name="calendar-outline" size={16} color={Colors.textSecondary} />
          <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
            color: Colors.textSecondary }}>Workout Log</Text>
        </View>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
          <TouchableOpacity onPress={() => setMonth((m) => subMonths(m, 1))} style={{ padding: 4 }}>
            <Ionicons name="chevron-back" size={18} color={Colors.textSecondary} />
          </TouchableOpacity>
          <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary, minWidth: 112, textAlign: 'center' }}>
            {format(month, 'MMMM yyyy')}
          </Text>
          <TouchableOpacity onPress={() => setMonth((m) => addMonths(m, 1))} style={{ padding: 4 }}>
            <Ionicons name="chevron-forward" size={18} color={Colors.textSecondary} />
          </TouchableOpacity>
        </View>
      </View>

      {/* Weekday labels */}
      <View style={{ flexDirection: 'row', marginBottom: 4 }}>
        {WEEK.map((w, i) => (
          <Text key={i} style={{ flex: 1, textAlign: 'center', fontSize: 10,
            color: Colors.textMuted, fontWeight: FontWeight.medium }}>{w}</Text>
        ))}
      </View>

      {/* Day grid */}
      <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
        {cells.map((d, i) => {
          if (!d) return <View key={i} style={{ width: `${100 / 7}%`, height: 40 }} />;
          const sess = byDay[format(d, 'yyyy-MM-dd')];
          const has = !!sess;
          return (
            <View key={i} style={{ width: `${100 / 7}%`, height: 40,
              alignItems: 'center', justifyContent: 'center' }}>
              <TouchableOpacity
                disabled={!has}
                onPress={() => sess && router.push({ pathname: '/workout/view', params: { sessionId: String(sess.id) } })}
                style={{ width: 32, height: 32, borderRadius: 16,
                  alignItems: 'center', justifyContent: 'center',
                  backgroundColor: has ? Colors.primary : 'transparent',
                  borderWidth: isToday(d) && !has ? 1.5 : 0, borderColor: Colors.primary }}>
                <Text style={{ fontSize: FontSize.xs,
                  color: has ? Colors.textInverse : isToday(d) ? Colors.primary : Colors.textPrimary,
                  fontWeight: has || isToday(d) ? FontWeight.bold : FontWeight.regular }}>
                  {d.getDate()}
                </Text>
              </TouchableOpacity>
            </View>
          );
        })}
      </View>

      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: Spacing.sm }}>
        <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: Colors.primary }} />
        <Text style={{ fontSize: 10, color: Colors.textMuted }}>
          Days with a completed workout · tap to view
        </Text>
      </View>
    </View>
  );
}
