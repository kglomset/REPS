import React, { useRef, useState } from 'react';
import { LayoutChangeEvent, PanResponder, Text, TouchableOpacity, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors, Spacing, Radius, FontSize, FontWeight } from '@/constants/theme';

// ─── Volume slider ────────────────────────────────────────────────────────────
// Hand-rolled rather than pulled from a package: the app ships to web as well as
// native, and PanResponder behaves identically in both. Tap targets either side
// of the track give the same control without dragging, which matters on a phone
// held one-handed in a gym.

export interface VolumeBand {
  label: string;
  min: number;
  max: number;
}

export function bandFor(value: number, bands: VolumeBand[]): VolumeBand | undefined {
  // Bands overlap on purpose, so the *last* one a value falls into wins —
  // 18 sets reads as Advanced rather than Intermediate.
  return [...bands].reverse().find((b) => value >= b.min && value <= b.max);
}

export function VolumeSlider({ value, min, max, onChange, bands }: {
  value: number;
  min: number;
  max: number;
  onChange: (v: number) => void;
  bands: VolumeBand[];
}) {
  const [width, setWidth] = useState(0);
  // PanResponder closes over its handlers once, so the live width and value have
  // to be read through refs rather than state.
  const widthRef = useRef(0);
  const valueRef = useRef(value);
  valueRef.current = value;

  const clamp = (v: number) => Math.max(min, Math.min(max, v));
  const clampRef = useRef(clamp);
  clampRef.current = clamp;
  const fromX = (x: number) => {
    if (widthRef.current <= 0) return valueRef.current;
    const ratio = Math.max(0, Math.min(1, x / widthRef.current));
    return clamp(Math.round(min + ratio * (max - min)));
  };

  // Drag is tracked relative to where it started rather than against the
  // track's absolute page position: measure() is unreliable on web, and dx is
  // the one value both platforms report the same way.
  const dragStart = useRef(value);
  const pan = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: (e) => {
        const tapped = fromX(e.nativeEvent.locationX);
        dragStart.current = tapped;
        onChange(tapped);
      },
      onPanResponderMove: (_e, g) => {
        if (widthRef.current <= 0) return;
        const delta = (g.dx / widthRef.current) * (max - min);
        onChange(clampRef.current(Math.round(dragStart.current + delta)));
      },
    })
  ).current;

  const onLayout = (e: LayoutChangeEvent) => {
    const w = e.nativeEvent.layout.width;
    widthRef.current = w;
    setWidth(w);
  };

  const ratio = max > min ? (value - min) / (max - min) : 0;
  const band = bandFor(value, bands);

  return (
    <View>
      {/* Value + band */}
      <View style={{ alignItems: 'center', marginBottom: Spacing.md }}>
        <Text style={{ fontSize: 44, fontWeight: FontWeight.bold, color: Colors.primary,
          fontVariant: ['tabular-nums'], lineHeight: 50 }}>{value}</Text>
        <Text style={{ fontSize: FontSize.sm, color: Colors.textSecondary }}>
          sets per muscle group, per week
        </Text>
        {band && (
          <View style={{ marginTop: 6, backgroundColor: Colors.primaryTint,
            borderRadius: Radius.full, paddingHorizontal: 12, paddingVertical: 4 }}>
            <Text style={{ fontSize: FontSize.xs, color: Colors.primary,
              fontWeight: FontWeight.semibold }}>{band.label} range</Text>
          </View>
        )}
      </View>

      {/* Track */}
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.sm }}>
        <StepButton icon="remove" onPress={() => onChange(clamp(value - 1))}
          disabled={value <= min} />
        <View
          style={{ flex: 1, justifyContent: 'center', height: 44 }}
          onLayout={onLayout}
          {...pan.panHandlers}
        >
          <View style={{ height: 6, borderRadius: 3, backgroundColor: Colors.surfaceSubtle }}>
            <View style={{ height: 6, borderRadius: 3, width: `${ratio * 100}%`,
              backgroundColor: Colors.primary }} />
          </View>
          {width > 0 && (
            <View
              pointerEvents="none"
              style={{ position: 'absolute', left: Math.max(0, ratio * width - 14),
                width: 28, height: 28, borderRadius: 14, backgroundColor: Colors.surface,
                borderWidth: 3, borderColor: Colors.primary }}
            />
          )}
        </View>
        <StepButton icon="add" onPress={() => onChange(clamp(value + 1))}
          disabled={value >= max} />
      </View>

      {/* Band scale under the track */}
      <View style={{ flexDirection: 'row', marginTop: Spacing.sm, gap: 4 }}>
        {bands.map((b) => {
          const active = band?.label === b.label;
          return (
            <View key={b.label} style={{ flex: 1, alignItems: 'center' }}>
              <View style={{ height: 3, alignSelf: 'stretch', borderRadius: 2,
                backgroundColor: active ? Colors.primary : Colors.border }} />
              <Text style={{ fontSize: 10, marginTop: 4,
                color: active ? Colors.primary : Colors.textMuted,
                fontWeight: active ? FontWeight.semibold : FontWeight.regular }}>
                {b.label}
              </Text>
              <Text style={{ fontSize: 10, color: Colors.textMuted }}>{b.min}–{b.max}</Text>
            </View>
          );
        })}
      </View>
    </View>
  );
}

function StepButton({ icon, onPress, disabled }: {
  icon: 'add' | 'remove';
  onPress: () => void;
  disabled: boolean;
}) {
  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled}
      style={{ width: 36, height: 36, borderRadius: 18, alignItems: 'center',
        justifyContent: 'center', borderWidth: 1, borderColor: Colors.border,
        backgroundColor: Colors.surface, opacity: disabled ? 0.35 : 1 }}>
      <Ionicons name={icon} size={18} color={Colors.textPrimary} />
    </TouchableOpacity>
  );
}
