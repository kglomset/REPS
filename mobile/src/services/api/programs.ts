import client from './client';
import { ENDPOINTS } from '@/constants/api';
import {
  ProgramResponse, CreateProgramForm,
  SplitOptionResponse, ProgramDraftRequest, ProgramDraftResponse,
} from '@/types';

export interface BuilderExercisePayload {
  exerciseId: number;
  sets: number;
  /** Legacy single rep target; send repsMin/repsMax instead where known. */
  reps: number;
  /** Per-exercise prescription; the backend falls back to the goal range. */
  repsMin?: number;
  repsMax?: number;
  restSeconds?: number;
  trainingMethod: string;
  supersetGroupId?: string | null;
}

export interface CreateProgramPayload extends CreateProgramForm {
  /** Weekly set target per muscle group the program was built around. */
  weeklySetsPerMuscle?: number;
  /** Optional custom-built structure (Build from Scratch / guided builder). */
  days?: {
    name?: string;
    dayIndex?: number;
    exercises: BuilderExercisePayload[];
  }[];
}

export const programsApi = {
  list: () =>
    client.get<ProgramResponse[]>(ENDPOINTS.programs.list).then((r) => r.data),

  // ── Guided builder ────────────────────────────────────────────────────

  /** Split options for a frequency, best first (2+ sessions per muscle lead). */
  getSplits: (daysPerWeek: number) =>
    client
      .get<SplitOptionResponse[]>(ENDPOINTS.programBuilder.splits(daysPerWeek))
      .then((r) => r.data),

  /** Propose a program. Nothing is saved — the user edits this, then creates. */
  draft: (data: ProgramDraftRequest) =>
    client
      .post<ProgramDraftResponse>(ENDPOINTS.programBuilder.draft, data)
      .then((r) => r.data),

  getActive: () =>
    client.get<ProgramResponse | null>(ENDPOINTS.programs.active).then((r) => r.data),

  get: (id: number) =>
    client.get<ProgramResponse>(ENDPOINTS.programs.get(id)).then((r) => r.data),

  create: (data: CreateProgramPayload) =>
    client.post<ProgramResponse>(ENDPOINTS.programs.create, data).then((r) => r.data),

  activate: (id: number) =>
    client.post<ProgramResponse>(`/programs/${id}/activate`, {}).then((r) => r.data),

  deactivate: (id: number) =>
    client.post(`/programs/${id}/deactivate`, {}).then((r) => r.data),

  update: (id: number, data: { name?: string }) =>
    client.patch(`/programs/${id}`, data).then((r) => r.data),

  updateStructure: (
    id: number,
    data: {
      name?: string;
      days: {
        templateId?: number;
        name?: string;
        dayIndex?: number;
        exercises: {
          exerciseId: number;
          sets: number;
          reps: number;
          trainingMethod: string;
          supersetGroupId?: string | null;
        }[];
      }[];
    },
  ) =>
    client.patch<ProgramResponse>(`/programs/${id}/structure`, data).then((r) => r.data),
};
