import React, { useState } from 'react';
import {
  View, Text, TouchableOpacity, ScrollView,
  ActivityIndicator, Alert,
} from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { useAuthStore } from '@/store/useAuthStore';
import { FitnessLevel, TrainingGoal } from '@/types';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';

const FITNESS_OPTIONS: { value: FitnessLevel; label: string; subtitle: string }[] = [
  { value: 'BEGINNER', label: 'Beginner', subtitle: '< 1 year training · 6–10 sets/muscle/week' },
  { value: 'INTERMEDIATE', label: 'Intermediate', subtitle: '1–3 years · 10–14 sets/muscle/week' },
  { value: 'ADVANCED', label: 'Advanced', subtitle: '3+ years · 14–20 sets/muscle/week' },
];

const GOAL_OPTIONS: { value: TrainingGoal; label: string; subtitle: string }[] = [
  { value: 'HYPERTROPHY', label: 'Muscle Growth', subtitle: '8–12 reps · moderate loads · shorter rest' },
  { value: 'STRENGTH', label: 'Strength', subtitle: '3–6 reps · heavy loads · longer rest' },
];

export default function OnboardScreen() {
  const { email, password, name } = useLocalSearchParams<{
    email: string; password: string; name: string;
  }>();

  const [fitnessLevel, setFitnessLevel] = useState<FitnessLevel>('BEGINNER');
  const [goal, setGoal] = useState<TrainingGoal>('HYPERTROPHY');
  const [isLoading, setIsLoading] = useState(false);
  const { register } = useAuthStore();

  const handleFinish = async () => {
    setIsLoading(true);
    try {
      await register({ email, password, name, fitnessLevel });
      router.replace('/program/setup');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <ScrollView style={{ flex: 1, backgroundColor: Colors.surface }}
      contentContainerStyle={{ padding: Spacing.lg }}>
      <Text style={{ fontSize: FontSize.xxl, fontWeight: FontWeight.bold,
        color: Colors.textPrimary, marginTop: Spacing.xl }}>
        Welcome, {name} 👋
      </Text>
      <Text style={{ fontSize: FontSize.md, color: Colors.textSecondary, marginTop: 6,
        marginBottom: Spacing.xl }}>
        Let's set up your profile so we can build the right program for you.
      </Text>

      <SectionTitle>Your fitness level</SectionTitle>
      {FITNESS_OPTIONS.map((opt) => (
        <SelectCard key={opt.value} label={opt.label} subtitle={opt.subtitle}
          selected={fitnessLevel === opt.value} onPress={() => setFitnessLevel(opt.value)} />
      ))}

      <SectionTitle style={{ marginTop: Spacing.lg }}>Your primary goal</SectionTitle>
      {GOAL_OPTIONS.map((opt) => (
        <SelectCard key={opt.value} label={opt.label} subtitle={opt.subtitle}
          selected={goal === opt.value} onPress={() => setGoal(opt.value)} />
      ))}

      <TouchableOpacity
        onPress={handleFinish}
        disabled={isLoading}
        style={{
          backgroundColor: Colors.primary, borderRadius: Radius.md,
          paddingVertical: 16, alignItems: 'center',
          marginTop: Spacing.xl, marginBottom: Spacing.xxl,
          opacity: isLoading ? 0.7 : 1,
        }}
      >
        {isLoading
          ? <ActivityIndicator color={Colors.textInverse} />
          : <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
              fontSize: FontSize.md }}>Create Account →</Text>}
      </TouchableOpacity>
    </ScrollView>
  );
}

function SectionTitle({ children, style }: any) {
  return (
    <Text style={[{ fontSize: FontSize.lg, fontWeight: FontWeight.semibold,
      color: Colors.textPrimary, marginBottom: Spacing.sm }, style]}>
      {children}
    </Text>
  );
}

function SelectCard({ label, subtitle, selected, onPress }: {
  label: string; subtitle: string; selected: boolean; onPress: () => void;
}) {
  return (
    <TouchableOpacity
      onPress={onPress}
      style={{
        borderRadius: Radius.lg, padding: Spacing.md, marginBottom: Spacing.sm,
        backgroundColor: selected ? Colors.primaryTint : Colors.surfaceMuted,
        borderWidth: 2, borderColor: selected ? Colors.primary : 'transparent',
        ...(selected ? Shadow.card : {}),
      }}
    >
      <Text style={{ fontWeight: FontWeight.semibold, fontSize: FontSize.md,
        color: selected ? Colors.primary : Colors.textPrimary }}>{label}</Text>
      <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 }}>
        {subtitle}
      </Text>
    </TouchableOpacity>
  );
}
