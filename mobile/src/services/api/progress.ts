import client from './client';
import { ENDPOINTS } from '@/constants/api';
import { ExerciseProgressResponse, BodyWeightResponse } from '@/types';

export const progressApi = {
  getExerciseProgress: (exerciseId: number) =>
    client
      .get<ExerciseProgressResponse>(ENDPOINTS.progress.exercise(exerciseId))
      .then((r) => r.data),

  getBodyWeightHistory: () =>
    client.get<BodyWeightResponse[]>(ENDPOINTS.progress.bodyWeight).then((r) => r.data),

  logBodyWeight: (data: { weightKg: number; logDate: string }) =>
    client.post<BodyWeightResponse>(ENDPOINTS.progress.bodyWeight, data).then((r) => r.data),
};
