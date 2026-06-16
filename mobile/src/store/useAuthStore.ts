import { create } from 'zustand';
import { storage } from '@/utils/storage';
import { authApi } from '@/services/api/auth';
import { AuthResponse, FitnessLevel } from '@/types';

export const TOKEN_KEY = 'reps_auth_token';

interface AuthState {
  user: AuthResponse | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (data: {
    email: string; password: string; name: string; fitnessLevel: FitnessLevel;
  }) => Promise<void>;
  logout: () => Promise<void>;
  hydrate: () => Promise<void>;
  /** Merge partial profile updates (name, avatarUrl) into stored user */
  updateUser: (patch: Partial<Pick<AuthResponse, 'name' | 'avatarUrl'>>) => Promise<void>;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isLoading: true,
  isAuthenticated: false,

  hydrate: async () => {
    try {
      const token = await storage.getItem(TOKEN_KEY);
      const userJson = await storage.getItem('reps_user');
      if (token && userJson) {
        set({ user: JSON.parse(userJson), isAuthenticated: true });
      }
    } catch (e) {
      // Storage unavailable — treat as logged out
    } finally {
      set({ isLoading: false });
    }
  },

  login: async (email, password) => {
    const data = await authApi.login({ email, password });
    await storage.setItem(TOKEN_KEY, data.token);
    await storage.setItem('reps_user', JSON.stringify(data));
    set({ user: data, isAuthenticated: true });
  },

  register: async (payload) => {
    const data = await authApi.register(payload);
    await storage.setItem(TOKEN_KEY, data.token);
    await storage.setItem('reps_user', JSON.stringify(data));
    set({ user: data, isAuthenticated: true });
  },

  logout: async () => {
    await storage.deleteItem(TOKEN_KEY);
    await storage.deleteItem('reps_user');
    set({ user: null, isAuthenticated: false });
  },

  updateUser: async (patch) => {
    const current = get().user;
    if (!current) return;
    const updated = { ...current, ...patch };
    await storage.setItem('reps_user', JSON.stringify(updated));
    set({ user: updated });
  },
}));
