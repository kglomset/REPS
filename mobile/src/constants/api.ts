export const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL ?? 'http://localhost:8080/api';

export const ENDPOINTS = {
  auth: {
    register: '/auth/register',
    login: '/auth/login',
  },
  programs: {
    list: '/programs',
    active: '/programs/active',
    create: '/programs',
    get: (id: number) => `/programs/${id}`,
  },
  exercises: {
    list: '/exercises',
    get: (id: number) => `/exercises/${id}`,
  },
  workouts: {
    sessions: '/workouts/sessions',
    session: (id: number) => `/workouts/sessions/${id}`,
    complete: (id: number) => `/workouts/sessions/${id}/complete`,
    logSet: (sessionId: number, exerciseId: number) =>
      `/workouts/sessions/${sessionId}/exercises/${exerciseId}/sets`,
  },
  progress: {
    exercise: (id: number) => `/progress/exercises/${id}`,
    bodyWeight: '/progress/body-weight',
  },
} as const;
