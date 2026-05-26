import React from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, RefreshControl,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { format } from 'date-fns';
import { programsApi } from '@/services/api/programs';
import { workoutsApi } from '@/services/api/workouts';
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

        {/* Recent sessions */}
        {sessions && sessions.length > 0 && (
          <>
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.semibold,
              color: Colors.textPrimary, marginTop: Spacing.xl, marginBottom: Spacing.sm }}>
              Recent Sessions
            </Text>
            {sessions.slice(0, 10).map((s) => {
              const inProgress = !s.completedAt;
              const SessionRow = inProgress ? TouchableOpacity : View;
              return (
                <SessionRow
                  key={s.id}
                  {...(inProgress
                    ? { onPress: () => router.push({ pathname: '/workout/start', params: { templateId: s.templateId ?? '', sessionId: s.id } }) }
                    : {})}
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
                    ? <Ionicons name="checkmark-circle" size={20} color={Colors.success} />
                    : <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                        <View style={{ backgroundColor: Colors.warningTint, paddingHorizontal: 8,
                          paddingVertical: 3, borderRadius: Radius.full }}>
                          <Text style={{ fontSize: FontSize.xs, color: Colors.warning }}>In Progress</Text>
                        </View>
                        <Ionicons name="chevron-forward" size={16} color={Colors.warning} />
                      </View>
                  }
                </SessionRow>
              );
            })}
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
