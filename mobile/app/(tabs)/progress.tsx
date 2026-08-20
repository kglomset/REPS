import React, { useMemo, useState, useEffect } from 'react';
import {
  ActivityIndicator, ScrollView, Text, TouchableOpacity, View,
  useWindowDimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useQuery, useQueries } from '@tanstack/react-query';
import { Ionicons } from '@expo/vector-icons';
import { format } from 'date-fns';
import Svg, {
  Path, Circle, Rect, Defs, LinearGradient, Stop,
  Text as SvgText, Line as SvgLine,
} from 'react-native-svg';
import { progressApi } from '@/services/api/progress';
import { programsApi } from '@/services/api/programs';
import { ExerciseResponse, BodyWeightResponse, ProgressionTrend } from '@/types';
import { TrendBadge, TrendSheet } from '@/components/TrendBadge';
import { Colors, Spacing, Radius, FontSize, FontWeight, Shadow } from '@/constants/theme';
import { storage } from '@/utils/storage';

// ─── Types ──────────────────────────────────────────────────────────────────────

interface ChartPoint { x: number; y: number; }
interface ChartSeries { label: string; color: string; data: ChartPoint[]; }

interface TooltipState {
  px: number; py: number;
  xLabel: string; yLabel: string;
  seriesLabel: string;
  seriesIdx: number; pointIdx: number;
}

interface PersistedFilter {
  selectedWorkoutId: number | null;
  selectedExerciseIds: number[];
}

const SERIES_COLORS = [
  Colors.primary,
  Colors.success,
  '#F59E0B',
  '#8B5CF6',
  '#EC4899',
  '#06B6D4',
  '#F97316',
  '#10B981',
];
const FILTER_KEY = 'progress_filter_v1';

// ─── Grafana-style SVG line chart ───────────────────────────────────────────────

function GrafanaLineChart({ series, width, height, formatX, formatY, yUnit = '' }: {
  series: ChartSeries[];
  width: number;
  height: number;
  formatX: (v: number) => string;
  formatY: (v: number) => string;
  yUnit?: string;
}) {
  const [tooltip, setTooltip] = useState<TooltipState | null>(null);

  const allPoints = series.flatMap((s) => s.data);
  if (!allPoints.length) {
    return (
      <View style={{ height, alignItems: 'center', justifyContent: 'center' }}>
        <Text style={{ color: Colors.textMuted, fontSize: FontSize.sm }}>No data yet</Text>
      </View>
    );
  }

  const PAD = { top: 16, right: 16, bottom: 30, left: 44 };
  const W   = width  - PAD.left - PAD.right;
  const H   = height - PAD.top  - PAD.bottom;

  const xMin = Math.min(...allPoints.map((p) => p.x));
  const xMax = Math.max(...allPoints.map((p) => p.x));
  const yMin = Math.min(...allPoints.map((p) => p.y));
  const yMax = Math.max(...allPoints.map((p) => p.y));

  const xRange = xMax - xMin || 1;
  const yPad   = (yMax - yMin) * 0.15 || 2;
  const yLow   = yMin - yPad;
  const yHigh  = yMax + yPad;
  const yRange = yHigh - yLow;

  const xOf = (v: number) => PAD.left + ((v - xMin) / xRange) * W;
  const yOf = (v: number) => PAD.top  + (1 - (v - yLow) / yRange) * H;

  function buildLinePath(pts: ChartPoint[]): string {
    if (pts.length < 2) return '';
    const s = pts.map((p) => ({ x: xOf(p.x), y: yOf(p.y) }));
    let d = `M ${s[0].x.toFixed(1)} ${s[0].y.toFixed(1)}`;
    for (let i = 0; i < s.length - 1; i++) {
      const dx = (s[i + 1].x - s[i].x) * 0.4;
      d += ` C ${(s[i].x + dx).toFixed(1)} ${s[i].y.toFixed(1)},`
        + `${(s[i + 1].x - dx).toFixed(1)} ${s[i + 1].y.toFixed(1)},`
        + `${s[i + 1].x.toFixed(1)} ${s[i + 1].y.toFixed(1)}`;
    }
    return d;
  }

  function buildFillPath(pts: ChartPoint[]): string {
    const line = buildLinePath(pts);
    if (!line) return '';
    const s = pts.map((p) => ({ x: xOf(p.x), y: yOf(p.y) }));
    const bottom = (PAD.top + H).toFixed(1);
    return `${line} L ${s[s.length - 1].x.toFixed(1)} ${bottom} L ${s[0].x.toFixed(1)} ${bottom} Z`;
  }

  const yTicks = Array.from({ length: 5 }, (_, i) => {
    const v = yLow + (i / 4) * yRange;
    return { yPx: yOf(v), label: formatY(v) };
  });

  const xTickN = Math.min(5, allPoints.length);
  const xStep  = xRange / Math.max(xTickN - 1, 1);
  const xTicks = Array.from({ length: xTickN }, (_, i) => {
    const v = xMin + i * xStep;
    return { xPx: xOf(v), label: formatX(v) };
  });

  const handlePointPress = (
    si: number, pi: number,
    px: number, py: number,
    xLabel: string, yLabel: string,
    seriesLabel: string,
  ) => {
    if (tooltip?.seriesIdx === si && tooltip?.pointIdx === pi) {
      setTooltip(null);
    } else {
      setTooltip({ px, py, xLabel, yLabel, seriesLabel, seriesIdx: si, pointIdx: pi });
    }
  };

  return (
    <View>
      <Svg width={width} height={height}>
        <Defs>
          {series.map((s, i) => (
            <LinearGradient key={i} id={`grad_${i}`} x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0%" stopColor={s.color} stopOpacity={0.22} />
              <Stop offset="100%" stopColor={s.color} stopOpacity={0.01} />
            </LinearGradient>
          ))}
        </Defs>

        {/* Grid lines */}
        {yTicks.map((t, i) => (
          <SvgLine key={i} x1={PAD.left} y1={t.yPx} x2={PAD.left + W} y2={t.yPx}
            stroke={Colors.border} strokeWidth={0.5} />
        ))}

        {/* Y axis labels */}
        {yTicks.map((t, i) => (
          <SvgText key={i} x={PAD.left - 5} y={t.yPx + 3.5}
            fontSize={9} fill={Colors.textMuted} textAnchor="end">
            {t.label}
          </SvgText>
        ))}

        {/* X axis labels */}
        {xTicks.map((t, i) => (
          <SvgText key={i} x={t.xPx} y={PAD.top + H + 18}
            fontSize={9} fill={Colors.textMuted} textAnchor="middle">
            {t.label}
          </SvgText>
        ))}

        {/* Series: gradient fill + smooth line + dots */}
        {series.map((s, si) => {
          if (s.data.length < 1) return null;
          const pts = s.data.map((p) => ({ x: xOf(p.x), y: yOf(p.y), orig: p }));
          return (
            <React.Fragment key={si}>
              {s.data.length >= 2 && (
                <>
                  <Path d={buildFillPath(s.data)} fill={`url(#grad_${si})`} />
                  <Path d={buildLinePath(s.data)} stroke={s.color} strokeWidth={2}
                    fill="none" strokeLinecap="round" strokeLinejoin="round" />
                </>
              )}
              {pts.map((pt, pi) => (
                <Circle key={pi} cx={pt.x} cy={pt.y} r={4}
                  fill={Colors.surface} stroke={s.color} strokeWidth={2}
                  opacity={tooltip?.seriesIdx === si && tooltip?.pointIdx === pi ? 1 : 0} />
              ))}
              {pts.map((pt, pi) => (
                <Circle key={`h${pi}`} cx={pt.x} cy={pt.y} r={14}
                  fill="transparent"
                  onPress={() => handlePointPress(
                    si, pi, pt.x, pt.y,
                    formatX(pt.orig.x),
                    `${formatY(pt.orig.y)}${yUnit}`,
                    s.label,
                  )}
                />
              ))}
            </React.Fragment>
          );
        })}

        {/* Tooltip */}
        {tooltip && (() => {
          const TW = 110; const TH = 40; const RAD = 6;
          const tx = Math.min(Math.max(tooltip.px - TW / 2, PAD.left), PAD.left + W - TW);
          const ty = tooltip.py > PAD.top + H / 2
            ? tooltip.py - TH - 10
            : tooltip.py + 10;
          return (
            <>
              <Rect x={tx} y={ty} width={TW} height={TH} rx={RAD}
                fill={Colors.textPrimary} opacity={0.93} />
              <SvgText x={tx + TW / 2} y={ty + 13}
                fontSize={9} fill="rgba(255,255,255,0.7)" textAnchor="middle">
                {tooltip.xLabel} · {tooltip.seriesLabel}
              </SvgText>
              <SvgText x={tx + TW / 2} y={ty + 28}
                fontSize={13} fill={Colors.textInverse} textAnchor="middle"
                fontWeight="bold">
                {tooltip.yLabel}
              </SvgText>
            </>
          );
        })()}
      </Svg>

      {/* Legend — only for multi-series */}
      {series.length > 1 && (
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 10, marginTop: 4 }}>
          {series.map((s, i) => (
            <View key={i} style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
              <View style={{ width: 14, height: 3, backgroundColor: s.color, borderRadius: 2 }} />
              <Text style={{ fontSize: 10, color: Colors.textSecondary }}>{s.label}</Text>
            </View>
          ))}
        </View>
      )}
    </View>
  );
}

// ─── Filter chip ────────────────────────────────────────────────────────────────

function FilterChip({ label, active, onPress, activeColor }: {
  label: string;
  active: boolean;
  onPress: () => void;
  activeColor?: string;
}) {
  const color = activeColor ?? Colors.primary;
  return (
    <TouchableOpacity
      onPress={onPress}
      style={{
        paddingHorizontal: 10, paddingVertical: 4, borderRadius: Radius.full,
        backgroundColor: active ? `${color}22` : Colors.surfaceSubtle,
        borderWidth: 1, borderColor: active ? color : Colors.border,
      }}>
      <Text style={{ fontSize: 10, fontWeight: FontWeight.medium,
        color: active ? color : Colors.textSecondary }}>{label}</Text>
    </TouchableOpacity>
  );
}

// ─── Workout progress card (one graph, one line per exercise) ────────────────────

function WorkoutProgressCard({ exercises, selectedIds, onToggle, chartWidth }: {
  exercises: ExerciseResponse[];
  selectedIds: number[];
  onToggle: (id: number) => void;
  chartWidth: number;
}) {
  const progressQueries = useQueries({
    queries: exercises.map((ex) => ({
      queryKey: ['exerciseProgress', ex.id],
      queryFn: () => progressApi.getExerciseProgress(ex.id),
    })),
  });

  const isLoading = progressQueries.some((q) => q.isLoading);

  // Build one series per toggled-on exercise using set-1 weight per session date
  const series = useMemo((): ChartSeries[] => {
    return exercises
      .map((ex, i) => {
        if (!selectedIds.includes(ex.id)) return null;
        const data = progressQueries[i]?.data;
        if (!data) return null;
        const set1 = data.series
          .filter((p) => p.setNumber === 1)
          .sort((a, b) => a.date.localeCompare(b.date));
        if (!set1.length) return null;
        return {
          label: ex.name,
          color: SERIES_COLORS[i % SERIES_COLORS.length],
          data: set1.map((p) => ({
            x: new Date(p.date).getTime(),
            y: Number(p.weightKg ?? 0),
          })),
        } as ChartSeries;
      })
      .filter((s): s is ChartSeries => s !== null);
  }, [exercises, selectedIds, progressQueries]);

  return (
    <View style={{
      backgroundColor: Colors.surface, borderRadius: Radius.xl,
      padding: Spacing.md, marginBottom: Spacing.md, ...Shadow.card,
    }}>
      {/* Header */}
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: Spacing.sm }}>
        <Ionicons name="trending-up-outline" size={16} color={Colors.textSecondary} />
        <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
          color: Colors.textPrimary }}>Weight Progress</Text>
        <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>· kg, set 1</Text>
      </View>

      {/* Exercise toggles — colored to match their line */}
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginBottom: Spacing.md }}>
        {exercises.map((ex, i) => (
          <FilterChip
            key={ex.id}
            label={ex.name}
            active={selectedIds.includes(ex.id)}
            onPress={() => onToggle(ex.id)}
            activeColor={SERIES_COLORS[i % SERIES_COLORS.length]}
          />
        ))}
      </View>

      {/* Chart */}
      {isLoading ? (
        <View style={{ height: 240, alignItems: 'center', justifyContent: 'center' }}>
          <ActivityIndicator color={Colors.primary} />
        </View>
      ) : (
        <GrafanaLineChart
          series={series}
          width={chartWidth}
          height={240}
          formatX={(v) => format(new Date(v), 'MMM d')}
          formatY={(v) => `${Math.round(v)}`}
          yUnit="kg"
        />
      )}
    </View>
  );
}

// ─── Exercise tile (All mode) ────────────────────────────────────────────────────

function ExerciseTile({ exercise, chartWidth, trend }: {
  exercise: ExerciseResponse;
  chartWidth: number;
  /** Week-to-week trend; absent until the exercise has two completed sessions. */
  trend?: ProgressionTrend;
}) {
  const [trendOpen, setTrendOpen]           = useState(false);
  const [expanded, setExpanded]             = useState(false);
  const [chartType, setChartType]           = useState<'weight' | 'reps'>('weight');
  const [selectedWeight, setSelectedWeight] = useState<number | null>(null);
  const [showMyoreps, setShowMyoreps]       = useState(false);

  const { data: progressData, isLoading } = useQuery({
    queryKey: ['exerciseProgress', exercise.id],
    queryFn: () => progressApi.getExerciseProgress(exercise.id),
    enabled: expanded,
  });

  const primaryMuscles   = exercise.muscles.filter((m) => m.role === 'PRIMARY');
  const secondaryMuscles = exercise.muscles.filter((m) => m.role === 'SECONDARY');

  // Myo-rep and straight-set performance are graphed separately so one doesn't
  // distort the other. Straight sets are the default; the myo-reps view only
  // appears when there is myo-rep data. Both views offer the same weight/reps
  // toggle — in the myo-rep view "weight" is the activation-set load, which is
  // the working weight every mini-set in the cluster shares.
  const hasMyoreps = useMemo(
    () => !!progressData?.series.some((p) => p.trainingMethod === 'MYOREPS'),
    [progressData]
  );
  const myoActive = showMyoreps && hasMyoreps;
  const effectiveChartType: 'weight' | 'reps' = chartType;

  // Points for the active mode: myo-reps only, or everything except myo-reps.
  const methodPoints = useMemo(() => {
    if (!progressData) return [];
    return progressData.series.filter((p) =>
      myoActive ? p.trainingMethod === 'MYOREPS' : p.trainingMethod !== 'MYOREPS'
    );
  }, [progressData, myoActive]);

  const availableWeights = useMemo(() => {
    const seen = new Set<number>();
    const result: number[] = [];
    for (const p of methodPoints) {
      if (p.weightKg == null) continue;
      const w = Number(p.weightKg);
      if (!seen.has(w)) { seen.add(w); result.push(w); }
    }
    return result.sort((a, b) => a - b);
  }, [methodPoints]);

  const series = useMemo((): ChartSeries[] => {
    if (!methodPoints.length) return [];

    if (effectiveChartType === 'weight') {
      const set1 = methodPoints
        .filter((p) => p.setNumber === 1)
        .sort((a, b) => a.date.localeCompare(b.date));
      if (!set1.length) return [];
      return [{
        label: myoActive ? 'Activation weight' : 'Weight',
        color: SERIES_COLORS[0],
        data: set1.map((p) => ({
          x: new Date(p.date).getTime(),
          y: Number(p.weightKg ?? 0),
        })),
      }];
    }

    let pts = methodPoints;
    if (selectedWeight !== null) {
      pts = pts.filter((p) => Math.abs(Number(p.weightKg) - selectedWeight) < 0.01);
    }
    const setNums = [...new Set(pts.map((p) => p.setNumber))].sort((a, b) => a - b);
    return setNums.slice(0, 4).map((sn, i) => ({
      label: `Set ${sn}`,
      color: SERIES_COLORS[i],
      data: pts
        .filter((p) => p.setNumber === sn)
        .sort((a, b) => a.date.localeCompare(b.date))
        .map((p) => ({
          x: new Date(p.date).getTime(),
          y: p.reps,
        })),
    }));
  }, [methodPoints, effectiveChartType, selectedWeight, myoActive]);

  const toggleWeight = (w: number) =>
    setSelectedWeight((prev) => (prev !== null && Math.abs(prev - w) < 0.01 ? null : w));

  return (
    <View style={{
      backgroundColor: Colors.surface, borderRadius: Radius.xl,
      padding: Spacing.md, marginBottom: Spacing.md, ...Shadow.card,
    }}>
      {/* Header */}
      <TouchableOpacity
        onPress={() => setExpanded((v) => !v)}
        style={{ flexDirection: 'row', alignItems: 'flex-start', justifyContent: 'space-between' }}
        activeOpacity={0.7}
      >
        <View style={{ flex: 1, marginRight: Spacing.sm }}>
          <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
            color: Colors.textPrimary }}>{exercise.name}</Text>
          <View style={{ flexDirection: 'row', gap: 4, marginTop: 4, flexWrap: 'wrap' }}>
            {primaryMuscles.map((m) => (
              <View key={`p-${m.muscleGroupId}`} style={{
                backgroundColor: Colors.primaryTint, borderRadius: Radius.full,
                paddingHorizontal: 7, paddingVertical: 1,
              }}>
                <Text style={{ fontSize: 10, color: Colors.primary }}>{m.muscleGroupName}</Text>
              </View>
            ))}
            {secondaryMuscles.map((m) => (
              <View key={`s-${m.muscleGroupId}`} style={{
                backgroundColor: Colors.surfaceSubtle, borderRadius: Radius.full,
                paddingHorizontal: 7, paddingVertical: 1,
                borderWidth: 1, borderColor: Colors.border,
              }}>
                <Text style={{ fontSize: 10, color: Colors.textSecondary }}>{m.muscleGroupName}</Text>
              </View>
            ))}
          </View>
        </View>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: Spacing.sm }}>
          {/* Week-to-week trend — tap for the set-by-set breakdown */}
          {trend && <TrendBadge trend={trend} size={22} onPress={() => setTrendOpen(true)} />}
          <Ionicons name={expanded ? 'chevron-up' : 'chevron-down'} size={18} color={Colors.textMuted} />
        </View>
      </TouchableOpacity>

      {trendOpen && trend && (
        <TrendSheet
          exerciseName={exercise.name}
          trend={trend}
          onClose={() => setTrendOpen(false)}
        />
      )}

      {/* Expanded content */}
      {expanded && (
        <View style={{ marginTop: Spacing.md }}>
          {/* Data-mode toggle — only shown when the exercise has myo-rep data.
              Straight sets is the default; myo-reps tracks that method alone. */}
          {hasMyoreps && (
            <View style={{ flexDirection: 'row', gap: 6, marginBottom: Spacing.sm }}>
              {([['straight', 'Straight sets'], ['myoreps', 'Myo-reps']] as const).map(([mode, label]) => {
                const active = mode === 'myoreps' ? myoActive : !myoActive;
                return (
                  <TouchableOpacity
                    key={mode}
                    onPress={() => { setShowMyoreps(mode === 'myoreps'); setSelectedWeight(null); }}
                    style={{
                      paddingHorizontal: 12, paddingVertical: 6, borderRadius: Radius.full,
                      backgroundColor: active ? Colors.primary : Colors.surfaceSubtle,
                      borderWidth: 1, borderColor: active ? Colors.primary : 'transparent',
                    }}>
                    <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.medium,
                      color: active ? Colors.textInverse : Colors.textSecondary }}>{label}</Text>
                  </TouchableOpacity>
                );
              })}
            </View>
          )}

          {/* Chart type toggle — available in both the straight-set and myo-rep
              views. For myo-reps, "weight" plots the activation-set load. */}
          <View style={{ flexDirection: 'row', gap: 6, marginBottom: Spacing.sm }}>
            {(['weight', 'reps'] as const).map((ct) => (
              <TouchableOpacity
                key={ct}
                onPress={() => { setChartType(ct); setSelectedWeight(null); }}
                style={{
                  paddingHorizontal: 12, paddingVertical: 6, borderRadius: Radius.full,
                  backgroundColor: chartType === ct ? Colors.primaryTint : Colors.surfaceSubtle,
                  borderWidth: 1, borderColor: chartType === ct ? Colors.primary : 'transparent',
                }}>
                <Text style={{ fontSize: FontSize.xs, fontWeight: FontWeight.medium,
                  color: chartType === ct ? Colors.primary : Colors.textSecondary }}>
                  {ct === 'weight'
                    ? (myoActive ? 'Activation weight (kg)' : 'Weight (kg)')
                    : 'Reps'}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          {/* Weight filter — reps view (straight or myo-reps) */}
          {effectiveChartType === 'reps' && availableWeights.length > 1 && (
            <View style={{ marginBottom: Spacing.xs }}>
              <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, marginBottom: 4 }}>
                At weight:
              </Text>
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                <View style={{ flexDirection: 'row', gap: 4 }}>
                  {availableWeights.map((w) => (
                    <FilterChip
                      key={w}
                      label={`${w}kg`}
                      active={selectedWeight !== null && Math.abs(selectedWeight - w) < 0.01}
                      onPress={() => toggleWeight(w)}
                    />
                  ))}
                </View>
              </ScrollView>
            </View>
          )}

          {/* Chart */}
          {isLoading ? (
            <View style={{ height: 160, alignItems: 'center', justifyContent: 'center' }}>
              <ActivityIndicator color={Colors.primary} />
            </View>
          ) : (
            <GrafanaLineChart
              series={series}
              width={chartWidth}
              height={220}
              formatX={(v) => format(new Date(v), 'MMM d')}
              formatY={(v) => `${Math.round(v)}`}
              yUnit={effectiveChartType === 'weight' ? 'kg' : ''}
            />
          )}
        </View>
      )}
    </View>
  );
}

// ─── Body weight chart card ─────────────────────────────────────────────────────

function BodyWeightChartCard({ bodyWeights, chartWidth }: {
  bodyWeights: BodyWeightResponse[];
  chartWidth: number;
}) {
  const series: ChartSeries[] = useMemo(() => {
    if (bodyWeights.length < 2) return [];
    return [{
      label: 'Body Weight',
      color: Colors.success,
      data: bodyWeights.map((b) => ({
        x: new Date(b.logDate).getTime(),
        y: Number(b.weightKg),
      })),
    }];
  }, [bodyWeights]);

  if (!series.length) return null;

  return (
    <View style={{
      backgroundColor: Colors.surface, borderRadius: Radius.xl,
      padding: Spacing.md, ...Shadow.card, marginBottom: Spacing.md,
    }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: Spacing.sm }}>
        <Ionicons name="body-outline" size={16} color={Colors.textSecondary} />
        <Text style={{ fontSize: FontSize.md, fontWeight: FontWeight.semibold,
          color: Colors.textPrimary }}>Body Weight</Text>
      </View>
      <GrafanaLineChart
        series={series}
        width={chartWidth}
        height={200}
        formatX={(v) => format(new Date(v), 'MMM d')}
        formatY={(v) => v.toFixed(1)}
        yUnit="kg"
      />
    </View>
  );
}

// ─── Screen ─────────────────────────────────────────────────────────────────────

export default function ProgressScreen() {
  const { width: screenWidth } = useWindowDimensions();
  const chartWidth = screenWidth - 2 * Spacing.lg - 2 * Spacing.md;

  const [filtersOpen, setFiltersOpen]               = useState(false);
  const [selectedWorkoutId, setSelectedWorkoutId]   = useState<number | null>(null);
  const [selectedExerciseIds, setSelectedExerciseIds] = useState<number[]>([]);
  const [filterLoaded, setFilterLoaded]             = useState(false);

  // Hydrate persisted filter on mount
  useEffect(() => {
    storage.getItem(FILTER_KEY).then((raw) => {
      if (raw) {
        try {
          const f: PersistedFilter = JSON.parse(raw);
          setSelectedWorkoutId(f.selectedWorkoutId ?? null);
          setSelectedExerciseIds(f.selectedExerciseIds ?? []);
        } catch {}
      }
      setFilterLoaded(true);
    });
  }, []);

  // Persist filter whenever it changes
  useEffect(() => {
    if (!filterLoaded) return;
    const f: PersistedFilter = { selectedWorkoutId, selectedExerciseIds };
    storage.setItem(FILTER_KEY, JSON.stringify(f)).catch(() => {});
  }, [selectedWorkoutId, selectedExerciseIds, filterLoaded]);

  const { data: program } = useQuery({
    queryKey: ['activeProgram'],
    queryFn: programsApi.getActive,
  });
  const { data: bodyWeights } = useQuery({
    queryKey: ['bodyWeight'],
    queryFn: progressApi.getBodyWeightHistory,
  });
  // One call for every exercise's week-to-week trend, so the arrows are on the
  // tiles without expanding them. Invalidated when a workout is completed.
  const { data: trends } = useQuery({
    queryKey: ['exerciseTrends'],
    queryFn: progressApi.getTrends,
  });
  const trendsByExercise = useMemo(() => {
    const map: Record<number, ProgressionTrend> = {};
    (trends ?? []).forEach((t) => { map[t.exerciseId] = t.trend; });
    return map;
  }, [trends]);

  const workoutTemplates = program?.workoutTemplates ?? [];

  // Exercises available for the filter panel (scoped by selected workout)
  const exercisesForFilter: ExerciseResponse[] = useMemo(() => {
    if (selectedWorkoutId === null) {
      const all = workoutTemplates.flatMap((t) => t.exercises.map((e) => e.exercise));
      return all.filter((e, i, arr) => arr.findIndex((x) => x.id === e.id) === i);
    }
    const tmpl = workoutTemplates.find((t) => t.id === selectedWorkoutId);
    return tmpl?.exercises.map((e) => e.exercise) ?? [];
  }, [workoutTemplates, selectedWorkoutId]);

  // Exercises to show in "All" mode (individual tiles)
  const visibleExercises: ExerciseResponse[] = useMemo(() => {
    if (selectedExerciseIds.length === 0) return [];
    return exercisesForFilter.filter((e) => selectedExerciseIds.includes(e.id));
  }, [exercisesForFilter, selectedExerciseIds]);

  const handleWorkoutSelect = (id: number | null) => {
    setSelectedWorkoutId(id);
    if (id !== null) {
      // Auto-select all exercises for the chosen workout
      const tmpl = workoutTemplates.find((t) => t.id === id);
      const allIds = tmpl?.exercises.map((e) => e.exercise.id) ?? [];
      setSelectedExerciseIds(allIds);
    }
  };

  const toggleExercise = (id: number) => {
    setSelectedExerciseIds((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );
  };

  const filterSummary = selectedWorkoutId !== null
    ? (workoutTemplates.find((t) => t.id === selectedWorkoutId)?.name ?? 'Workout')
    : selectedExerciseIds.length === 0
      ? 'Body weight only'
      : `${selectedExerciseIds.length} exercise${selectedExerciseIds.length === 1 ? '' : 's'} selected`;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: Colors.surfaceMuted }}>
      <ScrollView contentContainerStyle={{ padding: Spacing.lg, paddingBottom: 100 }}>

        {/* Title */}
        <Text style={{ fontSize: FontSize.xxl, fontWeight: FontWeight.bold,
          color: Colors.textPrimary, marginBottom: Spacing.lg }}>Progress</Text>

        {/* Collapsible filter section */}
        {workoutTemplates.length > 0 && (
          <View style={{ marginBottom: Spacing.md }}>
            <TouchableOpacity
              onPress={() => setFiltersOpen((v) => !v)}
              activeOpacity={0.7}
              style={{
                flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
                backgroundColor: Colors.surface,
                borderTopLeftRadius: Radius.xl,
                borderTopRightRadius: Radius.xl,
                borderBottomLeftRadius: filtersOpen ? 0 : Radius.xl,
                borderBottomRightRadius: filtersOpen ? 0 : Radius.xl,
                padding: Spacing.md,
                ...Shadow.card,
              }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                <Ionicons name="filter-outline" size={16} color={Colors.textSecondary} />
                <Text style={{ fontSize: FontSize.sm, fontWeight: FontWeight.medium,
                  color: Colors.textPrimary }}>Filters</Text>
                <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>
                  — {filterSummary}
                </Text>
              </View>
              <Ionicons name={filtersOpen ? 'chevron-up' : 'chevron-down'}
                size={16} color={Colors.textMuted} />
            </TouchableOpacity>

            {filtersOpen && (
              <View style={{
                backgroundColor: Colors.surface,
                borderBottomLeftRadius: Radius.xl,
                borderBottomRightRadius: Radius.xl,
                padding: Spacing.md,
                borderTopWidth: 1,
                borderTopColor: Colors.border,
                ...Shadow.card,
              }}>
                {/* Workout chips */}
                <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary,
                  fontWeight: FontWeight.medium, marginBottom: 6 }}>Workout</Text>
                <ScrollView horizontal showsHorizontalScrollIndicator={false}
                  style={{ marginBottom: Spacing.md }}>
                  <View style={{ flexDirection: 'row', gap: 6 }}>
                    <FilterChip label="All" active={selectedWorkoutId === null}
                      onPress={() => handleWorkoutSelect(null)} />
                    {workoutTemplates.map((t) => (
                      <FilterChip key={t.id} label={t.name}
                        active={selectedWorkoutId === t.id}
                        onPress={() => handleWorkoutSelect(
                          selectedWorkoutId === t.id ? null : t.id
                        )} />
                    ))}
                  </View>
                </ScrollView>

                {/* Exercise chips — only in All mode */}
                {selectedWorkoutId === null && (
                  <>
                    <Text style={{ fontSize: FontSize.xs, color: Colors.textSecondary,
                      fontWeight: FontWeight.medium, marginBottom: 6 }}>Exercises</Text>
                    {exercisesForFilter.length === 0 ? (
                      <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted }}>
                        No exercises found.
                      </Text>
                    ) : (
                      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6 }}>
                        {exercisesForFilter.map((ex) => (
                          <FilterChip key={ex.id} label={ex.name}
                            active={selectedExerciseIds.includes(ex.id)}
                            onPress={() => toggleExercise(ex.id)} />
                        ))}
                      </View>
                    )}
                  </>
                )}

                {/* Hint in workout mode */}
                {selectedWorkoutId !== null && (
                  <Text style={{ fontSize: FontSize.xs, color: Colors.textMuted, fontStyle: 'italic' }}>
                    Toggle individual exercises directly on the chart below.
                  </Text>
                )}
              </View>
            )}
          </View>
        )}

        {/* Workout mode: single combined graph */}
        {selectedWorkoutId !== null && exercisesForFilter.length > 0 && (
          <WorkoutProgressCard
            exercises={exercisesForFilter}
            selectedIds={selectedExerciseIds}
            onToggle={toggleExercise}
            chartWidth={chartWidth}
          />
        )}

        {/* All mode: individual exercise tiles */}
        {selectedWorkoutId === null && visibleExercises.map((ex) => (
          <ExerciseTile key={ex.id} exercise={ex} chartWidth={chartWidth}
            trend={trendsByExercise[ex.id]} />
        ))}

        {/* Body weight — always shown when data exists */}
        {(bodyWeights?.length ?? 0) >= 2 && (
          <BodyWeightChartCard bodyWeights={bodyWeights!} chartWidth={chartWidth} />
        )}

        {/* Empty state */}
        {selectedWorkoutId === null && visibleExercises.length === 0 && (bodyWeights?.length ?? 0) < 2 && (
          <View style={{ backgroundColor: Colors.surface, borderRadius: Radius.xl,
            padding: Spacing.xl, alignItems: 'center', ...Shadow.card }}>
            <Ionicons name="trending-up-outline" size={36} color={Colors.textMuted} />
            <Text style={{ color: Colors.textMuted, marginTop: Spacing.sm,
              fontSize: FontSize.sm, textAlign: 'center' }}>
              Log workouts and body weight to track your progress.
            </Text>
          </View>
        )}

      </ScrollView>
    </SafeAreaView>
  );
}
