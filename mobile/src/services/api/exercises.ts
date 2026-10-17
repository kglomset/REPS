import client from './client';
import { ENDPOINTS } from '@/constants/api';
import { EquipmentResponse, ExerciseResponse, MovementResponse, ResolveExerciseRequest } from '@/types';

export const exercisesApi = {
  list: () =>
    client.get<ExerciseResponse[]>('/exercises').then((r) => r.data),

  get: (id: number) =>
    client.get<ExerciseResponse>(`/exercises/${id}`).then((r) => r.data),

  /**
   * Step two/three of the exercise picker: movement + equipment + optional
   * variation, resolved to an actual exercise id (created on the fly if
   * this exact combination doesn't exist yet).
   */
  resolve: (req: ResolveExerciseRequest) =>
    client.post<ExerciseResponse>(ENDPOINTS.exercises.resolve, req).then((r) => r.data),
};

export const movementsApi = {
  list: () =>
    client.get<MovementResponse[]>(ENDPOINTS.movements.list).then((r) => r.data),
};

export type { EquipmentResponse, MovementResponse };
