# Exercise / equipment model redesign

## Why

Exercises used to carry their equipment baked into the name: "Shoulder Press
Smith", "Shoulder Press Barbell", "Shoulder Press Dumbbell" were three
unrelated rows, each with its own copy of the agonist/synergist muscle
mapping. Adding "Shoulder Press Cable" meant re-entering that mapping a
fourth time. The program builder's `movementFamily()` heuristic existed
purely to paper over this — stripping equipment words back out of names by
regex so the allocator wouldn't treat "Incline Chest Press Dumbbell" and
"...Barbell" as two different exercises.

## The split

Three concerns, three tables:

- **`movements`** — the exercise identity ("Squat", "Bench Press"). Owns the
  muscle mapping (`exercise_muscles`, repointed from `exercise_id` to
  `movement_id`) and the compound/isolation classification, since neither
  changes with equipment.
- **`equipment`** — "Barbell", "Dumbbell", "Smith Machine", "Machine",
  "Cable", "Keiser", "Bodyweight", "Kettlebell", "EZ Bar", "TRX", "Weighted".
  11 rows, flat.
- **`movement_equipment`** — which equipment the picker *suggests* for a
  movement (join table). Not a hard constraint: `POST /exercises/resolve`
  accepts any equipment id regardless of whether it's listed here.
- **`exercises`** — becomes the **variant**: `(movement_id, equipment_id,
  variation)`, plus a cached `name` ("Barbell Squat", "Smith Machine Lateral
  Raise Unilateral (Cuffed)") computed once and stored, so the rest of the
  codebase that reads `exercise.getName()` didn't need to change.
  `equipment_id` is nullable (a handful of movements have no equipment at
  all, e.g. Ab Wheel Roll Out). `variation` is free text, not a fixed enum —
  "Seated", "Cuffed", "45 Degree" are seed suggestions, not an exhaustive
  list.

This is also what `workout_template_exercises` / `session_exercises`
reference — every one of those FKs carries real logged history, so **every
live `exercises` row is retrofitted in place, same id**, rather than
replaced. Nothing needed remapping.

`Exercise` (the entity) delegates `getMuscles()`, `getMovementPattern()`,
`getDescription()`, `getCues()`, `getImageUrl()` to its `Movement` — none of
those changed with equipment, so every existing call site
(`ProgramBuilderService`, `ProgressionService`, `ProgramService.exerciseToResponse`)
kept working unmodified.

`movementFamily()` in `ProgramBuilderService` — previously a qualifier-
stripping regex over the exercise name — is now just `movement.getId()`.
Simpler and exact, since equipment genuinely cannot leak into the comparison
any more.

## Migration (V15) and the admin user's history

`backend/src/main/resources/db/migration/V15__exercise_equipment_model.sql`:

1. Creates `equipment`, `movements`, `movement_equipment`.
2. Seeds all 11 equipment rows and all 66 movements (name + compound/isolation,
   derived from V14's curated classification plus judgment calls for a few
   movements with no precedent in the old 106-exercise library — Goblet
   Squat, Hack Squat, Split Squat, Step Down, Reverse Nordics).
3. Clears `exercise_muscles` (safe — catalogue metadata duplicated once per
   equipment variant, not user history) and reinserts it once per movement
   from the agonist/synergist columns of the supplied spreadsheet, then
   repoints the column from `exercise_id` to `movement_id`.
4. Seeds `movement_equipment` from the spreadsheet's equipment lists, unioned
   with whatever equipment the live 106 exercises actually use (one case —
   "Upright Row Smith" — needs equipment the sheet didn't list for Upright
   Row; the sheet is extended rather than treated as authoritative over real
   history).
5. Adds `movement_id` / `equipment_id` / `variation` to `exercises`, then runs
   106 `UPDATE ... WHERE name = '<old name>'` statements — one per live
   exercise, **same row, same id** — setting its movement, equipment,
   variation and recomputed display name. A `DO` block asserts zero rows are
   left with a null `movement_id` before the column is made `NOT NULL`
   (would mean a historical FK pointing at an exercise with no identity).
6. Drops `movement_pattern`, `description`, `cues`, `image_url` from
   `exercises` (moved to `movements`; no live row had ever populated the
   latter three).

Two of the 106 live names are deliberately **not** auto-matched from their
own equipment word, because that isn't the equipment actually trained on:

| Live name | → | Movement | Equipment |
|---|---|---|---|
| Machine Leg Press | | Leg Press | **Keiser** |
| Stiff Legged Deadlift | | Stiff Legged Deadlift | **Keiser** |

Every one of the 106 `(old name → movement, equipment, variation)` mappings,
plus the full equipment/movement/muscle extraction from the spreadsheet, was
generated and validated offline before being written into the migration:
every old name resolves to exactly one movement, every equipment token
resolves to one of the 11 canonical rows, and no two old names resolve to the
same `(movement, equipment, variation)` triple (a collision there would mean
two historical rows wanting the same identity with no way to tell them
apart). The generator and its assertions are not checked into the repo (a
one-time migration script), but the migration file itself carries the full
explanation in its header comment.

## API

- `GET /movements` — step one of the picker. Each entry carries its muscle
  mapping and its suggested equipment list (`equipmentOptions`).
- `POST /exercises/resolve` — step two/three: `{movementId, equipmentId?,
  variation?}` → an `ExerciseResponse`. Finds the matching `exercises` row or
  creates it on the fly (globally, not scoped to the requesting user — a
  standard equipment combination picked for the first time becomes available
  to everyone from then on, same as any other seeded variant). The full
  `movement × equipment × variation` space is never pre-seeded; most
  combinations are created the first time anyone picks them.
- `GET /exercises`, `GET /exercises/{id}` — unchanged shape, with
  `movementId` / `movementName` / `equipmentId` / `equipmentName` /
  `variation` added to `ExerciseResponse`.
- Everything that already worked by exercise id — creating/editing a
  program's structure, adding an exercise to an active workout, swapping one
  mid-workout — needed **no backend change**: those endpoints only ever
  took an `exerciseId`, and `exercises.id` never moved.

## Mobile picker flow

One shared component (`mobile/src/components/ExercisePicker.tsx`) replaces
the four near-identical "flat list, search by name, tap to add" pickers that
existed before:

- `program/guided.tsx` → `AddExerciseModal`
- `program/setup.tsx` → `ExerciseRowsEditor`'s inline search list (DIY
  builder + standalone builder)
- `workout/start.tsx` → `AddExerciseModal` and `SwapExerciseModal`

The picker searches movements, and picking one expands it inline to show its
suggested equipment as chips (pre-selecting the only option when there is
exactly one) plus an optional free-text variation field, then resolves
through `POST /exercises/resolve` and hands the caller back the same
`ExerciseResponse` shape every one of these screens already consumed — so
nothing downstream of "an exercise got added" needed to change, only how the
user gets there.

Because the picker now operates on movements rather than variants, "already
in this workout" is no longer a reason to hide a movement from the list —
the same movement with different equipment (pre-fatigue barbell bench, then
machine bench) is a legitimate thing to add twice. Duplicate *exact* variants
are still caught after resolving, not before.
