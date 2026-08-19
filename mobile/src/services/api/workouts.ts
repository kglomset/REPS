import client from './client';
import { ENDPOINTS } from '@/constants/api';
import { WorkoutSessionResponse, ExerciseSetResponse, WorkoutTemplateResponse } from '@/types';
import { BuilderExercisePayload } from './programs';

export const workoutsApi = {
  // `date` (yyyy-MM-dd) backdates the session for retrospective logging.
  startSession: (templateId: number, date?: string) =>
    client
      .post<WorkoutSessionResponse>(ENDPOINTS.workouts.sessions, {
        templateId,
        ...(date ? { date } : {}),
      })
      .then((r) => r.data),

  swapSessionExercise: (sessionId: number, sessionExerciseId: number, exerciseId: number) =>
    client
      .patch<WorkoutSessionResponse>(
        ENDPOINTS.workouts.swap(sessionId, sessionExerciseId),
        { exerciseId }
      )
      .then((r) => r.data),

  // Add an exercise to a live session (this session only — template untouched).
  addSessionExercise: (sessionId: number, exerciseId: number, trainingMethod?: string) =>
    client
      .post<WorkoutSessionResponse>(ENDPOINTS.workouts.sessionExercises(sessionId), {
        exerciseId,
        ...(trainingMethod ? { trainingMethod } : {}),
      })
      .then((r) => r.data),

  // Remove an exercise from a live session (this session only).
  removeSessionExercise: (sessionId: number, sessionExerciseId: number) =>
    client
      .delete<WorkoutSessionResponse>(
        ENDPOINTS.workouts.sessionExercise(sessionId, sessionExerciseId)
      )
      .then((r) => r.data),

  // ── Standalone workouts (not tied to a program or calendar) ──────────────
  listStandalone: () =>
    client
      .get<WorkoutTemplateResponse[]>(ENDPOINTS.workouts.standalone)
      .then((r) => r.data),

  createStandalone: (data: { name: string; exercises: BuilderExercisePayload[] }) =>
    client
      .post<WorkoutTemplateResponse>(ENDPOINTS.workouts.standalone, data)
      .then((r) => r.data),

  deleteStandalone: (id: number) =>
    client.delete(ENDPOINTS.workouts.standaloneItem(id)).then((r) => r.data),

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

  updateTemplate: (templateId: number, data: { dayIndex?: number; name?: string }) =>
    client
      .patch(`/workouts/templates/${templateId}`, data)
      .then((r) => r.data),

  reorderTemplateExercises: (templateId: number, exerciseIds: number[]) =>
    client
      .patch(`/workouts/templates/${templateId}/reorder`, { exerciseIds })
      .then((r) => r.data),

  reorderSessionExercises: (sessionId: number, exerciseIds: number[]) =>
    client
      .patch(`/workouts/sessions/${sessionId}/reorder`, { exerciseIds })
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
