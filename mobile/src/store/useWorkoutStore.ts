import { create } from 'zustand';
import { WorkoutSessionResponse } from '@/types';
import { workoutsApi } from '@/services/api/workouts';

interface WorkoutState {
  activeSession: WorkoutSessionResponse | null;
  restTimerActive: boolean;
  restTimerSeconds: number;
  restTimerRemaining: number;

  startSession: (templateId: number) => Promise<WorkoutSessionResponse>;
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

  startSession: async (templateId) => {
    const session = await workoutsApi.startSession(templateId);
    set({ activeSession: session });
    return session;
  },

  setActiveSession: (session) => set({ activeSession: session }),

  startRestTimer: (seconds) => {
    set({ restTimerActive: true, restTimerSeconds: seconds, restTimerRemaining: seconds });
  },

  tickRestTimer: () => {
    set((state) => {
      const remaining = state.restTimerRemaining - 1;
      return remaining <= 0
        ? { restTimerActive: false, restTimerRemaining: 0 }
        : { restTimerRemaining: remaining };
    });
  },

  stopRestTimer: () => set({ restTimerActive: false, restTimerRemaining: 0 }),
}));
