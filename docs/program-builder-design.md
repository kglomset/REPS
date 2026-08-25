# Program Builder — Design

Rework of the first-run and "new program" flows (August 2026). Replaces the old
5-step `SuggestedWizard` (level → goal → days → cardio → confirm), which asked for
a fitness level and then let the backend pick a split and hand every exercise the
same 3×8–12.

## 1. Goal

Give the lifter real control over the three parameters that actually shape a
program — **goal**, **volume**, and **frequency** — and explain each one on the
screen where it is chosen, rather than burying them behind a "beginner /
intermediate / advanced" label.

The user picks one of two entry points:

- **Build it myself** — the existing DIY builder, unchanged in shape.
- **Guide me through it** — the flow below.

## 2. Steps

```
Goal → Volume → Frequency → Split → Myo-reps → Exercises → Name & create
```

Every step is a page with a short explainer above the control. Goal comes first
because it changes what the later screens should recommend.

### 2.1 Goal

| Option | Enum | What it does |
|---|---|---|
| **Stronger** | `STRENGTH` | Higher total volume, more sets and fewer reps, further from failure, compound movements prioritised. Longer sessions. |
| **Bigger & stronger** | `HYPERTROPHY` | Mixes sets, reps and proximity to failure. Reps land in the 4–12 band, taken closer to failure. |

Proximity to failure is explained on this page and repeated on the exercise
review, but it is **not stored** — there is no `target_rir` column. It is
coaching guidance, not prescription.

### 2.2 Volume — sets per muscle group per week

A slider, 5–30, is the single volume control. Bands shown live under the handle:

| Sets / muscle / week | Band |
|---|---|
| 5–10 | Beginner |
| 10–20 | Intermediate |
| 15–25+ | Advanced |

The bands **overlap deliberately** and the page says so: they are not hard
intervals tied to training status. An advanced lifter can make good progress at
the low end, and a higher number mostly means longer sessions or more of them —
which is exactly the trade the next two steps make concrete.

Stored on the program as `weekly_sets_per_muscle`, and mapped to the existing
`FitnessLevel` enum for backwards compatibility (`<10` beginner, `10–15`
intermediate, `≥16` advanced).

### 2.3 Frequency — training days per week

1–6. (The old `@Min(2)` on `strengthDaysPerWeek` is relaxed to `@Min(1)` so a
one-day full-body program is legal.)

### 2.4 Split

Options depend on the frequency chosen. Splits that hit each muscle **twice or
more per week** are listed first and carry a "2× / week" badge; the rest follow.

| Days | Splits (in listed order) |
|---|---|
| 1 | Full body |
| 2 | Full body ×2 · Upper / Lower |
| 3 | Full body ×3 · Upper / Lower / Full · Push / Pull / Legs · Chest+Back / Shoulders+Arms / Legs |
| 4 | Full body ×4 · Push / Pull / Legs / Full · Upper / Lower ×2 |
| 5 | Push / Pull / Legs / Upper / Lower · Chest / Back / Legs / Arms / Shoulders |
| 6 | Upper / Lower / Full ×2 · Push / Pull / Legs ×2 · Chest+Back / Shoulders+Arms / Legs ×2 |

Ranking is computed, not hard-coded: each split's **minimum per-muscle weekly
frequency** is derived from its day types, and options with `≥ 2` sort ahead of
the rest (stable, so the listed order above survives).

Day types and the muscle groups they own:

| Day type | Muscle groups |
|---|---|
| `FULL_BODY` | all 13 |
| `UPPER` | chest, lats, upper-back, front/side/rear delts, biceps, triceps |
| `LOWER` | quads, hamstrings, glutes, calves, abs |
| `PUSH` | chest, front delts, side delts, triceps |
| `PULL` | lats, upper-back, rear delts, biceps |
| `LEGS` | quads, hamstrings, glutes, calves, abs |
| `CHEST_BACK` | chest, lats, upper-back |
| `SHOULDERS_ARMS` | front/side/rear delts, biceps, triceps |
| `CHEST` / `BACK` / `ARMS` / `SHOULDERS` | (bro split) chest · lats+upper-back · biceps+triceps · all delts |

Traps, lower back, obliques and forearms are not volume targets — they accrue
work incidentally as secondary muscles.

### 2.5 Myo-reps

A single checkbox: *"Suggest myo-reps where they save time"*. The page explains
what a myo-rep set is and what it costs.

When on, an exercise becomes myo-reps if **it is an isolation movement, or it is
the second (or later) exercise for that muscle group in the session** — and never
the first exercise of a workout, so every session keeps at least one straight-set
exercise. Myo-rep exercises are written with **6 sets** (one activation set plus
five clusters), matching what the active-workout screen expects, and count as
**3 sets** of volume — the same `MYOREPS_COUNTED_SETS` the app's volume guide
already uses.

Everything is editable afterwards: the exercise review lets any exercise be
switched between straight sets, myo-reps and drop sets.

### 2.6 Exercises

The backend generates a draft and the client shows it, day by day, with the
achieved weekly volume per muscle next to the target. Nothing is saved until the
last step, and every exercise, set count and method can be changed first.

## 3. Prescription table

Reps and rest come from goal × movement pattern:

| Goal | Pattern | Reps | Rest | Sets/exercise |
|---|---|---|---|---|
| Stronger | Compound | 4–6 | 240 s | 4 |
| Stronger | Isolation | 6–10 | 150 s | 4 |
| Bigger & stronger | Compound | 5–8 | 180 s | 3 |
| Bigger & stronger | Isolation | 8–12 | 90 s | 3 |

"More sets and fewer reps" for the strength goal falls out of the sets/exercise
column plus the rep ranges; the 4–12 band for the hybrid goal falls out of its
two rows.

## 4. Movement pattern

`exercises.movement_pattern` — `COMPOUND` | `ISOLATION`, added in **V14** and
curated by name for all 106 seeded exercises.

It cannot be inferred from the existing data: Bench Press carries exactly one
PRIMARY muscle (chest), the same as Lateral Raise, so any "2+ primary muscles =
compound" heuristic mislabels every horizontal press, push-up and narrow-grip
pull-up. Multi-joint movements are compound; single-joint are isolation, with two
deliberate judgement calls — hip thrusts and hinges (RDL, SLDL, good mornings)
count as compound because they are programmed and loaded like one, and face pulls
count as isolation because they are accessory work and a good myo-rep candidate.

The pattern drives three things: the prescription table above, the compound bias
in exercise selection, and myo-rep candidacy.

> `ProgressionService.isLowerBodyCompound` still infers "compound" from primary
> muscle slugs for its +5 kg / +2.5 kg jump. It should move onto this column, but
> that is a separate change.

## 5. The allocator

Per day, per muscle group in that day's type:

```
target[muscle] = weeklySetsPerMuscle / (times that muscle appears in the split)
```

Then greedily fill the deficit. An exercise contributes to every muscle it
trains, weighted by role — **PRIMARY = 1 set, SECONDARY = 0.5 sets** — so a
Bench Press pays into chest, front delts and triceps at once.

That weighting is documented on the `MuscleRole` enum and now applied
everywhere volume is counted: the allocator, the guided builder's review
screen, and the DIY builder's volume guide. The shared client-side rules live
in `mobile/src/utils/volume.ts` (`creditFor`, `countedSets`, `weeklyVolume`).
The DIY guide previously counted primary muscles only, so the same program
reported different numbers depending on which screen you were looking at.

Both numbers are kept and shown: **direct** (sets where the muscle is the
movement's target) and **total** (direct plus half a set for every set that
works it as a secondary). Rows read `12 direct · 18 total`, and the bar draws
the total pale behind a solid direct segment.

Which one the colour is judged against depends on what the target was written
for, and the two screens differ on purpose:

| Screen | Target | Coloured on |
|---|---|---|
| DIY volume guide | `WEEKLY_SETS_GUIDE`, fixed per-muscle ranges | **direct** — these are direct-set recommendations |
| Guided builder review | the volume slider | **total** — that is what the allocator fills |

Judging the DIY guide on total made every pressing program read "above max" on
shoulders (front delts land near 18 against a 8–12 range). Judging the guided
review on direct would flag 5 of 13 muscles short on a program the generator
considers complete, because arms, rear delts and hamstrings are largely trained
by the presses, rows and squats already in the week.

The trade is visible rather than hidden: on the DIY guide, muscles that train
mostly indirectly (triceps, hamstrings) now read as "building up" in blue with
their total alongside — which is a fair prompt to consider direct work, not an
error state.

```
score(E) = Σ_m min(deficit[m], credit(E, m))        // useful work
         − 0.5 · Σ_m max(0, credit(E, m) − deficit[m])   // overshoot
         + compoundBonus                            // 2.0 strength, 0.75 hybrid
         − 1.5 if this exercise is already used elsewhere in the program
```

Picking continues until every deficit is inside a 1-set tolerance or the day hits
its exercise cap (`ceil(totalDeficit / setsPerExercise)`, clamped to 3–9). At most
3 exercises per muscle per day. The draft reports planned-vs-target volume so the
UI can say plainly when a split cannot absorb the volume asked of it — 20 sets per
muscle across two days does not fit, and the honest answer is "add a day or lower
the number", not a silently truncated program.

**Worked example** (the one in the brief): 4 days, Upper/Lower ×2, 12 sets/muscle/
week, hybrid goal. Each muscle appears twice → target 6 sets per session; sets per
exercise is 3 → 2 exercises per muscle per day, 3 sets each. ✅

Variety: an exercise already used earlier in the program is penalised, so the
second upper day does not repeat the first one verbatim.

## 6. Session-length estimate

```
minutes = 6 (warm-up) + Σ over exercises:
    straight sets → sets × (rest + 40 s)
    myo-reps      → rest + 40 s + 5 × 35 s   (activation set + clusters)
```

Shown on the split step and the exercise review, because "a higher volume
typically means longer workouts" should be a number the lifter can see, not a
sentence they have to take on faith.

## 7. API

| Endpoint | Purpose |
|---|---|
| `GET /programs/splits?daysPerWeek=N` | Split options for a frequency, ranked, each with its day names and minimum per-muscle weekly frequency. |
| `POST /programs/draft` | `{goal, weeklySetsPerMuscle, daysPerWeek, splitId, recommendMyoreps}` → an **unsaved** program structure: days, exercises with sets/reps/rest/method, per-muscle planned-vs-target volume, estimated session minutes. |
| `POST /programs` | Unchanged shape, but `Ex` now carries optional `repsMin`, `repsMax`, `restSeconds` (previously the goal range overwrote whatever the client sent), the request carries `weeklySetsPerMuscle`, and `strengthDaysPerWeek` accepts 1. |

Generation lives on the backend so the rules are testable in one place and the
client stays a renderer.

## 8. Not doing

- **No reps-in-reserve column.** Proximity to failure is explained, not stored.
- **No cardio step.** It was in the old wizard, did nothing, and is dropped from
  the guided flow (the field stays on the request, defaulted to 0).
- **No equipment filter.** Every seeded exercise is assumed available.
- **Deload/periodisation** stays out — the progression algorithm owns that.
