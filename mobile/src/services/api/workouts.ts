import client from './client';
import { ENDPOINTS } from '@/constants/api';
import { WorkoutSessionResponse, ExerciseSetResponse } from '@/types';

export const workoutsApi = {
  startSession: (templateId: number) =>
    client
      .post<WorkoutSessionResponse>(ENDPOINTS.workouts.sessions, { templateId })
      .then((r) => r.data),

  getSession: (id: number) =>
    client.get<WorkoutSessionResponse>(ENDPOINTS.workouts.session(id)).then((r) => r.data),

  listSessions: () =>
    client.get<WorkoutSessionResponse[]>(ENDPOINTS.workouts.sessions).then((r) => r.data),

  completeSession: (id: number, notes?: string) =>
    client
      .post<WorkoutSessionResponse>(ENDPOINTS.workouts.complete(id), { notes })
      .then((r) => r.data),

  cancelSession: (id: number) =>
    client.delete(ENDPOINTS.workouts.session(id)).then((r) => r.data),

  logSet: (
    sessionId: number,
    exerciseId: number,
    data: { weightKg?: number; reps: number; setNumber?: number; rpe?: number; restSeconds?: number }
  ) =>
    client
      .post<ExerciseSetResponse>(ENDPOINTS.workouts.logSet(sessionId, exerciseId), data)
      .then((r) => r.data),

  updateTemplate: (templateId: number, data: { dayIndex?: number }) =>
    client
      .patch(`/workouts/templates/${templateId}`, data)
      .then((r) => r.data),

  updateTemplateExercise: (
    templateExerciseId: number,
    data: {
      sets?: number;
      restSeconds?: number;
      trainingMethod?: string;
      supersetGroupId?: string;
    }
  ) =>
    client
      .patch(`/workouts/templates/exercises/${templateExerciseId}`, data)
      .then((r) => r.data),
};
