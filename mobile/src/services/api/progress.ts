import client from './client';
import { ENDPOINTS } from '@/constants/api';
import {
  ExerciseProgressResponse, BodyWeightResponse, ProgramInsightResponse,
  ExerciseTrendResponse,
} from '@/types';

export const progressApi = {
  getExerciseProgress: (exerciseId: number) =>
    client
      .get<ExerciseProgressResponse>(ENDPOINTS.progress.exercise(exerciseId))
      .then((r) => r.data),

  getBodyWeightHistory: () =>
    client.get<BodyWeightResponse[]>(ENDPOINTS.progress.bodyWeight).then((r) => r.data),

  logBodyWeight: (data: { weightKg: number; logDate: string }) =>
    client.post<BodyWeightResponse>(ENDPOINTS.progress.bodyWeight, data).then((r) => r.data),

  getProgramInsight: () =>
    client.get<ProgramInsightResponse>(ENDPOINTS.progress.programInsight).then((r) => r.data),

  // Week-to-week trend for every exercise with completed history. Exercises
  // with only one session are omitted — nothing to compare yet.
  getTrends: () =>
    client.get<ExerciseTrendResponse[]>(ENDPOINTS.progress.trends).then((r) => r.data),
};
