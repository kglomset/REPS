import { create } from 'zustand';
import { storage } from '@/utils/storage';

const KEY_GOAL  = 'settings_weight_goal';
const KEY_START = 'settings_start_weight';

interface SettingsState {
  weightGoal:   number | undefined;
  startWeight:  number | undefined;
  isHydrated:   boolean;
  hydrate:      () => Promise<void>;
  setWeightGoal:  (v: number | undefined) => Promise<void>;
  setStartWeight: (v: number | undefined) => Promise<void>;
}

export const useSettingsStore = create<SettingsState>((set) => ({
  weightGoal:  undefined,
  startWeight: undefined,
  isHydrated:  false,

  hydrate: async () => {
    try {
      const goalStr  = await storage.getItem(KEY_GOAL);
      const startStr = await storage.getItem(KEY_START);
      set({
        weightGoal:  goalStr  ? parseFloat(goalStr)  : undefined,
        startWeight: startStr ? parseFloat(startStr) : undefined,
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
}));
