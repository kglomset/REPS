import client from './client';
import { ENDPOINTS } from '@/constants/api';
import { AuthResponse } from '@/types';

export const authApi = {
  register: (data: { email: string; password: string; name: string; fitnessLevel: string }) =>
    client.post<AuthResponse>(ENDPOINTS.auth.register, data).then((r) => r.data),

  login: (data: { email: string; password: string }) =>
    client.post<AuthResponse>(ENDPOINTS.auth.login, data).then((r) => r.data),
};
