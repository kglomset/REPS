import client from './client';
import { ExerciseResponse } from '@/types';

export const exercisesApi = {
  list: () =>
    client.get<ExerciseResponse[]>('/exercises').then((r) => r.data),

  get: (id: number) =>
    client.get<ExerciseResponse>(`/exercises/${id}`).then((r) => r.data),
};
