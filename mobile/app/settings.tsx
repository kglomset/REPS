import React, { useState, useEffect } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, TextInput,
  Alert, Platform, Image, Modal, Switch,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/store/useAuthStore';
import { useSettingsStore } from '@/store/useSettingsStore';
import { progressApi } from '@/services/api/progress';
import { programsApi } from '@/services/api/programs';
import { usersApi } from '@/services/api/users';
import { workoutsApi } from '@/services/api/workouts';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';
import { format } from 'date-fns';
import { ProgramResponse } from '@/types';

export default function SettingsScreen() {
  const { user, logout, updateUser } = useAuthStore();
  const queryClient = useQueryClient();

  // ── Weight log ──────────────────────────────────────────────────────────
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

  // ── Profile edit ────────────────────────────────────────────────────────
  const [editingName, setEditingName] = useState(false);
  const [nameInput, setNameInput] = useState(user?.name ?? '');

  // ── Program rename modal ────────────────────────────────────────────────
  const [renameProgramModal, setRenameProgramModal] = useState<ProgramResponse | null>(null);
  const [renameProgramInput, setRenameProgramInput] = useState('');

  // ── Template rename modal ───────────────────────────────────────────────
  const [renameTemplateModal, setRenameTemplateModal] = useState<{ id: number; name: string } | null>(null);
  const [renameTemplateInput, setRenameTemplateInput] = useState('');

  const { data: programs } = useQuery({
    queryKey: ['programs'],
    queryFn: programsApi.list,
  });

  // ── Mutations ───────────────────────────────────────────────────────────
  const { mutate: activateProgram } = useMutation({
    mutationFn: (id: number) => programsApi.activate(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['activeProgram'] });
      queryClient.invalidateQueries({ queryKey: ['programs'] });
    },
    onError: (e: Error) => Alert.alert('Error', e.message),
  });

  const { mutate: deactivateProgram } = useMutation({
    mutationFn: (id: number) => programsApi.deactivate(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['activeProgram'] });
      queryClient.invalidateQueries({ queryKey: ['programs'] });
    },
    onError: (e: Error) => Alert.alert('Error', e.message),
  });

  const { mutate: renameProgram } = useMutation({
    mutationFn: ({ id, name }: { id: number; name: string }) => programsApi.update(id, { name }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['programs'] });
      setRenameProgramModal(null);
    },
    onError: (e: Error) => Alert.alert('Error', e.message),
  });

  const { mutate: renameTemplate } = useMutation({
    mutationFn: ({ id, name }: { id: number; name: string }) =>
      workoutsApi.updateTemplate(id, { name }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['programs'] });
      queryClient.invalidateQueries({ queryKey: ['activeProgram'] });
      setRenameTemplateModal(null);
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

  const { mutate: updateProfile } = useMutation({
    mutationFn: (data: { name?: string; avatarUrl?: string | null }) =>
      usersApi.updateMe(data),
    onSuccess: (res) => {
      updateUser({ name: res.name, avatarUrl: res.avatarUrl });
      setEditingName(false);
    },
    onError: (e: Error) => Alert.alert('Error', e.message),
  });

  // ── Profile photo picker ─────────────────────────────────────────────────
  // On web we use a hidden file input; on native this is a placeholder
  const pickAvatar = () => {
    if (Platform.OS === 'web') {
      const input = document.createElement('input');
      input.type = 'file';
      input.accept = 'image/*';
      input.onchange = (e: any) => {
        const file = e.target.files?.[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = (ev) => {
          const dataUri = ev.target?.result as string;
          if (!dataUri) return;
          // Downscale + compress so the stored avatar is a small, reliable data URI.
          const img = new (window as any).Image();
          img.onload = () => {
            const MAX = 256;
            const scale = Math.min(1, MAX / Math.max(img.width, img.height));
            const w = Math.round(img.width * scale);
            const h = Math.round(img.height * scale);
            const canvas = document.createElement('canvas');
            canvas.width = w;
            canvas.height = h;
            const ctx = canvas.getContext('2d');
            if (!ctx) { updateProfile({ avatarUrl: dataUri }); return; }
            ctx.drawImage(img, 0, 0, w, h);
            const compressed = canvas.toDataURL('image/jpeg', 0.85);
            updateProfile({ avatarUrl: compressed });
          };
          img.onerror = () => updateProfile({ avatarUrl: dataUri });
          img.src = dataUri;
        };
        reader.readAsDataURL(file);
      };
      input.click();
    } else {
      Alert.alert('Coming soon', 'Photo upload is not yet available on this platform.');
    }
  };

  const removeAvatar = () => {
    Alert.alert('Remove photo', 'Remove your profile photo?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Remove', style: 'destructive', onPress: () => updateProfile({ avatarUrl: null }) },
    ]);
  };

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

  const avatarUrl = user?.avatarUrl;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surfaceMuted }}>
      <ScrollView contentContainerStyle={{ padding: Spacing.lg, paddingBottom: 100 }}>
        {/* Back */}
        <TouchableOpacity
          onPress={() => (router.canGoBack() ? router.back() : router.replace('/(tabs)/'))}
          style={{ flexDirection: 'row', alignItems: 'center', gap: 4, marginBottom: Spacing.lg }}
        >
          <Ionicons name="chevron-back" size={20} color={Colors.primary} />
          <Text style={{ color: Colors.primary, fontSize: FontSize.md }}>Back to Home</Text>
        </TouchableOpacity>

        {/* ── Profile card ──────────────────────────────────────────── */}
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          padding: Spacing.lg, ...Shadow.card, marginBottom: Spacing.lg,
          alignItems: 'center' }}>

          {/* Avatar */}
          <TouchableOpacity onPress={pickAvatar} style={{ marginBottom: Spacing.sm }}>
            {avatarUrl ? (
              <Image
                source={{ uri: avatarUrl }}
                style={{ width: 72, height: 72, borderRadius: 36 }}
              />
            ) : (
              <View style={{ width: 72, height: 72, borderRadius: 36,
                backgroundColor: Colors.primaryTint,
                alignItems: 'center', justifyContent: 'center' }}>
                <Text style={{ fontSize: 28, fontWeight: FontWeight.bold, color: Colors.primary }}>
                  {user?.name?.[0]?.toUpperCase() ?? '?'}
                </Text>
              </View>
            )}
            {/* Camera badge */}
            <View style={{ position: 'absolute', bottom: 0, right: 0,
              backgroundColor: Colors.primary, borderRadius: 12,
              width: 24, height: 24, alignItems: 'center', justifyContent: 'center',
              borderWidth: 2, borderColor: Colors.surface }}>
              <Ionicons name="camera" size={12} color="#fff" />
            </View>
          </TouchableOpacity>
          {avatarUrl && (
            <TouchableOpacity onPress={removeAvatar} style={{ marginBottom: 4 }}>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>Remove photo</Text>
            </TouchableOpacity>
          )}

          {/* Name */}
          {editingName ? (
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.sm,
              marginTop: Spacing.xs }}>
              <TextInput
                value={nameInput}
                onChangeText={setNameInput}
                autoFocus
                style={{ borderBottomWidth: 1, borderColor: Colors.primary,
                  fontSize: FontSize.lg, fontWeight: FontWeight.bold,
                  color: Colors.textPrimary, minWidth: 120, textAlign: 'center',
                  paddingVertical: 2 }}
              />
              <TouchableOpacity
                onPress={() => {
                  if (nameInput.trim()) updateProfile({ name: nameInput.trim() });
                  else setEditingName(false);
                }}
              >
                <Ionicons name="checkmark-circle" size={22} color={Colors.primary} />
              </TouchableOpacity>
              <TouchableOpacity onPress={() => { setNameInput(user?.name ?? ''); setEditingName(false); }}>
                <Ionicons name="close-circle" size={22} color={Colors.textMuted} />
              </TouchableOpacity>
            </View>
          ) : (
            <TouchableOpacity
              onPress={() => { setNameInput(user?.name ?? ''); setEditingName(true); }}
              style={{ flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 4 }}
            >
              <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
                color: Colors.textPrimary }}>{user?.name}</Text>
              <Ionicons name="pencil" size={14} color={Colors.textMuted} />
            </TouchableOpacity>
          )}

          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginTop: 2 }}>
            {user?.email}
          </Text>
          <View style={{ backgroundColor: Colors.primaryTint, paddingHorizontal: 10,
            paddingVertical: 4, borderRadius: Radius.full, marginTop: Spacing.sm }}>
            <Text style={{ fontSize: FontSize.xs, color: Colors.primary, fontWeight: FontWeight.medium }}>
              {user?.fitnessLevel}
            </Text>
          </View>
        </View>

        {/* ── Body Weight ───────────────────────────────────────────── */}
        <SectionHeader title="Body Weight" />
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          padding: Spacing.md, ...Shadow.card, marginBottom: Spacing.md }}>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginBottom: Spacing.sm }}>
            Log today's weight (kg)
          </Text>
          <View style={{ flexDirection: 'row', gap: Spacing.sm, alignItems: 'center' }}>
            <TextInput
              value={weight}
              onChangeText={setWeight}
              placeholder="e.g. 75.5"
              placeholderTextColor={Colors.textMuted}
              keyboardType="decimal-pad"
              style={{
                flex: 1,
                backgroundColor: Colors.surfaceMuted,
                borderRadius: Radius.md,
                paddingHorizontal: Spacing.md,
                paddingVertical: 12,
                fontSize: FontSize.md,
                color: Colors.textPrimary,
                borderWidth: 1,
                borderColor: Colors.border,
              }}
            />
            <TouchableOpacity
              onPress={() => { if (weight) logWeight(); }}
              disabled={!weight}
              style={{
                backgroundColor: Colors.primary,
                borderRadius: Radius.md,
                paddingHorizontal: Spacing.lg,
                paddingVertical: 12,
                opacity: weight ? 1 : 0.4,
              }}
            >
              <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold }}>Save</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* ── Weight Goal ───────────────────────────────────────────── */}
        <SectionHeader title="Weight Goal" />
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          padding: Spacing.md, ...Shadow.card, marginBottom: Spacing.lg }}>
          <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary, marginBottom: Spacing.sm }}>
            Used to color-code your progress trend on the home screen.
          </Text>

          {/* Current goal display — replaces whenever a new goal is set */}
          {weightGoal !== undefined && (
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
              backgroundColor: Colors.successTint, borderRadius: Radius.md,
              paddingHorizontal: Spacing.md, paddingVertical: Spacing.sm, marginBottom: Spacing.sm }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                <Ionicons name="flag" size={14} color={Colors.success} />
                <Text style={{ fontSize: FontSize.sm, color: Colors.success,
                  fontWeight: FontWeight.semibold }}>Current goal</Text>
              </View>
              <Text style={{ fontSize: FontSize.md, color: Colors.success, fontWeight: FontWeight.bold }}>
                {weightGoal} kg{startWeight !== undefined ? `  ·  from ${startWeight} kg` : ''}
              </Text>
            </View>
          )}

          <View style={{ flexDirection: 'row', gap: Spacing.sm, marginBottom: Spacing.sm }}>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary, marginBottom: 4 }}>
                Starting weight (kg)
              </Text>
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
              <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary, marginBottom: 4 }}>
                Goal weight (kg)
              </Text>
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
                    ? '📈 Gaining — weight increases will show green'
                    : '📉 Losing — weight decreases will show green'}
              </Text>
            </View>
          )}
        </View>

        {/* ── Programs ──────────────────────────────────────────────── */}
        {programs && programs.length > 0 && (
          <>
            <SectionHeader title="Programs" />
            <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
              ...Shadow.card, marginBottom: Spacing.lg, overflow: 'hidden' }}>
              {programs.map((p, i) => (
                <View key={p.id}>
                  {/* Program row */}
                  <View style={{
                    flexDirection: 'row', alignItems: 'center',
                    padding: Spacing.md,
                    borderBottomWidth: 1, borderBottomColor: Colors.border,
                  }}>
                    <View style={{ flex: 1 }}>
                      <TouchableOpacity
                        onPress={() => router.push({ pathname: '/program/setup', params: { edit: String(p.id) } })}
                        style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}
                      >
                        <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary,
                          fontWeight: FontWeight.medium }}>{p.name}</Text>
                        <Ionicons name="create-outline" size={15} color={Colors.primary} />
                      </TouchableOpacity>
                      <TouchableOpacity onPress={() => router.push({ pathname: '/program/setup', params: { edit: String(p.id) } })}>
                        <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary }}>
                          {p.strengthDaysPerWeek}d/wk · {p.goal.toLowerCase()} · tap to edit
                        </Text>
                      </TouchableOpacity>
                    </View>

                    {/* Active/inactive toggle — activating deactivates the others
                        (single-active-program rule enforced by the backend) */}
                    <View style={{ alignItems: 'center', gap: 2 }}>
                      <Switch
                        value={p.active}
                        onValueChange={() =>
                          p.active ? deactivateProgram(p.id) : activateProgram(p.id)}
                        trackColor={{ false: Colors.border, true: Colors.success }}
                      />
                      {p.active && (
                        <Text style={{ fontSize: 10, color: Colors.success,
                          fontWeight: FontWeight.semibold }}>Active</Text>
                      )}
                    </View>
                  </View>
                </View>
              ))}
            </View>
          </>
        )}

        {/* ── Account ───────────────────────────────────────────────── */}
        <SectionHeader title="Account" />
        <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
          overflow: 'hidden', ...Shadow.card }}>
          <SettingsRow icon="notifications-outline" label="Notifications" onPress={() => {}} />
          <SettingsRow icon="barbell-outline" label="New Program"
            onPress={() => router.push('/program/setup')} />
          <SettingsRow icon="log-out-outline" label="Sign Out"
            onPress={handleLogout} destructive />
        </View>
      </ScrollView>

      {/* ── Rename Program Modal ────────────────────────────────────── */}
      <Modal visible={!!renameProgramModal} transparent animationType="fade">
        <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.5)',
          justifyContent: 'center', alignItems: 'center', padding: Spacing.lg }}>
          <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
            padding: Spacing.lg, width: '100%', maxWidth: 360 }}>
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
              color: Colors.textPrimary, marginBottom: Spacing.md }}>
              Rename Program
            </Text>
            <TextInput
              value={renameProgramInput}
              onChangeText={setRenameProgramInput}
              autoFocus
              placeholder="Program name"
              placeholderTextColor={Colors.textMuted}
              style={{ backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
                paddingHorizontal: Spacing.md, paddingVertical: 12,
                fontSize: FontSize.md, color: Colors.textPrimary,
                borderWidth: 1, borderColor: Colors.border, marginBottom: Spacing.md }}
            />
            <View style={{ flexDirection: 'row', gap: Spacing.sm }}>
              <TouchableOpacity
                onPress={() => setRenameProgramModal(null)}
                style={{ flex: 1, paddingVertical: 12, borderRadius: Radius.md,
                  backgroundColor: Colors.surfaceMuted, alignItems: 'center' }}
              >
                <Text style={{ color: Colors.textSecondary, fontWeight: FontWeight.medium }}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => {
                  if (renameProgramModal && renameProgramInput.trim())
                    renameProgram({ id: renameProgramModal.id, name: renameProgramInput.trim() });
                }}
                style={{ flex: 1, paddingVertical: 12, borderRadius: Radius.md,
                  backgroundColor: Colors.primary, alignItems: 'center' }}
              >
                <Text style={{ color: '#fff', fontWeight: FontWeight.semibold }}>Save</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* ── Rename Template Modal ────────────────────────────────────── */}
      <Modal visible={!!renameTemplateModal} transparent animationType="fade">
        <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.5)',
          justifyContent: 'center', alignItems: 'center', padding: Spacing.lg }}>
          <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
            padding: Spacing.lg, width: '100%', maxWidth: 360 }}>
            <Text style={{ fontSize: FontSize.lg, fontWeight: FontWeight.bold,
              color: Colors.textPrimary, marginBottom: Spacing.md }}>
              Rename Workout
            </Text>
            <TextInput
              value={renameTemplateInput}
              onChangeText={setRenameTemplateInput}
              autoFocus
              placeholder="Workout name"
              placeholderTextColor={Colors.textMuted}
              style={{ backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
                paddingHorizontal: Spacing.md, paddingVertical: 12,
                fontSize: FontSize.md, color: Colors.textPrimary,
                borderWidth: 1, borderColor: Colors.border, marginBottom: Spacing.md }}
            />
            <View style={{ flexDirection: 'row', gap: Spacing.sm }}>
              <TouchableOpacity
                onPress={() => setRenameTemplateModal(null)}
                style={{ flex: 1, paddingVertical: 12, borderRadius: Radius.md,
                  backgroundColor: Colors.surfaceMuted, alignItems: 'center' }}
              >
                <Text style={{ color: Colors.textSecondary, fontWeight: FontWeight.medium }}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => {
                  if (renameTemplateModal && renameTemplateInput.trim())
                    renameTemplate({ id: renameTemplateModal.id, name: renameTemplateInput.trim() });
                }}
                style={{ flex: 1, paddingVertical: 12, borderRadius: Radius.md,
                  backgroundColor: Colors.primary, alignItems: 'center' }}
              >
                <Text style={{ color: '#fff', fontWeight: FontWeight.semibold }}>Save</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
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
