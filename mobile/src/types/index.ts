// ─── Enums ────────────────────────────────────────────────────────────────────
export type FitnessLevel = 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
export type TrainingGoal = 'HYPERTROPHY' | 'STRENGTH';
export type TrainingMethod = 'STRAIGHT_SETS' | 'MYOREPS' | 'SUPERSET' | 'TRISET' | 'DROP_SET';
export type MuscleRole = 'PRIMARY' | 'SECONDARY';
export type CardioType = 'LISS' | 'HIIT' | 'CYCLING' | 'ROWING' | 'SWIMMING' | 'OTHER';

// ─── Auth ─────────────────────────────────────────────────────────────────────
export interface AuthResponse {
  token: string;
  userId: number;
  name: string;
  email: string;
  avatarUrl?: string | null;
  fitnessLevel: FitnessLevel;
}

// ─── Exercises ────────────────────────────────────────────────────────────────
export interface MuscleGroupResponse {
  id: number;
  name: string;
  slug: string;
}

export interface ExerciseMuscleResponse {
  muscleGroupId: number;
  muscleGroupName: string;
  role: MuscleRole;
}

export interface ExerciseResponse {
  id: number;
  name: string;
  description?: string;
  cues?: string;
  imageUrl?: string;
  muscles: ExerciseMuscleResponse[];
}

// ─── Programs ─────────────────────────────────────────────────────────────────
export interface WorkoutTemplateExerciseResponse {
  id: number;
  exercise: ExerciseResponse;
  exerciseOrder: number;
  sets: number;
  repsMin: number;
  repsMax: number;
  restSeconds: number;
  trainingMethod: TrainingMethod;
  supersetGroupId?: string;
}

export interface WorkoutTemplateResponse {
  id: number;
  name: string;
  dayIndex: number; // 0=Mon ... 6=Sun
  exercises: WorkoutTemplateExerciseResponse[];
}

export interface ProgramResponse {
  id: number;
  name: string;
  fitnessLevel: FitnessLevel;
  goal: TrainingGoal;
  strengthDaysPerWeek: number;
  cardioDaysPerWeek: number;
  cardioType?: CardioType;
  active: boolean;
  createdAt: string;
  workoutTemplates: WorkoutTemplateResponse[];
}

// ─── Workout Sessions ─────────────────────────────────────────────────────────
export interface ExerciseSetResponse {
  id: number;
  setNumber: number;
  weightKg?: number;
  reps: number;
  rpe?: number;
  restSeconds?: number;
  completedAt: string;
}

// ─── Progression suggestions ──────────────────────────────────────────────────
export type SuggestionType = 'INCREASE_WEIGHT' | 'DELOAD' | 'SWAP_EXERCISE';

export interface ProgressionSuggestion {
  type: SuggestionType;
  message: string;
  /** Target weight for INCREASE_WEIGHT / DELOAD; absent for bodyweight & swaps */
  suggestedWeightKg?: number;
  /** Swap candidates (same primary muscle group) for SWAP_EXERCISE */
  alternatives?: { id: number; name: string }[];
}

export interface ProgramInsightResponse {
  status: 'OK' | 'STALLING' | 'CHANGE_RECOMMENDED' | 'NO_ACTIVE_PROGRAM';
  message: string;
  weeksActive?: number;
  stalledExercises: { id: number; name: string }[];
}

export interface SessionExerciseResponse {
  id: number;
  exercise: ExerciseResponse;
  exerciseOrder: number;
  trainingMethod: TrainingMethod;
  supersetGroupId?: string;
  /** Template targets — used to pre-populate set rows */
  targetSets: number;
  repsMin?: number;
  repsMax?: number;
  restSeconds?: number;
  sets: ExerciseSetResponse[];
  previousSets: ExerciseSetResponse[]; // guidance from last workout
  /** Progression suggestion (null/absent = keep progressing reps). Active sessions only. */
  suggestion?: ProgressionSuggestion | null;
}

export interface WorkoutSessionResponse {
  id: number;
  templateId?: number;
  templateName?: string;
  startedAt: string;
  completedAt?: string;
  notes?: string;
  exercises: SessionExerciseResponse[];
}

// ─── Progress ─────────────────────────────────────────────────────────────────
export interface ProgressPoint {
  date: string;
  setNumber: number;
  weightKg?: number;
  reps: number;
  estimated1RM?: number;
  trainingMethod?: TrainingMethod;
}

export interface ExerciseProgressResponse {
  exerciseId: number;
  exerciseName: string;
  series: ProgressPoint[];
}

export interface BodyWeightResponse {
  id: number;
  weightKg: number;
  logDate: string;
}

// ─── Forms ────────────────────────────────────────────────────────────────────
export interface LogSetForm {
  weightKg?: string;
  reps: string;
  rpe?: string;
  restSeconds?: number;
}

export interface CreateProgramForm {
  name: string;
  fitnessLevel: FitnessLevel;
  goal: TrainingGoal;
  strengthDaysPerWeek: number;
  cardioDaysPerWeek: number;
  cardioType?: CardioType;
}
