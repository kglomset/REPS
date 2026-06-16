import client from './client';
import { AuthResponse } from '@/types';

export const usersApi = {
  me: () =>
    client.get<AuthResponse>('/users/me').then((r) => r.data),

  updateMe: (data: { name?: string; avatarUrl?: string | null }) =>
    client.patch<AuthResponse>('/users/me', data).then((r) => r.data),
};
