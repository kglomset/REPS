// ─── Enums ────────────────────────────────────────────────────────────────────
export type FitnessLevel = 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
export type TrainingGoal = 'HYPERTROPHY' | 'STRENGTH';
export type TrainingMethod = 'STRAIGHT_SETS' | 'MYOREPS' | 'SUPERSET' | 'TRISET' | 'DROP_SET';
export type MuscleRole = 'PRIMARY' | 'SECONDARY';
// Multi-joint vs single-joint. Curated per exercise server-side — it cannot be
// inferred from the muscle mapping (Bench Press has one primary muscle, same
// as Lateral Raise). Drives rep ranges and myo-rep eligibility.
export type MovementPattern = 'COMPOUND' | 'ISOLATION';
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
  movementPattern?: MovementPattern;
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
  /** Weekly set target per muscle group this program was built around. */
  weeklySetsPerMuscle?: number;
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

// ─── Guided program builder ───────────────────────────────────────────────────

export interface SplitOptionResponse {
  id: string;
  /** e.g. "Upper / Lower ×2" */
  name: string;
  /** Day labels in order, e.g. [Upper, Lower, Upper, Lower]. */
  dayNames: string[];
  /** How often the least-trained muscle is hit per week; 2+ is what to aim for. */
  minWeeklyFrequency: number;
}

export interface DraftExercise {
  exerciseId: number;
  name: string;
  movementPattern: MovementPattern;
  sets: number;
  repsMin: number;
  repsMax: number;
  restSeconds: number;
  trainingMethod: TrainingMethod;
}

export interface DraftDay {
  name: string;
  dayIndex: number;
  dayType: string;
  estimatedMinutes: number;
  exercises: DraftExercise[];
}

export interface DraftMuscleVolume {
  muscleGroupId: number;
  name: string;
  slug: string;
  targetSets: number;
  /** Myo-reps count as 3 sets, secondary muscles as half a set. */
  plannedSets: number;
}

export interface ProgramDraftResponse {
  splitId: string;
  splitName: string;
  days: DraftDay[];
  weeklyVolume: DraftMuscleVolume[];
  longestSessionMinutes: number;
}

export interface ProgramDraftRequest {
  goal: TrainingGoal;
  weeklySetsPerMuscle: number;
  daysPerWeek: number;
  splitId?: string;
  recommendMyoreps: boolean;
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

// ─── Week-to-week trend ───────────────────────────────────────────────────────
// How an exercise's last completed session compares with the one before it.
// Same working weight → reps decide; weight changed → estimated 1RM decides.
export type TrendDirection = 'UP' | 'FLAT' | 'DOWN';

export interface TrendSetDelta {
  setNumber: number;
  previousReps: number;
  reps: number;
  repsDelta: number;
}

export interface ProgressionTrend {
  direction: TrendDirection;
  /** Short title: 'Progressing' | 'Maintaining' | 'Regressing' */
  headline: string;
  /** Plain-language explanation, e.g. "You increased reps on set 1 by 2…" */
  message: string;
  weightDeltaKg?: number;
  totalRepsDelta?: number;
  previousDate?: string;
  latestDate?: string;
  /** Only the set numbers logged in both sessions. */
  sets: TrendSetDelta[];
}

export interface ExerciseTrendResponse {
  exerciseId: number;
  exerciseName: string;
  trend: ProgressionTrend;
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
  /**
   * Week-to-week trend arrow. On an active session it compares the last two
   * completed sessions; on a finished one, the session you just logged against
   * the one before it. Absent until there are two sessions to compare.
   */
  trend?: ProgressionTrend | null;
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
