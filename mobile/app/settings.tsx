import React, { useState, useEffect } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, TextInput,
  Alert, Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/store/useAuthStore';
import { useSettingsStore } from '@/store/useSettingsStore';
import { progressApi } from '@/services/api/progress';
import { programsApi } from '@/services/api/programs';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';
import { format } from 'date-fns';

export default function SettingsScreen() {
  const { user, logout } = useAuthStore();
  const queryClient = useQueryClient();
  const [weight, setWeight] = useState('');

  const { weightGoal, startWeight, hydrate, setWeightGoal, setStartWeight, isHydrated }
    = useSettingsStore();
  const [goalInput,  setGoalInput]  = useState('');
  const [startInput, setStartInput] = useState('');

  useEffect(() => { if (!isHydrated) hydrate(); }, []);
  useEffect(() => {
    if (isHydrated) {
      setGoalInput(weightGoal  !== undefined ? String(weightGoal)  : '');
      setStartInput(startWeight !== undefined ? String(startWeight) : '');
    }
  }, [isHydrated, weightGoal, startWeight]);

  const { data: programs } = useQuery({
    queryKey: ['programs'],
    queryFn: programsApi.list,
  });

  const { mutate: activateProgram } = useMutation({
    mutationFn: (id: number) => programsApi.activate(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['activeProgram'] });
      queryClient.invalidateQueries({ queryKey: ['programs'] });
      Alert.alert('Program activated', 'Your active program has been updated.');
    },
    onError: (e: Error) => Alert.alert('Error', e.message),
  });

  const { mutate: logWeight } = useMutation({
    mutationFn: () => progressApi.logBodyWeight({
      weightKg: parseFloat(weight),
      logDate: format(new Date(), 'yyyy-MM-dd'),
    }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['bodyWeight'] });
      setWeight('');
      Alert.alert('Saved', 'Body weight logged.');
    },
    onError: (e: Error) => Alert.alert('Error', e.message),
  });

  const handleLogout = () => {
    const doLogout = async () => {
      try { await logout(); } catch (_) {}
      router.replace('/(auth)/login');
    };
    if (Platform.OS === 'web') {
      if (window.confirm('Sign out of REPS?')) doLogout();
    } else {
      Alert.alert('Sign Out', 'Are you sure?', [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Sign Out', style: 'destructive', onPress: doLogout },
      ]);
    }
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surfaceMuted }}>
      <ScrollView contentContainerStyle={{ padding: Spacing.lg, paddingBottom: 100 }}>
        {/* Back */}
        <TouchableOpacity
          onPress={() => router.back()}
          style={{ flexDirection: 'row', alignItems: 'center', gap: 4, marginBottom: Spacing.lg }}
        >
          <Ionicons name="chevron-back" size={20} color={Colors.primary} />
          <Text style={{ color: Colors.primary, fontSize: FontSize.md }}>Back</Text>
        </TouchableOpacity>

        {/* Profile card */}
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          padding: Spacing.lg, ...Shadow.card, marginBottom: Spacing.lg,
          alignItems: 'center' }}>
          <View style={{ width: 64, height: 64, borderRadius: 32,
            backgroundColor: Colors.primaryTint,
            alignItems: 'center', justifyContent: 'center', marginBottom: Spacing.sm }}>
            <Text style={{ fontSize: FontSize.xxl, fontWeight: FontWeight.bold,
              color: Colors.primary }}>
              {user?.name?.[0]?.toUpperCase() ?? '?'}
            </Text>
          </View>
          <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
            color: Colors.textPrimary }}>{user?.name}</Text>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>{user?.email}</Text>
          <View style={{ backgroundColor: Colors.primaryTint, paddingHorizontal: 10,
            paddingVertical: 4, borderRadius: Radius.full, marginTop: Spacing.sm }}>
            <Text style={{ fontSize: FontSize.xs, color: Colors.primary, fontWeight: FontWeight.medium }}>
              {user?.fitnessLevel}
            </Text>
          </View>
        </View>

        {/* Body weight */}
        <SectionHeader title="Body Weight" />
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          padding: Spacing.md, ...Shadow.card, marginBottom: Spacing.lg }}>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginBottom: Spacing.sm }}>
            Log today's weight (kg)
          </Text>
          <View style={{ flexDirection: 'row', gap: Spacing.sm }}>
            <TextInput
              value={weight}
              onChangeText={setWeight}
              placeholder="e.g. 75.5"
              placeholderTextColor={Colors.textMuted}
              keyboardType="decimal-pad"
              style={{
                flex: 1, backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
                paddingHorizontal: Spacing.md, paddingVertical: 12,
                fontSize: FontSize.md, color: Colors.textPrimary,
                borderWidth: 1, borderColor: Colors.border,
              }}
            />
            <TouchableOpacity
              onPress={() => { if (weight) logWeight(); }}
              disabled={!weight}
              style={{
                backgroundColor: Colors.primary, borderRadius: Radius.md,
                paddingHorizontal: Spacing.lg, justifyContent: 'center',
                opacity: weight ? 1 : 0.5,
              }}
            >
              <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold }}>Save</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Weight goal */}
        <SectionHeader title="Weight Goal" />
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          padding: Spacing.md, ...Shadow.card, marginBottom: Spacing.lg }}>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginBottom: Spacing.sm }}>
            Used to color-code your progress trend on the home screen.
          </Text>
          <View style={{ flexDirection: 'row', gap: Spacing.sm, marginBottom: Spacing.sm }}>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary,
                marginBottom: 4 }}>Starting weight (kg)</Text>
              <TextInput
                value={startInput}
                onChangeText={setStartInput}
                onBlur={() => {
                  const n = parseFloat(startInput);
                  setStartWeight(!isNaN(n) && n > 0 ? n : undefined);
                }}
                placeholder="e.g. 90.0"
                placeholderTextColor={Colors.textMuted}
                keyboardType="decimal-pad"
                style={{
                  backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
                  paddingHorizontal: Spacing.md, paddingVertical: 10,
                  fontSize: FontSize.md, color: Colors.textPrimary,
                  borderWidth: 1, borderColor: Colors.border,
                }}
              />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary,
                marginBottom: 4 }}>Goal weight (kg)</Text>
              <TextInput
                value={goalInput}
                onChangeText={setGoalInput}
                onBlur={() => {
                  const n = parseFloat(goalInput);
                  setWeightGoal(!isNaN(n) && n > 0 ? n : undefined);
                }}
                placeholder="e.g. 80.0"
                placeholderTextColor={Colors.textMuted}
                keyboardType="decimal-pad"
                style={{
                  backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
                  paddingHorizontal: Spacing.md, paddingVertical: 10,
                  fontSize: FontSize.md, color: Colors.textPrimary,
                  borderWidth: 1, borderColor: Colors.border,
                }}
              />
            </View>
          </View>
          {weightGoal !== undefined && startWeight !== undefined && (
            <View style={{ backgroundColor: Colors.primaryTint, borderRadius: Radius.md,
              padding: Spacing.sm }}>
              <Text style={{ fontSize: FontSize.xs, color: Colors.primary }}>
                {Math.abs(weightGoal - startWeight) < 0.5
                  ? '⚖️ Maintenance — trend is always gray'
                  : weightGoal > startWeight
                    ? `📈 Gaining — weight increases will show green`
                    : `📉 Losing — weight decreases will show green`}
              </Text>
            </View>
          )}
        </View>

        {/* Programs */}
        {programs && programs.length > 0 && (
          <>
            <SectionHeader title="Programs" />
            <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
              ...Shadow.card, marginBottom: Spacing.lg, overflow: 'hidden' }}>
              {programs.map((p, i) => (
                <View key={p.id} style={{
                  flexDirection: 'row', alignItems: 'center',
                  padding: Spacing.md,
                  borderBottomWidth: i < programs.length - 1 ? 1 : 0,
                  borderBottomColor: Colors.border,
                }}>
                  <View style={{ flex: 1 }}>
                    <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary,
                      fontWeight: FontWeight.medium }}>{p.name}</Text>
                    <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary }}>
                      {p.strengthDaysPerWeek}d/wk · {p.goal.toLowerCase()}
                    </Text>
                  </View>
                  {p.active ? (
                    <View style={{ backgroundColor: Colors.successTint, borderRadius: Radius.full,
                      paddingHorizontal: 10, paddingVertical: 4 }}>
                      <Text style={{ fontSize: FontSize.xs, color: Colors.success,
                        fontWeight: FontWeight.semibold }}>Active</Text>
                    </View>
                  ) : (
                    <TouchableOpacity
                      onPress={() => {
                        Alert.alert(
                          'Activate program',
                          `Switch to "${p.name}"? This will deactivate your current program.`,
                          [
                            { text: 'Cancel', style: 'cancel' },
                            { text: 'Activate', onPress: () => activateProgram(p.id) },
                          ]
                        );
                      }}
                      style={{ backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
                        paddingHorizontal: 10, paddingVertical: 4 }}>
                      <Text style={{ fontSize: FontSize.xs, color: Colors.primary,
                        fontWeight: FontWeight.semibold }}>Activate</Text>
                    </TouchableOpacity>
                  )}
                </View>
              ))}
            </View>
          </>
        )}

        {/* Account */}
        <SectionHeader title="Account" />
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          overflow: 'hidden', ...Shadow.card }}>
          <SettingsRow icon="person-outline" label="Edit Profile" onPress={() => {}} />
          <SettingsRow icon="notifications-outline" label="Notifications" onPress={() => {}} />
          <SettingsRow icon="barbell-outline" label="New Program"
            onPress={() => router.push('/program/setup')} />
          <SettingsRow icon="log-out-outline" label="Sign Out"
            onPress={handleLogout} destructive />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function SectionHeader({ title }: { title: string }) {
  return (
    <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.semibold,
      color: Colors.textSecondary, textTransform: 'uppercase', letterSpacing: 0.5,
      marginBottom: Spacing.sm, marginLeft: 4 }}>
      {title}
    </Text>
  );
}

function SettingsRow({ icon, label, onPress, destructive }: {
  icon: string; label: string; onPress: () => void; destructive?: boolean;
}) {
  return (
    <TouchableOpacity
      onPress={onPress}
      style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md,
        borderBottomWidth: 1, borderBottomColor: Colors.border }}
    >
      <Ionicons name={icon as any} size={20}
        color={destructive ? Colors.error : Colors.textSecondary}
        style={{ marginRight: Spacing.md }}
      />
      <Text style={{ flex: 1, fontSize: FontSize.md,
        color: destructive ? Colors.error : Colors.textPrimary }}>{label}</Text>
      <Ionicons name="chevron-forward" size={16} color={Colors.textMuted} />
    </TouchableOpacity>
  );
}
