import { ExerciseMuscleResponse, MuscleRole, TrainingMethod } from '@/types';

// ─── Weekly volume accounting ─────────────────────────────────────────────────
// One place for the two rules that decide how many sets an exercise is worth,
// so the DIY builder, the guided builder and the backend allocator all report
// the same number for the same program.
//
// Mirrors ProgramBuilderService.creditFor and the MuscleRole enum's javadoc on
// the backend. If the weighting changes, it changes in both.

/** Myo-reps clusters are short, so a myo-reps exercise always counts as 3 sets. */
export const MYOREPS_COUNTED_SETS = 3;

/** A muscle worked as a secondary banks half a set — see MuscleRole. */
export const SECONDARY_CREDIT = 0.5;

export function countedSets(method: TrainingMethod, sets: number): number {
  return method === 'MYOREPS' ? MYOREPS_COUNTED_SETS : sets;
}

export function creditFor(role: MuscleRole, sets: number): number {
  return role === 'PRIMARY' ? sets : sets * SECONDARY_CREDIT;
}

/**
 * Two numbers, because they answer different questions.
 *
 * `direct` is what published set recommendations mean: sets where this muscle
 * is the movement's target. `total` adds half a set for every set that works
 * it as a secondary, which is what the program builder allocates against — a
 * bench press really does train triceps, just not at full value.
 *
 * Judge against whichever the target was written for. The DIY guide's fixed
 * ranges are direct-set advice; the guided builder's slider target is filled
 * with total credit.
 */
export interface MuscleVolume {
  direct: number;
  total: number;
}

export const EMPTY_VOLUME: MuscleVolume = { direct: 0, total: 0 };

export interface VolumeItem {
  muscles: ExerciseMuscleResponse[];
  method: TrainingMethod;
  sets: number;
}

/**
 * Weekly volume per muscle group name. A bench press at 3 sets banks 3 direct
 * sets to chest, and 1.5 total each to front delts and triceps — which is why a
 * program can cover the smaller muscles without a pile of isolation work.
 */
export function weeklyVolume(items: VolumeItem[]): Record<string, MuscleVolume> {
  const totals: Record<string, MuscleVolume> = {};
  for (const item of items) {
    const counted = countedSets(item.method, item.sets);
    for (const muscle of item.muscles) {
      const row = totals[muscle.muscleGroupName] ?? { direct: 0, total: 0 };
      if (muscle.role === 'PRIMARY') row.direct += counted;
      row.total += creditFor(muscle.role, counted);
      totals[muscle.muscleGroupName] = row;
    }
  }
  // Halves are the only fraction that can arise; round to keep float drift out
  // of what the user reads.
  for (const key of Object.keys(totals)) {
    totals[key] = {
      direct: Math.round(totals[key].direct * 2) / 2,
      total: Math.round(totals[key].total * 2) / 2,
    };
  }
  return totals;
}

/** "12" or "12.5" — never "12.0". */
export function formatSets(value: number): string {
  return Number.isInteger(value) ? String(value) : value.toFixed(1);
}

/**
 * "12 sets" when a muscle only ever trains directly, otherwise
 * "12 direct · 18 total".
 */
export function describeVolume(v: MuscleVolume): string {
  return v.direct === v.total
    ? `${formatSets(v.direct)} sets`
    : `${formatSets(v.direct)} direct · ${formatSets(v.total)} total`;
}
