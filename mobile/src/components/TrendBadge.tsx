import React from 'react';
import { Modal, ScrollView, Text, TouchableOpacity, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ProgressionTrend, TrendDirection } from '@/types';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';

// ─── Week-to-week trend ───────────────────────────────────────────────────────
// One arrow per exercise: up = progressing, flat = maintaining, down =
// regressing. The backend decides the direction (reps at the same load, or
// estimated 1RM when the load changed) and writes the sentence; this file only
// renders it. Used on active-workout tiles, the Progress tab and the workout
// summary, so the arrow means the same thing everywhere.

const TREND_STYLE: Record<TrendDirection, {
  icon: keyof typeof Ionicons.glyphMap;
  color: string;
  tint: string;
}> = {
  UP:   { icon: 'arrow-up',      color: Colors.success,       tint: Colors.successTint },
  FLAT: { icon: 'arrow-forward', color: Colors.textSecondary, tint: Colors.surfaceSubtle },
  DOWN: { icon: 'arrow-down',    color: Colors.error,         tint: Colors.errorTint },
};

export function trendStyle(direction: TrendDirection) {
  return TREND_STYLE[direction];
}

/** Tappable arrow pill. `size` matches the surrounding badges on each screen. */
export function TrendBadge({ trend, onPress, size = 24 }: {
  trend: ProgressionTrend;
  onPress: () => void;
  size?: number;
}) {
  const s = TREND_STYLE[trend.direction];
  return (
    <TouchableOpacity
      onPress={onPress}
      accessibilityLabel={`${trend.headline}. Tap for details.`}
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
      style={{
        width: size, height: size, borderRadius: size / 2,
        backgroundColor: s.tint, borderWidth: 1, borderColor: s.color,
        alignItems: 'center', justifyContent: 'center',
      }}>
      <Ionicons name={s.icon} size={Math.round(size * 0.55)} color={s.color} />
    </TouchableOpacity>
  );
}

/** Bottom sheet with the plain-language summary plus the set-by-set numbers. */
export function TrendSheet({ exerciseName, trend, onClose }: {
  exerciseName: string;
  trend: ProgressionTrend;
  onClose: () => void;
}) {
  const s = TREND_STYLE[trend.direction];
  const compared = formatComparison(trend);

  return (
    <Modal visible transparent animationType="slide" onRequestClose={onClose}>
      <TouchableOpacity
        style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.4)', justifyContent: 'flex-end' }}
        onPress={onClose} activeOpacity={1}>
        <TouchableOpacity activeOpacity={1} style={{
          backgroundColor: Colors.surface, borderTopLeftRadius: Radius.xl,
          borderTopRightRadius: Radius.xl, padding: Spacing.lg, paddingBottom: 36 }}>

          {/* Header */}
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.sm,
            marginBottom: Spacing.sm }}>
            <View style={{ width: 32, height: 32, borderRadius: 16,
              backgroundColor: s.tint, alignItems: 'center', justifyContent: 'center' }}>
              <Ionicons name={s.icon} size={18} color={s.color} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.bold,
                color: Colors.textPrimary }}>{trend.headline}</Text>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary }}>
                {exerciseName}{compared ? ` · ${compared}` : ''}
              </Text>
            </View>
          </View>

          {/* The sentence */}
          <Text style={{ fontSize: FontSize.sm, color: Colors.textPrimary,
            lineHeight: 20, marginBottom: Spacing.md }}>
            {trend.message}
          </Text>

          {/* Set-by-set numbers */}
          {trend.sets.length > 0 && (
            <View style={{ backgroundColor: Colors.surfaceMuted, borderRadius: Radius.md,
              paddingHorizontal: Spacing.md, paddingVertical: Spacing.sm,
              marginBottom: Spacing.md }}>
              <View style={{ flexDirection: 'row', paddingBottom: 6 }}>
                <Text style={[cell, { flex: 2, textAlign: 'left' }]}>Set</Text>
                <Text style={cell}>Last</Text>
                <Text style={cell}>This</Text>
                <Text style={cell}>Δ</Text>
              </View>
              <ScrollView style={{ maxHeight: 176 }}>
                {trend.sets.map((row) => {
                  const color = row.repsDelta > 0 ? Colors.success
                    : row.repsDelta < 0 ? Colors.error : Colors.textSecondary;
                  return (
                    <View key={row.setNumber} style={{ flexDirection: 'row', paddingVertical: 3 }}>
                      <Text style={[value, { flex: 2, textAlign: 'left',
                        color: Colors.textSecondary }]}>Set {row.setNumber}</Text>
                      <Text style={[value, { color: Colors.textMuted }]}>{row.previousReps}</Text>
                      <Text style={value}>{row.reps}</Text>
                      <Text style={[value, { color }]}>
                        {row.repsDelta > 0 ? `+${row.repsDelta}` : row.repsDelta === 0 ? '—' : row.repsDelta}
                      </Text>
                    </View>
                  );
                })}
              </ScrollView>
            </View>
          )}

          <TouchableOpacity onPress={onClose}
            style={{ alignItems: 'center', paddingVertical: 10 }}>
            <Text style={{ color: Colors.textSecondary, fontSize: FontSize.sm }}>Close</Text>
          </TouchableOpacity>
        </TouchableOpacity>
      </TouchableOpacity>
    </Modal>
  );
}

/** "vs 12 Aug" — omitted when the backend didn't send dates. */
function formatComparison(trend: ProgressionTrend): string | null {
  if (!trend.previousDate) return null;
  const d = new Date(trend.previousDate);
  if (Number.isNaN(d.getTime())) return null;
  return `vs ${d.toLocaleDateString(undefined, { day: 'numeric', month: 'short' })}`;
}

const cell: object = {
  flex: 1,
  fontSize: 10,
  color: Colors.textMuted,
  fontWeight: FontWeight.medium,
  textAlign: 'center',
  textTransform: 'uppercase',
  letterSpacing: 0.5,
};

const value: object = {
  flex: 1,
  fontSize: FontSize.sm,
  color: Colors.textPrimary,
  fontWeight: FontWeight.semibold,
  textAlign: 'center',
  fontVariant: ['tabular-nums'],
};
