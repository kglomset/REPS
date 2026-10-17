import React, { useState } from 'react';
import { ActivityIndicator, Text, TextInput, TouchableOpacity, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useMutation, useQuery } from '@tanstack/react-query';
import { exercisesApi, movementsApi } from '@/services/api/exercises';
import { ExerciseResponse, MovementResponse } from '@/types';
import { Colors, Spacing, Radius, FontSize, FontWeight } from '@/constants/theme';

// ─── Exercise picker ──────────────────────────────────────────────────────────
// Equipment used to be baked into the exercise name ("Shoulder Press Smith",
// "...Barbell", "...Dumbbell"), so picking an exercise was one flat search.
// Now it's two steps: pick the movement, then its equipment (plus an optional
// free-text detail — "Seated", "Cuffed"). This is the one place that two-step
// flow lives; every screen that lets the user add or swap an exercise
// (guided builder, DIY builder, active-workout add/swap) renders this list
// and gets back a resolved ExerciseResponse exactly like the old flat picker
// did, so nothing downstream of "an exercise got added" had to change.
//
// A movement already added to the workout is NOT hidden here — a different
// equipment variant of the same movement (barbell bench pre-fatigue, then
// machine) is a legitimate second entry. Exact-duplicate prevention happens
// after resolving, in the caller, which already knows its own exercise ids.

export function MovementPickerList({
  search,
  onResolved,
  isSimilar,
  emptyLabel,
}: {
  search: string;
  onResolved: (exercise: ExerciseResponse) => void;
  /** Used by the swap screen to surface muscle-sharing movements first. */
  isSimilar?: (movement: MovementResponse) => boolean;
  emptyLabel?: string;
}) {
  const { data: movements, isLoading } = useQuery({
    queryKey: ['movements'],
    queryFn: movementsApi.list,
  });

  const [expandedId, setExpandedId] = useState<number | null>(null);

  const q = search.trim().toLowerCase();
  const filtered = (movements ?? []).filter((m) => m.name.toLowerCase().includes(q));
  const sorted = isSimilar
    ? [...filtered].sort((a, b) => {
        const rank = Number(!isSimilar(a)) - Number(!isSimilar(b));
        return rank !== 0 ? rank : a.name.localeCompare(b.name);
      })
    : filtered;

  if (isLoading) {
    return <ActivityIndicator style={{ marginTop: Spacing.xl }} color={Colors.primary} />;
  }

  if (sorted.length === 0) {
    return (
      <Text style={{ padding: Spacing.lg, textAlign: 'center', color: Colors.textMuted }}>
        {emptyLabel ?? 'No exercises match your search.'}
      </Text>
    );
  }

  return (
    <>
      {sorted.map((movement) => (
        <MovementRow
          key={movement.id}
          movement={movement}
          expanded={expandedId === movement.id}
          onToggle={() => setExpandedId(expandedId === movement.id ? null : movement.id)}
          onResolved={(ex) => {
            setExpandedId(null);
            onResolved(ex);
          }}
          similar={isSimilar?.(movement)}
        />
      ))}
    </>
  );
}

function MovementRow({ movement, expanded, onToggle, onResolved, similar }: {
  movement: MovementResponse;
  expanded: boolean;
  onToggle: () => void;
  onResolved: (ex: ExerciseResponse) => void;
  similar?: boolean;
}) {
  // Pre-select the only option so a one-equipment movement (e.g. GHR,
  // bodyweight-only) can be added without an extra tap.
  const [equipmentId, setEquipmentId] = useState<number | null>(
    movement.equipmentOptions.length === 1 ? movement.equipmentOptions[0].id : null
  );
  const [variation, setVariation] = useState('');

  const { mutate: resolve, isPending } = useMutation({
    mutationFn: () => exercisesApi.resolve({
      movementId: movement.id,
      equipmentId,
      variation: variation.trim() || null,
    }),
    onSuccess: (ex) => {
      setVariation('');
      onResolved(ex);
    },
  });

  const primaryMuscles = movement.muscles.filter((m) => m.role === 'PRIMARY');

  return (
    <View style={{ borderBottomWidth: 1, borderBottomColor: Colors.border }}>
      <TouchableOpacity
        onPress={onToggle}
        style={{ flexDirection: 'row', alignItems: 'center', padding: Spacing.md,
          backgroundColor: expanded ? Colors.primaryTint : 'transparent' }}>
        <View style={{ flex: 1 }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
            <Text style={{ fontSize: FontSize.md, color: Colors.textPrimary,
              fontWeight: FontWeight.medium }}>{movement.name}</Text>
            {similar && (
              <View style={{ backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
                paddingHorizontal: 8, paddingVertical: 2 }}>
                <Text style={{ fontSize: 10, color: Colors.primary,
                  fontWeight: FontWeight.semibold }}>Similar</Text>
              </View>
            )}
          </View>
          {primaryMuscles.length > 0 && (
            <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginTop: 2 }}>
              {primaryMuscles.map((m) => m.muscleGroupName).join(', ')}
            </Text>
          )}
        </View>
        <Ionicons name={expanded ? 'chevron-up' : 'chevron-down'} size={18} color={Colors.textMuted} />
      </TouchableOpacity>

      {expanded && (
        <View style={{ paddingHorizontal: Spacing.md, paddingBottom: Spacing.md, gap: Spacing.sm }}>
          {movement.equipmentOptions.length > 0 && (
            <View>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted,
                fontWeight: FontWeight.medium, marginBottom: 6 }}>EQUIPMENT</Text>
              <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6 }}>
                {movement.equipmentOptions.map((eq) => {
                  const active = equipmentId === eq.id;
                  return (
                    <TouchableOpacity key={eq.id} onPress={() => setEquipmentId(eq.id)}
                      style={{ paddingHorizontal: 12, paddingVertical: 6, borderRadius: Radius.full,
                        backgroundColor: active ? Colors.primary : Colors.surface,
                        borderWidth: 1, borderColor: active ? Colors.primary : Colors.border }}>
                      <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.medium,
                        color: active ? Colors.textInverse : Colors.textPrimary }}>{eq.name}</Text>
                    </TouchableOpacity>
                  );
                })}
              </View>
            </View>
          )}

          <View>
            <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted,
              fontWeight: FontWeight.medium, marginBottom: 6 }}>DETAIL (OPTIONAL)</Text>
            <TextInput
              value={variation}
              onChangeText={setVariation}
              placeholder="e.g. Seated, Cuffed, 45 Degree"
              placeholderTextColor={Colors.textMuted}
              style={{ backgroundColor: Colors.surface, borderRadius: Radius.md,
                borderWidth: 1, borderColor: Colors.border, paddingHorizontal: 10,
                paddingVertical: 8, fontSize: FontSize.sm, color: Colors.textPrimary }}
            />
          </View>

          <TouchableOpacity
            onPress={() => resolve()}
            disabled={isPending || (movement.equipmentOptions.length > 0 && equipmentId == null)}
            style={{ backgroundColor: Colors.primary, borderRadius: Radius.md,
              paddingVertical: 10, alignItems: 'center',
              opacity: isPending || (movement.equipmentOptions.length > 0 && equipmentId == null) ? 0.6 : 1 }}>
            {isPending
              ? <ActivityIndicator size="small" color={Colors.textInverse} />
              : <Text style={{ color: Colors.textInverse, fontWeight: FontWeight.semibold,
                  fontSize: FontSize.sm }}>Add {movement.name}</Text>}
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
}
