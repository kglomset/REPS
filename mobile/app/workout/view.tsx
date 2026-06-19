// Read-only view of a completed workout session.
// Looks like the active workout screen but with no editing: no inputs,
// no checkmarks, no finish/cancel — just what was logged.
import React from 'react';
import { ActivityIndicator, ScrollView, Text, TouchableOpacity, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { format } from 'date-fns';
import { workoutsApi } from '@/services/api/workouts';
import { SessionExerciseResponse } from '@/types';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';

const METHOD_LABELS: Record<string, string> = {
  STRAIGHT_SETS: 'Straight',
  MYOREPS: 'Myo-reps',
  SUPERSET: 'Superset',
  TRISET: 'Tri-set',
  DROP_SET: 'Drop set',
};

export default function CompletedWorkoutScreen() {
  const { sessionId } = useLocalSearchParams<{ sessionId: string }>();

  const { data: session, isLoading } = useQuery({
    queryKey: ['sessionDetail', Number(sessionId)],
    queryFn: () => workoutsApi.getSession(Number(sessionId)),
    enabled: !!sessionId,
  });

  if (isLoading || !session) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center',
        backgroundColor: Colors.surface }}>
        <ActivityIndicator size="large" color={Colors.primary} />
        <Text style={{ marginTop: Spacing.md, color: Colors.textSecondary }}>Loading workout…</Text>
      </View>
    );
  }

  const durationMin = session.completedAt
    ? Math.max(0, Math.round(
        (new Date(session.completedAt).getTime() - new Date(session.startedAt).getTime()) / 60000))
    : null;

  const totalSets = session.exercises.reduce((acc, ex) => acc + ex.sets.length, 0);
  const totalVolume = Math.round(session.exercises.reduce((acc, ex) =>
    acc + ex.sets.reduce((a, s) => a + (s.weightKg != null ? s.weightKg * s.reps : 0), 0), 0));

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surfaceMuted }}>
      {/* Header */}
      <View style={{ backgroundColor: Colors.surface, paddingHorizontal: Spacing.lg,
        paddingVertical: Spacing.sm, borderBottomWidth: 1, borderBottomColor: Colors.border }}>
        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
          <TouchableOpacity onPress={() => (router.canGoBack() ? router.back() : router.replace('/(tabs)/workouts'))}
            style={{ padding: 4, marginRight: Spacing.sm }}>
            <Ionicons name="chevron-back" size={24} color={Colors.textPrimary} />
          </TouchableOpacity>
          <View style={{ flex: 1 }}>
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
              color: Colors.textPrimary }}>{session.templateName ?? 'Workout'}</Text>
            <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
              {format(new Date(session.startedAt), 'EEE, MMM d, yyyy')}
            </Text>
          </View>
        </View>

        {/* Read-only banner */}
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, marginTop: Spacing.sm,
          backgroundColor: Colors.surfaceSubtle, borderRadius: Radius.full,
          paddingHorizontal: 10, paddingVertical: 5, alignSelf: 'flex-start' }}>
          <Ionicons name="lock-closed" size={12} color={Colors.textMuted} />
          <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, fontWeight: FontWeight.medium }}>
            {session.completedAt ? 'Completed workout · view only' : 'Not an active workout · view only'}
          </Text>
        </View>
      </View>

      <ScrollView contentContainerStyle={{ padding: Spacing.md, paddingBottom: 60 }}>
        {/* Summary stats */}
        <View style={{ flexDirection: 'row', gap: Spacing.sm, marginBottom: Spacing.md }}>
          <SummaryTile icon="time-outline" label="Duration"
            value={durationMin != null ? `${durationMin}m` : '—'} />
          <SummaryTile icon="layers-outline" label="Sets" value={String(totalSets)} />
          <SummaryTile icon="barbell-outline" label="Volume" value={`${totalVolume}kg`} />
        </View>

        {session.exercises.map((ex) => (
          <ExerciseCard key={ex.id} ex={ex} />
        ))}

        {session.exercises.length === 0 && (
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, textAlign: 'center',
            marginTop: Spacing.lg }}>No exercises were logged in this session.</Text>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

function SummaryTile({ icon, label, value }: { icon: string; label: string; value: string }) {
  return (
    <View style={{ flex: 1, backgroundColor: Colors.surface, borderRadius: Radius.md,
      padding: Spacing.sm, alignItems: 'center', ...Shadow.card }}>
      <Ionicons name={icon as any} size={18} color={Colors.primary} />
      <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.bold, color: Colors.textPrimary,
        marginTop: 2 }}>{value}</Text>
      <Text style={{ fontSize: 9, color: Colors.textMuted }}>{label}</Text>
    </View>
  );
}

function ExerciseCard({ ex }: { ex: SessionExerciseResponse }) {
  const primary = ex.exercise.muscles.filter((m) => m.role === 'PRIMARY');
  const secondary = ex.exercise.muscles.filter((m) => m.role === 'SECONDARY');
  const sets = [...ex.sets].sort((a, b) => a.setNumber - b.setNumber);

  return (
    <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.lg,
      marginBottom: Spacing.sm, ...Shadow.card, overflow: 'hidden' }}>
      {/* Header */}
      <View style={{ flexDirection: 'row', alignItems: 'flex-start', padding: Spacing.md,
        borderBottomWidth: 1, borderBottomColor: Colors.border }}>
        <View style={{ flex: 1 }}>
          <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>{ex.exercise.name}</Text>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 4, marginTop: 4 }}>
            {primary.map((m) => (
              <View key={`p-${m.muscleGroupId}`} style={{ backgroundColor: Colors.primary,
                borderRadius: Radius.full, paddingHorizontal: 7, paddingVertical: 2 }}>
                <Text style={{ fontSize: 10, color: Colors.textInverse,
                  fontWeight: FontWeight.semibold }}>{m.muscleGroupName}</Text>
              </View>
            ))}
            {secondary.map((m) => (
              <View key={`s-${m.muscleGroupId}`} style={{ backgroundColor: Colors.primaryTint,
                borderRadius: Radius.full, paddingHorizontal: 7, paddingVertical: 2,
                borderWidth: 1, borderColor: Colors.primaryLight }}>
                <Text style={{ fontSize: 10, color: Colors.primaryLight,
                  fontWeight: FontWeight.medium }}>{m.muscleGroupName}</Text>
              </View>
            ))}
          </View>
        </View>
        <View style={{ backgroundColor: Colors.surfaceSubtle, borderRadius: Radius.full,
          paddingHorizontal: 10, paddingVertical: 4 }}>
          <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary,
            fontWeight: FontWeight.medium }}>{METHOD_LABELS[ex.trainingMethod] ?? 'Straight'}</Text>
        </View>
      </View>

      {/* Sets table */}
      <View style={{ paddingHorizontal: Spacing.md, paddingVertical: Spacing.sm }}>
        <View style={{ flexDirection: 'row', paddingVertical: 4 }}>
          <Text style={[hdr, { flex: 1 }]}>Set</Text>
          <Text style={[hdr, { flex: 2 }]}>Weight</Text>
          <Text style={[hdr, { flex: 2 }]}>Reps</Text>
        </View>
        {sets.length === 0 ? (
          <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, paddingVertical: 6 }}>
            No sets logged.
          </Text>
        ) : sets.map((s, i) => (
          <View key={s.id ?? i} style={{ flexDirection: 'row', alignItems: 'center',
            paddingVertical: 6, borderTopWidth: i === 0 ? 0 : 1, borderTopColor: Colors.borderLight }}>
            <Text style={{ flex: 1, fontSize: FontSize.sm, color: Colors.textSecondary,
              textAlign: 'center', fontVariant: ['tabular-nums'] }}>{s.setNumber}</Text>
            <Text style={{ flex: 2, fontSize: FontSize.sm, color: Colors.textPrimary,
              textAlign: 'center', fontWeight: FontWeight.semibold, fontVariant: ['tabular-nums'] }}>
              {s.weightKg != null ? `${s.weightKg} kg` : 'BW'}
            </Text>
            <Text style={{ flex: 2, fontSize: FontSize.sm, color: Colors.textPrimary,
              textAlign: 'center', fontWeight: FontWeight.semibold, fontVariant: ['tabular-nums'] }}>
              {s.reps}
            </Text>
          </View>
        ))}
      </View>
    </View>
  );
}

const hdr = {
  fontSize: FontSize.xs,
  color: Colors.textMuted,
  fontWeight: FontWeight.medium,
  textAlign: 'center' as const,
};
