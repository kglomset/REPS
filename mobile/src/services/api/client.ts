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

// Normalise errors
client.interceptors.response.use(
  (res) => res,
  (err) => {
    const msg =
      err?.response?.data?.message ??
      err?.response?.data?.errors ??
      err?.message ??
      'Unknown error';
    return Promise.reject(new Error(typeof msg === 'object' ? JSON.stringify(msg) : msg));
  }
);

export default client;
