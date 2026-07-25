import axios, { AxiosInstance, InternalAxiosRequestConfig } from 'axios';
import { Platform } from 'react-native';
import { API_BASE_URL } from '@/constants/api';

export const TOKEN_KEY = 'reps_auth_token';

const client: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 15_000,
});

// Attach JWT on every request — platform-safe token retrieval
client.interceptors.request.use(async (config: InternalAxiosRequestConfig) => {
  try {
    let token: string | null = null;
    if (Platform.OS === 'web') {
      token = localStorage.getItem(TOKEN_KEY);
    } else {
      const SecureStore = await import('expo-secure-store');
      token = await SecureStore.getItemAsync(TOKEN_KEY);
    }
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
  } catch {
    // No token available
  }
  return config;
});

// Auth-expiry handling + error normalisation.
// A 401 means the JWT is missing/expired. Previously the app kept showing the
// user as "logged in" (auth state is restored from the stored user object, not
// from token validity), so data queries silently failed until a manual
// logout/login minted a fresh token. Now any 401 signs the user out and sends
// them to the login screen automatically.
let handlingUnauthorized = false;

client.interceptors.response.use(
  (res) => res,
  async (err) => {
    const status = err?.response?.status;
    const url: string = err?.config?.url ?? '';
    // Don't treat a failed login/register attempt as a session expiry.
    const isAuthCall = url.includes('/auth/login') || url.includes('/auth/register');

    if (status === 401 && !isAuthCall && !handlingUnauthorized) {
      handlingUnauthorized = true;
      try {
        const { useAuthStore } = await import('@/store/useAuthStore');
        await useAuthStore.getState().logout();
        const { router } = await import('expo-router');
        router.replace('/(auth)/login');
      } catch {
        // best-effort; fall through to error normalisation
      } finally {
        // allow future 401s (e.g. next session) to be handled again
        setTimeout(() => { handlingUnauthorized = false; }, 1000);
      }
    }

    const msg =
      err?.response?.data?.message ??
      err?.response?.data?.errors ??
      err?.message ??
      'Unknown error';
    return Promise.reject(new Error(typeof msg === 'object' ? JSON.stringify(msg) : msg));
  }
);

export default client;
