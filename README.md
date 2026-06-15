# REPS — Strength Training Tracker

A full-stack strength training application with a Java Spring Boot backend and React Native (Expo) frontend supporting both iOS, Android, and web.

## Architecture

```
REPS/
├── backend/          Java 21 · Spring Boot 3.2 · PostgreSQL · Flyway
└── mobile/           React Native (Expo) · TypeScript · TanStack Query · Zustand
```

## Getting Started

### Prerequisites
- Docker + Docker Compose
- Java 21 (for local backend dev)
- Node.js 20+ and npm (for frontend)
- Expo CLI: `npm install -g expo-cli`

### 1. Start the database (+ backend) with Docker

```bash
cp .env.example .env
# Edit .env with your secrets

docker-compose up -d postgres       # database only
# OR
docker-compose up -d                # database + backend
```

### 2. Backend (local dev)

```bash
cd backend
./mvnw spring-boot:run
# API available at http://localhost:8080/api
# Swagger UI at http://localhost:8080/api/swagger-ui.html
```

### 3. Frontend (mobile/web)

```bash
cd mobile
cp .env.example .env.local
# Edit EXPO_PUBLIC_API_URL if needed

npm install
npx expo start

# Press i → iOS simulator
# Press a → Android emulator
# Press w → Web browser
```

## Key Features

- **Program generation** — auto-builds Push/Pull/Legs, Upper/Lower, or Full Body splits based on training days, fitness level (BEGINNER/INTERMEDIATE/ADVANCED), and goal (Hypertrophy/Strength)
- **Volume tracking** — sets per muscle group per week, respecting PRIMARY (×1) and SECONDARY (×0.5) muscle contributions
- **Live workout logging** — weight + reps per set, rest timer, previous-session guidance shown inline
- **Training methods** — Straight Sets, Myoreps, Supersets, Trisets, Drop Sets
- **Progress graphs** — per-set lines for weight, reps, and estimated 1RM (Epley formula) over time
- **Body weight tracking** — trend graph with daily logging

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/auth/register` | Register + JWT |
| POST | `/api/auth/login` | Login + JWT |
| GET/POST | `/api/programs` | List / create program |
| GET | `/api/programs/active` | Active program with schedule |
| GET | `/api/exercises` | Exercise database |
| POST | `/api/workouts/sessions` | Start workout session |
| POST | `/api/workouts/sessions/{id}/complete` | Complete session |
| POST | `/api/workouts/sessions/{sid}/exercises/{eid}/sets` | Log a set |
| GET | `/api/progress/exercises/{id}` | Exercise progress history |
| GET/POST | `/api/progress/body-weight` | Body weight history / log |

## Exercise Database

Seeds 22 exercises across all major muscle groups, each with primary and secondary muscle mappings, coaching cues, and descriptions. More can be added via the API or additional Flyway migrations.

## Extending

- **Add exercises** — insert into `V4__more_exercises.sql`
- **Change colours** — edit `mobile/src/constants/theme.ts`
- **Add training methods** — extend the `TrainingMethod` enum in both backend and `mobile/src/types/index.ts`
- **Cloud deployment** — set `SPRING_DATASOURCE_URL`, `POSTGRES_*`, and `JWT_SECRET` env vars; the Dockerfile is production-ready

## Tech Stack

**Backend**: Java 21 · Spring Boot 3.2 · Spring Security (JWT) · Spring Data JPA · Hibernate · PostgreSQL · Flyway · Lombok · SpringDoc OpenAPI

**Frontend**: Expo SDK 51 · React Native 0.74 · Expo Router v3 · TypeScript · TanStack Query v5 · Zustand · Axios · Victory Native (charts) · NativeWind (Tailwind styling)
