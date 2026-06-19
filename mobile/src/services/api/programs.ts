import client from './client';
import { ENDPOINTS } from '@/constants/api';
import { ProgramResponse, CreateProgramForm } from '@/types';

export const programsApi = {
  list: () =>
    client.get<ProgramResponse[]>(ENDPOINTS.programs.list).then((r) => r.data),

  getActive: () =>
    client.get<ProgramResponse | null>(ENDPOINTS.programs.active).then((r) => r.data),

  get: (id: number) =>
    client.get<ProgramResponse>(ENDPOINTS.programs.get(id)).then((r) => r.data),

  create: (data: CreateProgramForm) =>
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
        exercises: { exerciseId: number; sets: number; reps: number; trainingMethod: string }[];
      }[];
    },
  ) =>
    client.patch<ProgramResponse>(`/programs/${id}/structure`, data).then((r) => r.data),
};
