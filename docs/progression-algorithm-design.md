# Progression Algorithm — Design

**Status:** Implemented (backend + mobile) · July 2026
**Approach:** Double progression, computed in a backend `ProgressionService`, surfaced as a badge on exercise tiles in the active session with one-tap apply.

---

## 1. Goal

For each exercise the user performs, decide — from logged sets/reps/weight history — whether to suggest one of:

| Suggestion | Meaning |
|---|---|
| `INCREASE_WEIGHT` | Rep range topped out → add load |
| `SWAP_EXERCISE` | Plateaued → rotate to a variation |
| `DELOAD` | Performance regressing → reduce load |
| *(program-level)* `CHANGE_PROGRAM` | Most lifts stalled → time for a new block |

No suggestion is the default. Suggestions are advisory — nothing changes until the user applies them.

**One progression variable at a time, reps before weight.** The default path is always to add reps within the `repsMin`–`repsMax` range — that needs no badge, it's what the user is already doing. Only when reps are maxed out does the algorithm suggest touching weight. Set count is a program-design decision, not a progression variable: the algorithm never suggests changing sets.

## 2. Data model fit (what we already have)

- `ExerciseSet`: `weightKg`, `reps`, `rpe` (optional), `setNumber`, per completed session (`WorkoutSession.completedAt IS NOT NULL`).
- `WorkoutTemplateExercise`: `sets` (target), `repsMin`, `repsMax` → the double-progression rep range. Already mirrored into `SessionExerciseResponse` as `targetSets`/`repsMin`/`repsMax`.
- `ExerciseSetRepository.findHistoryForUserAndExercise(userId, exerciseId)` — exactly the history query needed.
- History is **per user + exercise**, not per template, so progression carries across programs and standalone sessions. This is the right key: the barbell squat is the same lift wherever it appears. (Note: the existing `previousSets` guidance is per-template via `findCompletedByUserAndTemplate`; the algorithm deliberately uses the wider per-exercise history instead.)
- `ExerciseMuscle` (role = PRIMARY) → used to find swap candidates for the same muscle group.

**No schema change is required for the MVP.** (Optional later: a `progression_events` table to record accepted/dismissed suggestions — see §7.)

## 3. Core definitions

- **Session snapshot** for an exercise = all logged sets of that exercise in one completed session. Sessions with zero sets for the exercise are ignored.
- **Working weight** of a snapshot = the modal (most common) `weightKg` across its sets — robust against a lighter first set.
- **Total reps** = sum of reps at the working weight.
- **e1RM** = Epley: `weight × (1 + reps/30)`, best set of the snapshot. Used only as a tiebreak/trend signal, never shown as the headline.
- **History window** = last **6** snapshots of the exercise (configurable).
- Rep range: `repsMin`/`repsMax` from the template exercise. Fallback when null (standalone/free exercises): **6–10**.

## 4. Rules (evaluated in priority order — first match wins)

Requires ≥ 1 prior snapshot; rules 2–3 require ≥ 3. At most one suggestion per exercise — first match wins, and each suggestion changes exactly one variable (weight *or* exercise), never several at once.

### R1 — INCREASE_WEIGHT
In the **most recent** snapshot, the **best working set** reached `repsMax` — in practice the first, freshest set. At least `targetSets` sets must have been logged (a half-logged session is not evidence), and if `rpe` was logged, avg RPE ≤ 9.

> **Revised Aug 2026.** This originally required *every* working set to top out. In practice that stalls the load for weeks while the trailing sets catch up — the exact "reps keep going up, weight never does" pattern the algorithm is meant to break. Topping the range on the first set is the signal; the later sets follow at the new load.

Suggested increment, rounded to 2.5 kg:
- lower-body compound (primary muscle in quads/hamstrings/glutes): **+5 kg**
- everything else: **+2.5 kg**
- if current weight < 20 kg (dumbbell/isolation territory): **+2.5 kg → but never more than +10 %**

Suggestion payload includes `suggestedWeightKg = workingWeight + increment`.

### R2 — DELOAD
Over the last 3 snapshots at the **same working weight**, compared **set number to set number**:

- only set numbers logged in *all three* sessions are considered (adding or dropping a set must not fake a decline);
- **no individual set may have improved** anywhere in the window — one climbing set vetoes the deload, because that is a shifting effort distribution, not a regression;
- the total over those matched sets must fall **every** session.

Suggest reducing to **90 % of working weight** (rounded to 2.5 kg) and rebuilding.

> **Revised Aug 2026.** Was session rep totals. Reps taper *within* a session (set 1 = 8, set 2 = 7 near failure) so only the same set number across sessions is comparable.

### R3 — SWAP_EXERCISE (plateau)
Last **4** snapshots: working weight unchanged **and** total reps within ±1 of flat **and** e1RM trend slope ≤ 0 — i.e., stuck, but not regressing (that's R2). Suggest rotating to a variation: top 3 exercises sharing the same PRIMARY muscle group that the user hasn't done in the window.

### R4 — CHANGE_PROGRAM (program-level, not per-tile)
Evaluated for the active program: if ≥ 60 % of its distinct exercises are currently in R2/R3 state, **or** the program has been active ≥ 10 weeks with ≥ 2 sessions/week logged, surface a program-level insight ("Most lifts have stalled — consider a new block") on the program screen, not on tiles.

### Hysteresis / anti-nagging
- A suggestion type is suppressed for an exercise if the same type fired in the previous snapshot and the underlying condition data hasn't gained a new snapshot (i.e., recompute only adds signal when a new session completes — automatic since input is completed sessions).
- After the user changes weight (accepting R1 or not), R1 can't re-fire until `repsMax` is hit again at the *new* weight — this falls out of the rule naturally. In between, the user progresses reps within the range with no algorithm involvement.
- Dismissals are client-side, session-scoped state keyed by `exerciseId + type + message` (new data changes the message, resurfacing the badge); no backend state in MVP.

## 4b. Week-to-week trend (descriptive, not a suggestion)

Separate from R1–R4: an arrow on every exercise tile saying how the **last two completed sessions** compare. Unlike a suggestion it never asks for a change — it exists so that progress that *is* happening (reps climbing at a fixed load, week after week) is visible instead of silent.

**Direction**

| Working weight | Decided by |
|---|---|
| unchanged | net rep change over the set numbers logged in both sessions |
| **up** | always `UP` |
| down | best estimated 1RM, with a **1 % dead-band** |

> **Revised Aug 2026 — a heavier bar is never a regression.** Weight up used to
> be judged on estimated 1RM, so a jump that cost more reps than the load made
> back scored as `DOWN`. That is backwards: double progression *works* by adding
> weight and rebuilding reps, and flagging the drop in red told the user off for
> doing exactly the right thing. Any increase in working weight now reads as
> progress, and the message names the rep ceiling to build back towards —
> "You added 2.5 kg and reps came down on set 1 by 3 — exactly what should
> happen at a heavier load. Build the reps back up to 10, then add weight
> again." A load that was jumped too far still surfaces separately, as R2's
> deload once the reps keep sliding at the new weight.

`UP` = Progressing, `FLAT` = Maintaining, `DOWN` = Regressing. Null until the exercise has two completed sessions, or if the two sessions share no set numbers.

**Payload** — `direction`, `headline`, a written `message`, `weightDeltaKg`, `totalRepsDelta`, both session dates, and a per-set breakdown (`setNumber`, `previousReps`, `reps`, `repsDelta`) restricted to the matched sets.

**Message** is generated backend-side so every surface says the same thing, e.g.:

> "You increased reps on set 1 by 2, and set 2 by 1 at 60 kg. Keep this up."
> "You added 2.5 kg, so reps eased off on set 1 by 1, and set 2 by 1. That is the trade, and you came out ahead."
> "Same reps as last time at 60 kg — matched set for set. One extra rep anywhere moves you forward."

**When it runs** — on every session load, so **starting a workout recomputes it**. On an *active* session it compares the last two completed sessions (how last week went vs the week before); on a *completed* one it compares the session just logged with the one before it, which is what the completion overlay shows. The Progress tab reads `GET /progress/trends`, one query for every exercise.

**Surfaces** — active-workout exercise tiles (including superset members), Progress tab exercise list, and the workout summary overlay. Tapping the arrow opens a sheet with the message and the set-by-set numbers.

## 5. API design

### Per-exercise suggestions ride on the session

Add to `SessionExerciseResponse`:

```java
private ProgressionSuggestionResponse suggestion;   // nullable

@Data @Builder
public class ProgressionSuggestionResponse {
    private SuggestionType type;        // INCREASE_WEIGHT | DELOAD | SWAP_EXERCISE
    private String message;             // human-readable reason ("Hit 3×10 at 60 kg last time")
    private BigDecimal suggestedWeightKg;   // for INCREASE_WEIGHT / DELOAD
    private List<ExerciseSummary> alternatives; // for SWAP_EXERCISE (id, name)
}
```

Computed in `WorkoutService.toSessionExResponse` (the mapper already resolves `targetSets`/`repsMin`/`repsMax` from the template and builds `previousSets` there — the suggestion slots in alongside) via the new `ProgressionService.suggestFor(userId, exerciseId, repsMin, repsMax, targetSets)`. One history query per exercise (reuses `findHistoryForUserAndExercise`); a session has ~5–8 exercises, so no performance concern. Can be batched later if needed. Skip computation when the session is already completed (badges are for active sessions).

### Program-level

`GET /progress/program-insight` → `{ status: OK | STALLING | CHANGE_RECOMMENDED, stalledExercises: [...], weeksActive, message }`, rendered on the workouts tab under the active program (next to the existing insights).

### Applying a suggestion

- **INCREASE_WEIGHT / DELOAD**: no backend write — the app pre-fills the set rows' weight input with `suggestedWeightKg`.
- **SWAP_EXERCISE**: persist via existing `PATCH /programs/{id}/structure` (`updateProgramStructure` supports swap/add/remove) — with a confirm dialog, since it's permanent. *Gap:* that endpoint is program-scoped; standalone templates have no swap endpoint yet, so for standalone sessions the swap suggestion is informational-only in MVP (or we add a small standalone-template PATCH later).

## 6. UI

**Tile badge** (in `app/workout/start.tsx` exercise card header):

- Small circular indicator on the exercise tile's right edge:
  - ▲ green — increase weight
  - ▼ orange — deload
  - ⇄ amber — plateau / swap suggestion
- Tap → bottom sheet: title, `message` (the "why"), and an **Apply** button ("Set 62.5 kg for all sets" / list of swap alternatives). Secondary "Dismiss" hides it for this exercise until new data arrives.
- Applying INCREASE_WEIGHT overwrites the placeholder weights (which currently come from `previousSets`) with the suggested weight.

Badges only render during an **active session** (that's when the decision is actionable). The progress tab can later reuse the same data for an overview.

## 7. Explicit non-goals / later

- **Warm-up sets** aren't distinguished in the data; the modal-weight heuristic handles most cases. A `isWarmup` flag on `ExerciseSet` is a possible V2.
- **`progression_events` table** (accepted/dismissed audit) — only needed if we want cross-device dismissal sync or to tune thresholds from real behavior.
- **RPE-driven autoregulation** — RPE is optional input today; it only *gates* suggestions (R1), never drives them.
- **Body-weight exercises** (`weightKg` 0/null): R1 suggests "+1–2 reps beyond range or add weight" as text only, no `suggestedWeightKg`.

## 8. Thresholds (all in one config class, `ProgressionConfig`)

| Parameter | Default |
|---|---|
| History window | 6 snapshots |
| Min snapshots for R2–R3 | 3 |
| Plateau window (R3) | 4 snapshots |
| Deload target | 90 % of working weight |
| Upper/lower increment | 2.5 / 5 kg |
| Rounding | nearest 2.5 kg |
| RPE gate (R1) | ≤ 9 |
| Program stall ratio (R4) | 60 % |
| Program age trigger (R4) | 10 weeks |

## 9. Implementation plan

**Backend**
1. `enums/SuggestionType.java`
2. `service/ProgressionService.java` — pure logic over `List<ExerciseSet>` history (unit-test friendly: snapshot grouping, rules R1–R3)
3. `dto/response/ProgressionSuggestionResponse.java`; add `suggestion` to `SessionExerciseResponse`; wire into `WorkoutService.toResponse` path
4. `ProgressController`: `GET /progress/program-insight` (R4)
5. Unit tests for rule engine (table-driven: history → expected suggestion)

**Mobile**
6. Types in `api` layer; badge component + bottom sheet in `app/workout/start.tsx`
7. Apply handlers: pre-fill weights / add set row / swap via template update endpoint
8. Dismissal store (persisted Zustand)

Rough order: 1–3 and 5 first (pure backend, testable), then 6–7, then 4 + program insight UI.

## 10. Implementation status (July 2026)

Implemented: `SuggestionType`, `ProgressionSuggestionResponse`, `ProgramInsightResponse`,
`ProgressionService` (rule engine + program insight), wiring in `WorkoutService.toSessionExResponse`
(active sessions only), `GET /progress/program-insight`, unit tests in `ProgressionServiceTest`
(pure rule-engine tests, no Spring context). Mobile: types, `progressApi.getProgramInsight`,
`SuggestionBadge` + `SuggestionSheet` in `app/workout/start.tsx` (straight + superset blocks),
one-tap apply pre-fills remaining rows, insight banner in the workouts tab's Program Insights card.
Swap suggestions list alternatives informationally; the swap itself happens in the program editor.
Run backend tests with `./mvnw test` (needs Java 21).
