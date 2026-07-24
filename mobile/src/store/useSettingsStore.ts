import { create } from 'zustand';
import { storage } from '@/utils/storage';

const KEY_GOAL  = 'settings_weight_goal';
const KEY_START = 'settings_start_weight';
const KEY_SKIP  = 'settings_skipped_workouts';

/** Map key: `${weekKey}:${templateId}` -> true. Old weeks are pruned on write. */
type SkipMap = Record<string, boolean>;

interface SettingsState {
  weightGoal:   number | undefined;
  startWeight:  number | undefined;
  skipped:      SkipMap;
  isHydrated:   boolean;
  hydrate:      () => Promise<void>;
  setWeightGoal:  (v: number | undefined) => Promise<void>;
  setStartWeight: (v: number | undefined) => Promise<void>;
  /** Skip a workout for a single week (chip disappears from that week only). */
  skipWorkout:    (weekKey: string, templateId: number) => Promise<void>;
  unskipWorkout:  (weekKey: string, templateId: number) => Promise<void>;
}

export const useSettingsStore = create<SettingsState>((set, get) => ({
  weightGoal:  undefined,
  startWeight: undefined,
  skipped:     {},
  isHydrated:  false,

  hydrate: async () => {
    try {
      const goalStr  = await storage.getItem(KEY_GOAL);
      const startStr = await storage.getItem(KEY_START);
      const skipStr  = await storage.getItem(KEY_SKIP);
      set({
        weightGoal:  goalStr  ? parseFloat(goalStr)  : undefined,
        startWeight: startStr ? parseFloat(startStr) : undefined,
        skipped:     skipStr  ? JSON.parse(skipStr)  : {},
        isHydrated: true,
      });
    } catch {
      set({ isHydrated: true });
    }
  },

  setWeightGoal: async (v) => {
    try {
      if (v !== undefined) await storage.setItem(KEY_GOAL, String(v));
      else await storage.deleteItem(KEY_GOAL);
    } catch {}
    set({ weightGoal: v });
  },

  setStartWeight: async (v) => {
    try {
      if (v !== undefined) await storage.setItem(KEY_START, String(v));
      else await storage.deleteItem(KEY_START);
    } catch {}
    set({ startWeight: v });
  },

  skipWorkout: async (weekKey, templateId) => {
    // Keep only the current week's entries so the map doesn't grow forever.
    const pruned: SkipMap = {};
    for (const [k, v] of Object.entries(get().skipped)) {
      if (v && k.startsWith(`${weekKey}:`)) pruned[k] = true;
    }
    pruned[`${weekKey}:${templateId}`] = true;
    try { await storage.setItem(KEY_SKIP, JSON.stringify(pruned)); } catch {}
    set({ skipped: pruned });
  },

  unskipWorkout: async (weekKey, templateId) => {
    const next = { ...get().skipped };
    delete next[`${weekKey}:${templateId}`];
    try { await storage.setItem(KEY_SKIP, JSON.stringify(next)); } catch {}
    set({ skipped: next });
  },
}));
