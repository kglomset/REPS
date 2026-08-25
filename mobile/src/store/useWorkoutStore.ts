import { create } from 'zustand';
import { WorkoutSessionResponse } from '@/types';
import { workoutsApi } from '@/services/api/workouts';

interface WorkoutState {
  activeSession: WorkoutSessionResponse | null;
  restTimerActive: boolean;
  restTimerSeconds: number;
  restTimerRemaining: number;
  /**
   * Epoch ms the current rest ends at. The countdown text is driven by the
   * one-second tick, but the progress bar animates against this so it runs
   * smoothly and stays honest if a tick is late or dropped.
   */
  restTimerEndsAt: number | null;

  startSession: (templateId: number, date?: string) => Promise<WorkoutSessionResponse>;
  setActiveSession: (session: WorkoutSessionResponse | null) => void;

  startRestTimer: (seconds: number) => void;
  tickRestTimer: () => void;
  stopRestTimer: () => void;
}

export const useWorkoutStore = create<WorkoutState>((set) => ({
  activeSession: null,
  restTimerActive: false,
  restTimerSeconds: 120,
  restTimerRemaining: 0,
  restTimerEndsAt: null,

  startSession: async (templateId, date) => {
    const session = await workoutsApi.startSession(templateId, date);
    set({ activeSession: session });
    return session;
  },

  setActiveSession: (session) => set({ activeSession: session }),

  startRestTimer: (seconds) => {
    set({
      restTimerActive: true,
      restTimerSeconds: seconds,
      restTimerRemaining: seconds,
      restTimerEndsAt: Date.now() + seconds * 1000,
    });
  },

  tickRestTimer: () => {
    set((state) => {
      const remaining = state.restTimerRemaining - 1;
      return remaining <= 0
        ? { restTimerActive: false, restTimerRemaining: 0, restTimerEndsAt: null }
        : { restTimerRemaining: remaining };
    });
  },

  stopRestTimer: () =>
    set({ restTimerActive: false, restTimerRemaining: 0, restTimerEndsAt: null }),
}));
