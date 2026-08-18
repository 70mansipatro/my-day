# MyDay

MyDay is a full-stack personal productivity app for tracking tasks, notes,
and habits. **Plan. Track. Grow.**

This repository now includes **Phase 5: Habit Tracking**. The app supports
secure, user-scoped habit creation, tracking, streak calculation, statistics,
and home-screen summaries across the Flutter client and the Express + MongoDB backend.

## Phase 5 - Habit Tracking

### Habit Features

- Create daily and weekly habits for the authenticated user only
- View all habits, a single habit, and today's scheduled habits
- Edit and deactivate or reactivate habits without losing history
- Delete habits and remove their related habit logs safely
- Toggle habit completion for the current day
- Search by habit name and description
- Filter by activity state, frequency, and category
- Sort by newest, oldest, name, or streak
- Review habit history and weekly completion stats
- Calculate current streak, best streak, and completion rate

### Daily and Weekly Habit Logic

Daily habits are scheduled every day. A daily streak is the count of consecutive
completed calendar days ending today. If today's completion is missing, the
current daily streak resets to 0.

Weekly habits only count scheduled target days. For a habit with target days
Monday, Wednesday, and Friday, only those weekdays are considered when
calculating streaks and completion rates. Tuesday or Thursday is never counted
as a missed scheduled day unless it is part of the chosen target set.

### Habit Logs and MongoDB Collections

The backend uses two collections in MongoDB:

- `habits` for habit metadata (`userId`, `name`, `description`, `category`,
  `frequency`, `targetDays`, `isActive`, timestamps)
- `habitLogs` for one completion record per habit per day

The `habitLogs` collection uses a unique compound index on `habitId` + `date` to
prevent duplicate logs for the same habit on the same calendar day.

### Habit API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|:----:|-------------|
| GET | `/api/habits` | Yes | List habits for the logged-in user |
| POST | `/api/habits` | Yes | Create a habit |
| GET | `/api/habits/today` | Yes | Get habits scheduled for today |
| GET | `/api/habits/:id` | Yes | Fetch one habit |
| PUT | `/api/habits/:id` | Yes | Update a habit |
| PATCH | `/api/habits/:id/toggle` | Yes | Toggle today's completion |
| DELETE | `/api/habits/:id` | Yes | Remove a habit and its logs |
| GET | `/api/habits/:id/history` | Yes | Get recent history |
| GET | `/api/habits/:id/stats` | Yes | Get streak and completion stats |

### Habit Model

The backend uses a Mongoose `Habit` model in `backend/src/models/Habit.js` with:

- `userId`: required `ObjectId` reference to `User`
- `name`: required, trimmed, 1-100 characters
- `description`: optional, trimmed, max 500 characters
- `category`: optional, trimmed, max 50 characters, default `General`
- `frequency`: `daily | weekly` with default `daily`
- `targetDays`: array of weekdays 0-6 for weekly habits
- `isActive`: boolean, default `true`
- `createdAt` / `updatedAt`: managed automatically by Mongoose timestamps

### Habit Log Model

The backend uses a Mongoose `HabitLog` model in `backend/src/models/HabitLog.js`:

- `userId`: required `ObjectId` reference to `User`
- `habitId`: required `ObjectId` reference to `Habit`
- `date`: normalized to the start of the day in UTC
- `completed`: boolean, default `true`
- `createdAt` / `updatedAt`: managed automatically by Mongoose timestamps

### Flutter Screens

- Habits list screen with search, filters, and sorting
- Add/edit habit screen with weekly weekday selector
- Habit detail screen with stats and history
- Home screen summary card for today's habits

### Testing Instructions

Backend:

```bash
cd backend
npm install
npm run dev
```

Flutter:

```bash
flutter pub get
flutter run
```

For Android emulator testing, the app uses `10.0.2.2` to reach the host API.

This project intentionally keeps the backend and frontend responsibilities
separate while using the same secure JWT authentication flow.


This repository includes **Phase 4: Notes Management**. The app now supports
secure, user-scoped note CRUD, searching, filtering, sorting, favorites, and
home-screen summaries across the Flutter client and the Express + MongoDB backend.

## Phase 4 - Notes Module

### Features

- Create notes for the authenticated user only
- View all notes and a single note by ID
- Edit existing notes
- Delete notes with confirmation in the UI
- Toggle favorite status
- Search by title and content
- Filter by category and favorites
- Sort by newest, oldest, or favorites
- Recent notes card on the Home screen
- Secure user-specific access with JWT-bound queries

### Note API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|:----:|-------------|
| GET | `/api/notes` | Yes | List notes for the logged-in user |
| POST | `/api/notes` | Yes | Create a note |
| GET | `/api/notes/:id` | Yes | Fetch a single note |
| PUT | `/api/notes/:id` | Yes | Update a note |
| PATCH | `/api/notes/:id/favorite` | Yes | Toggle favorite |
| DELETE | `/api/notes/:id` | Yes | Remove a note |

### Note Model

The backend uses a Mongoose `Note` model in `backend/src/models/Note.js` with the
following fields:

- `userId`: required `ObjectId` reference to `User`
- `title`: required, trimmed, 1-150 characters
- `content`: required, trimmed, 1-10000 characters
- `category`: optional, trimmed, max 50 characters, default `General`
- `isFavorite`: boolean, default `false`
- `createdAt` / `updatedAt`: managed automatically by Mongoose timestamps

### Authentication Requirement

All note requests require a valid JWT in the `Authorization: Bearer <token>`
header. The backend reads the verified `req.userId` from the token and never
trusts a client-supplied `userId`.

### User Data Isolation

Every note query is restricted to the authenticated user's ID. A user cannot
read, update, or delete another user's notes. If a note is not found for that
user, the API returns `404 { success: false, message: 'Note not found' }`.

### Search, Filter, and Sort

- `GET /api/notes?search=flutter` searches title and content case-insensitively
- `GET /api/notes?category=Study`
- `GET /api/notes?favorite=true|false`
- `GET /api/notes?sort=newest|oldest|favorite`
- Combined filters can be used together safely in a single query

### Flutter Screens

- Notes list screen with search, filter, and sort
- Add note screen
- Edit note screen
- Note detail screen
- Home dashboard recent notes card

### Testing Instructions

Backend:

```bash
cd backend
npm install
npm run dev
```

Then call the protected endpoints with a valid bearer token from a successful
login request.

Flutter:

```bash
flutter pub get
flutter run
```

For Android emulator testing, the app uses `10.0.2.2` to reach the host API.

## Phase 3 - Task Management

### Features

- Create tasks for the authenticated user only
- View all tasks, a single task, and task details
- Edit existing tasks
- Toggle completed state
- Delete tasks with confirmation in the UI
- Search by title and description
- Filter by status, priority, and category
- Sort by newest, oldest, due date, or priority
- Dashboard stats for total, completed, pending, and completion percentage
- Secure user-specific access with JWT-bound queries

### Task API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|:----:|-------------|
| GET | `/api/tasks` | Yes | List tasks for the logged-in user |
| POST | `/api/tasks` | Yes | Create a task |
| GET | `/api/tasks/:id` | Yes | Fetch one task |
| PUT | `/api/tasks/:id` | Yes | Update a task |
| PATCH | `/api/tasks/:id/toggle` | Yes | Toggle completion |
| DELETE | `/api/tasks/:id` | Yes | Remove a task |

### Task Model

The backend uses a Mongoose `Task` model in `backend/src/models/Task.js` with the
following fields:

- `userId`: required `ObjectId` reference to `User`
- `title`: required, trimmed, 1-150 characters
- `description`: optional, trimmed, max 1000 characters
- `priority`: `low | medium | high` with default `medium`
- `completed`: boolean with default `false`
- `dueDate`: optional `Date`
- `category`: optional, trimmed, max 50 characters
- `createdAt` / `updatedAt`: managed automatically by Mongoose timestamps

### Authentication Requirement

All task requests require a valid JWT in the `Authorization: Bearer <token>`
header. The backend reads the verified `req.userId` from the token and never
trusts a client-supplied `userId`.

### User Data Isolation

Every task query is restricted to the authenticated user's ID. A user cannot
read, update, or delete another user's tasks. If a task is not found for that
user, the API returns `404 { success: false, message: 'Task not found' }`.

### Search, Filter, and Sort

- `GET /api/tasks?search=flutter` searches title and description case-insensitively
- `GET /api/tasks?completed=true|false`
- `GET /api/tasks?priority=low|medium|high`
- `GET /api/tasks?category=Study`
- `GET /api/tasks?sort=newest|oldest|dueDate|priority`

### Flutter Screens

- Task list screen
- Add task screen
- Edit task screen
- Task detail screen
- Home dashboard summary with real task stats

### Testing Instructions

Backend:

```bash
cd backend
npm install
npm run dev
```

Then call the protected endpoints with a valid bearer token from a successful
login request.

Flutter:

```bash
flutter pub get
flutter run
```

For Android emulator testing, the app uses `10.0.2.2` to reach the host API.
This project intentionally keeps the backend and frontend responsibilities
separate while using the same secure JWT authentication flow.

## 1. Project Overview

- Flutter mobile app with a splash-screen session check, login/register
  screens, and a bottom-navigation home shell — all gated behind
  authentication.
- Node.js + Express REST API with JWT-based authentication, bcrypt password
  hashing, and input validation.
- MongoDB Atlas database with a Mongoose `User` schema (hashed passwords
  only, never returned in API responses).

## 2. Tech Stack

| Layer     | Technology                                  |
|-----------|----------------------------------------------|
| Frontend  | Flutter (Dart), Material 3, Provider          |
| Backend   | Node.js, Express.js                           |
| Database  | MongoDB Atlas, Mongoose                       |
| Auth      | JWT (jsonwebtoken), bcryptjs                  |
| Validation| express-validator                             |
| Storage   | flutter_secure_storage (JWT), not SharedPreferences |
| HTTP      | `http` package (Flutter)                      |

## 3. Phase 2 — Authentication

### 3.1 API Endpoints

| Method | Endpoint             | Auth required | Description                          |
|--------|-----------------------|:-------------:|---------------------------------------|
| POST   | `/api/auth/register`  | No            | Create a user, returns user + JWT     |
| POST   | `/api/auth/login`     | No            | Validate credentials, returns user + JWT |
| GET    | `/api/auth/me`        | Yes           | Return the current authenticated user |
| POST   | `/api/auth/logout`    | Yes           | Stateless logout acknowledgement      |

All responses follow the shape `{ success, message?, data? }`. Errors never
leak stack traces, database errors, or secrets.

### 3.2 JWT Authentication

- On register/login, the server signs a JWT containing only `{ userId }`
  using `JWT_SECRET`, expiring after `JWT_EXPIRES_IN` (default `7d`).
- Protected routes require `Authorization: Bearer <token>`. The
  `authMiddleware` (`backend/src/middleware/authMiddleware.js`) verifies the
  token and attaches `req.userId` — this id is never trusted from the client.
- Invalid, missing, or expired tokens return `401 { success: false, message:
  "Unauthorized" }`.

### 3.3 Password Security

- Passwords are hashed with `bcryptjs` in a Mongoose `pre('save')` hook
  before being written to MongoDB — plaintext passwords are never stored.
- The `password` field uses `select: false`, so it is excluded from queries
  by default and never returned in any API response.
- Login compares the submitted password against the stored hash with
  `bcrypt.compare()`.

### 3.4 MongoDB User Collection

Database: `myday`, collection: `users`.

```json
{
  "_id": "665f1a2b3c4d5e6f7a8b9c0d",
  "name": "Mansi",
  "email": "mansi@example.com",
  "password": "$2b$10$examplehashvalue...",
  "createdAt": "2026-08-17T10:00:00.000Z",
  "updatedAt": "2026-08-17T10:00:00.000Z"
}
```

### 3.5 Flutter Authentication Flow

```
Splash Screen
      |
Check secure storage for JWT
      |
Token exists? --- NO ---> Login Screen
      | YES
GET /api/auth/me
      |
Valid? --- NO ---> delete token, clear user state ---> Login Screen
      | YES
Home Screen
```

- `SecureStorageService` (`lib/core/storage/secure_storage_service.dart`)
  wraps `flutter_secure_storage` — the JWT is never stored with
  SharedPreferences, printed to the console, or shown in the UI.
- `AuthProvider` (`lib/providers/auth_provider.dart`) exposes `AuthStatus`
  (`unknown`, `loading`, `authenticated`, `unauthenticated`), the current
  user, and `login()` / `register()` / `logout()` / `checkAuthStatus()`.
- `ApiClient` (`lib/core/network/api_client.dart`) attaches the bearer token
  to authenticated requests and, on a `401`, clears the session and routes
  the user back to Login automatically.
- After login/register/logout, the navigation stack is cleared with
  `pushNamedAndRemoveUntil` so the back button can't return an authenticated
  user to Login/Register, or a logged-out user back to Home.

## 4. Flutter Setup

Requirements: Flutter SDK (3.x), an Android emulator or device.

```bash
flutter pub get
flutter run
```

## 5. Backend Setup

Requirements: Node.js 18+.

```bash
cd backend
npm install
npm run dev
```

## 6. MongoDB Atlas Setup

1. Create a free account at https://www.mongodb.com/cloud/atlas.
2. Create a new Cluster (the free M0 tier is enough for development).
3. Under **Database Access**, create a database user with a username and
   password.
4. Under **Network Access**, add your current IP address (or
   `0.0.0.0/0` for local development only).
5. Click **Connect > Drivers** and copy the connection string. It looks
   like:
   `mongodb+srv://<username>:<password>@<cluster-url>/myday?retryWrites=true&w=majority`
6. Paste that string into `backend/.env` as `MONGO_URI`, using `myday` as
   the database name.

## 7. Environment Variables

Backend configuration lives in `backend/.env` (never commit this file — it
is already listed in `backend/.gitignore`). Copy `backend/.env.example` and
fill in your own values:

```
PORT=5000
MONGO_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your_long_random_secret
JWT_EXPIRES_IN=7d
```

`JWT_SECRET` should be a long, random string — never reuse the example
value in a real deployment. Never commit real credentials, connection
strings, or secrets.

## 8. How to Run the Backend

```bash
cd backend
npm install
npm run dev
```

The API starts on `http://localhost:5000` (or the port set in `.env`).

## 9. How to Run the Flutter App

```bash
flutter pub get
flutter run
```

Select an emulator/device when prompted, or run with a specific device id,
for example: `flutter run -d emulator-5554`.

## 10. Android Emulator API URL

The Android emulator can't reach your machine via `localhost`. It uses the
special alias `10.0.2.2` instead. This is already configured in
`lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

For a physical device, replace this with your computer's LAN IP
(e.g. `http://192.168.1.10:5000/api`). For production, replace it with your
deployed API URL. Keep this centralized in `api_constants.dart` — don't
hardcode the base URL anywhere else.

## 11. Testing the Backend

With the backend running (`cd backend && npm run dev`), using curl or
Postman:

```bash
# 1. Register a new user
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Mansi","email":"mansi@example.com","password":"Password123"}'

# 2. Register the same email again -> 409 "Email already registered"
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Mansi","email":"mansi@example.com","password":"Password123"}'

# 3. Login with correct credentials -> 200 + token
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"mansi@example.com","password":"Password123"}'

# 4. Login with the wrong password -> 401 "Invalid email or password"
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"mansi@example.com","password":"WrongPass1"}'

## 1. Project Overview

- Flutter mobile app with a splash-screen session check, login/register
  screens, and a bottom-navigation home shell — all gated behind
  authentication.
- Node.js + Express REST API with JWT-based authentication, bcrypt password
  hashing, and input validation.
- MongoDB Atlas database with a Mongoose `User` schema (hashed passwords
  only, never returned in API responses).

## 2. Tech Stack

| Layer     | Technology                                  |
|-----------|----------------------------------------------|
| Frontend  | Flutter (Dart), Material 3, Provider          |
| Backend   | Node.js, Express.js                           |
| Database  | MongoDB Atlas, Mongoose                       |
| Auth      | JWT (jsonwebtoken), bcryptjs                  |
| Validation| express-validator                             |
| Storage   | flutter_secure_storage (JWT), not SharedPreferences |
| HTTP      | `http` package (Flutter)                      |

## 3. Phase 2 — Authentication

### 3.1 API Endpoints

| Method | Endpoint             | Auth required | Description                          |
|--------|-----------------------|:-------------:|---------------------------------------|
| POST   | `/api/auth/register`  | No            | Create a user, returns user + JWT     |
| POST   | `/api/auth/login`     | No            | Validate credentials, returns user + JWT |
| GET    | `/api/auth/me`        | Yes           | Return the current authenticated user |
| POST   | `/api/auth/logout`    | Yes           | Stateless logout acknowledgement      |

All responses follow the shape `{ success, message?, data? }`. Errors never
leak stack traces, database errors, or secrets.

### 3.2 JWT Authentication

- On register/login, the server signs a JWT containing only `{ userId }`
  using `JWT_SECRET`, expiring after `JWT_EXPIRES_IN` (default `7d`).
- Protected routes require `Authorization: Bearer <token>`. The
  `authMiddleware` (`backend/src/middleware/authMiddleware.js`) verifies the
  token and attaches `req.userId` — this id is never trusted from the client.
- Invalid, missing, or expired tokens return `401 { success: false, message:
  "Unauthorized" }`.

### 3.3 Password Security

- Passwords are hashed with `bcryptjs` in a Mongoose `pre('save')` hook
  before being written to MongoDB — plaintext passwords are never stored.
- The `password` field uses `select: false`, so it is excluded from queries
  by default and never returned in any API response.
- Login compares the submitted password against the stored hash with
  `bcrypt.compare()`.

### 3.4 MongoDB User Collection

Database: `myday`, collection: `users`.

```json
{
  "_id": "665f1a2b3c4d5e6f7a8b9c0d",
  "name": "Mansi",
  "email": "mansi@example.com",
  "password": "$2b$10$examplehashvalue...",
  "createdAt": "2026-08-17T10:00:00.000Z",
  "updatedAt": "2026-08-17T10:00:00.000Z"
}
```

### 3.5 Flutter Authentication Flow

```
Splash Screen
      |
Check secure storage for JWT
      |
Token exists? --- NO ---> Login Screen
      | YES
GET /api/auth/me
      |
Valid? --- NO ---> delete token, clear user state ---> Login Screen
      | YES
Home Screen
```

- `SecureStorageService` (`lib/core/storage/secure_storage_service.dart`)
  wraps `flutter_secure_storage` — the JWT is never stored with
  SharedPreferences, printed to the console, or shown in the UI.
- `AuthProvider` (`lib/providers/auth_provider.dart`) exposes `AuthStatus`
  (`unknown`, `loading`, `authenticated`, `unauthenticated`), the current
  user, and `login()` / `register()` / `logout()` / `checkAuthStatus()`.
- `ApiClient` (`lib/core/network/api_client.dart`) attaches the bearer token
  to authenticated requests and, on a `401`, clears the session and routes
  the user back to Login automatically.
- After login/register/logout, the navigation stack is cleared with
  `pushNamedAndRemoveUntil` so the back button can't return an authenticated
  user to Login/Register, or a logged-out user back to Home.

## 4. Flutter Setup

Requirements: Flutter SDK (3.x), an Android emulator or device.

```bash
flutter pub get
flutter run
```

## 5. Backend Setup

Requirements: Node.js 18+.

```bash
cd backend
npm install
npm run dev
```

## 6. MongoDB Atlas Setup

1. Create a free account at https://www.mongodb.com/cloud/atlas.
2. Create a new Cluster (the free M0 tier is enough for development).
3. Under **Database Access**, create a database user with a username and
   password.
4. Under **Network Access**, add your current IP address (or
   `0.0.0.0/0` for local development only).
5. Click **Connect > Drivers** and copy the connection string. It looks
   like:
   `mongodb+srv://<username>:<password>@<cluster-url>/myday?retryWrites=true&w=majority`
6. Paste that string into `backend/.env` as `MONGO_URI`, using `myday` as
   the database name.

## 7. Environment Variables

Backend configuration lives in `backend/.env` (never commit this file — it
is already listed in `backend/.gitignore`). Copy `backend/.env.example` and
fill in your own values:

```
PORT=5000
MONGO_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your_long_random_secret
JWT_EXPIRES_IN=7d
```

`JWT_SECRET` should be a long, random string — never reuse the example
value in a real deployment. Never commit real credentials, connection
strings, or secrets.

## 8. How to Run the Backend

```bash
cd backend
npm install
npm run dev
```

The API starts on `http://localhost:5000` (or the port set in `.env`).

## 9. How to Run the Flutter App

```bash
flutter pub get
flutter run
```

Select an emulator/device when prompted, or run with a specific device id,
e.g. `flutter run -d emulator-5554`.

## 10. Android Emulator API URL

The Android emulator can't reach your machine via `localhost`. It uses the
special alias `10.0.2.2` instead. This is already configured in
`lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

For a physical device, replace this with your computer's LAN IP
(e.g. `http://192.168.1.10:5000/api`). For production, replace it with your
deployed API URL. Keep this centralized in `api_constants.dart` — don't
hardcode the base URL anywhere else.

## 11. Testing the Backend

With the backend running (`cd backend && npm run dev`), using curl or
Postman:

```bash
# 1. Register a new user
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Mansi","email":"mansi@example.com","password":"Password123"}'

# 2. Register the same email again -> 409 "Email already registered"
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Mansi","email":"mansi@example.com","password":"Password123"}'

# 3. Login with correct credentials -> 200 + token
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"mansi@example.com","password":"Password123"}'

# 4. Login with the wrong password -> 401 "Invalid email or password"
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"mansi@example.com","password":"WrongPass1"}'

# 5. Login with an email that doesn't exist -> 401 "Invalid email or password"
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"nobody@example.com","password":"Password123"}'

# 6. Get the current user with a valid token (replace TOKEN)
curl http://localhost:5000/api/auth/me -H "Authorization: Bearer TOKEN"

# 7. Get the current user with no token -> 401 "Unauthorized"
curl http://localhost:5000/api/auth/me

# 8. Get the current user with an invalid token -> 401 "Unauthorized"
curl http://localhost:5000/api/auth/me -H "Authorization: Bearer garbage"

# 9. Logout
curl -X POST http://localhost:5000/api/auth/logout -H "Authorization: Bearer TOKEN"
```

10. Restart the backend (`Ctrl+C`, then `npm run dev` again) and repeat
    step 6 with the same token — the user should still be found in MongoDB
    Atlas, confirming persistence.

## 12. Testing the Flutter App

1. Open the app — the Splash screen appears while the session is checked.
2. With no stored token, the Login screen appears.
3. Tap **Register**, create an account — on success you're taken to Home.
4. Close the app fully and reopen it — you should land on Home directly
   (the stored JWT is validated against `/api/auth/me`).
5. Go to **Profile** and tap **Logout** — you're returned to Login and the
   token is deleted from secure storage.
6. Log in again with the same credentials.
7. Try logging in with the wrong password — a friendly
   "Invalid email or password" message appears (no raw server errors).
8. If the backend is stopped or unreachable, a friendly "Unable to connect
   to server..." message appears instead of a stack trace.

## 13. What's Next (Phase 3)

- Tasks, Notes, and Habits CRUD (controllers + persistence)
- Habit logging / streak tracking
- Connecting the remaining Flutter screens to live data

## 14. Project Folder Structure

```
my_day/
├── lib/
│   ├── main.dart                  # Wires up ApiClient, AuthService, AuthProvider
│   ├── app/                       # App widget, routes, theme
│   ├── core/
│   │   ├── constants/             # API and app-wide constants
│   │   ├── network/               # ApiClient (auth headers, 401 handling)
│   │   ├── storage/                # SecureStorageService (JWT)
│   │   └── utils/                 # Validators, date helpers
│   ├── models/
│   │   └── user_model.dart
│   ├── providers/
│   │   └── auth_provider.dart
│   ├── services/
│   │   └── auth_service.dart
│   ├── screens/
│   │   ├── splash/                # Checks stored session on startup
│   │   ├── auth/                  # login, register
│   │   ├── home/
│   │   ├── tasks/
│   │   ├── notes/
│   │   ├── habits/
│   │   └── profile/                # Shows current user, logout
│   └── widgets/                    # Reusable buttons, fields, cards, empty state
│
└── backend/
    ├── src/
    │   ├── server.js
    │   ├── app.js
    │   ├── config/db.js             # MongoDB connection
    │   ├── models/User.js            # Hashed password, select:false
    │   ├── routes/authRoutes.js      # register, login, me, logout
    │   ├── controllers/authController.js
    │   ├── middleware/
    │   │   ├── authMiddleware.js     # JWT verification
    │   │   └── errorMiddleware.js
    │   └── utils/generateToken.js
    ├── .env / .env.example
    ├── .gitignore
    └── package.json
```

## 15. Security Checklist

- [x] Passwords hashed with bcryptjs before saving, never stored in plaintext
- [x] `password` field uses `select: false` and is never returned by any API
- [x] JWT signed with `JWT_SECRET` from `.env`, never hardcoded
- [x] MongoDB URI read from `.env`, never hardcoded
- [x] Generic "Invalid email or password" message — doesn't reveal whether
      an email is registered
- [x] `/api/auth/me` and `/api/auth/logout` protected by JWT middleware
- [x] `req.userId` comes only from the verified JWT, never from client input
- [x] Input validated server-side with `express-validator` (client-side
      validation is a UX convenience only, never trusted alone)
- [x] `.env` is gitignored and was never committed
- [x] JWT stored in `flutter_secure_storage`, never SharedPreferences, never
      logged or shown in the UI

## Phase 6 - Dashboard + Progress + App Polish

### Overview

Phase 6 completes the MyDay app with a comprehensive dashboard that aggregates
all user data (tasks, notes, habits, logs) into a single, unified view. No new
data collections are created; all dashboard information is calculated dynamically
from existing MongoDB documents.

### Dashboard Endpoint

**GET `/api/dashboard`**

- **Auth Required:** Yes (JWT)
- **User Scope:** Data is always filtered to `req.userId` from the JWT
- **Response:** Aggregated task stats, note summary, habit stats, streaks, 
  weekly progress, and recent activity

#### Response Structure

```json
{
  "success": true,
  "data": {
    "greeting": "Good morning",
    "date": "2026-08-18",
    "tasks": {
      "total": 10,
      "completed": 6,
      "pending": 4,
      "completionRate": 60.0
    },
    "todayTasks": {
      "total": 5,
      "completed": 3,
      "pending": 2
    },
    "notes": {
      "total": 8,
      "favorites": 3
    },
    "habits": {
      "total": 5,
      "completedToday": 3,
      "pendingToday": 2,
      "completionRate": 60.0
    },
    "streaks": {
      "bestCurrentStreak": 12
    },
    "weeklyProgress": [
      {
        "date": "2026-08-12",
        "day": "Mon",
        "tasksCompleted": 2,
        "habitsCompleted": 3
      }
      // ... 7 days total
    ],
    "recentTasks": [
      {
        "id": "...",
        "title": "Complete Flutter project",
        "completed": false,
        "priority": "high",
        "dueDate": "2026-08-20T00:00:00.000Z"
      }
      // ... up to 5 items
    ],
    "recentNotes": [
      {
        "id": "...",
        "title": "...",
        "category": "...",
        "isFavorite": true,
        "updatedAt": "..."
      }
      // ... up to 5 items
    ],
    "todayHabits": [
      {
        "id": "...",
        "name": "Coding",
        "category": "General",
        "completedToday": true,
        "currentStreak": 7
      }
      // ... scheduled for today
    ]
  }
}
```

### Dashboard Features

#### 1. Greeting and Date
- Time-based greeting: "Good morning" (5-11:59), "Good afternoon" (12-16:59),
  "Good evening" (17-20:59), "Good night" (21-04:59)
- Today's date in `YYYY-MM-DD` format

#### 2. Task Statistics
- Total tasks, completed tasks, pending tasks, completion rate %
- Today's task counts (tasks due today)

#### 3. Notes Summary
- Total notes, favorite notes count
- Recent notes (up to 5, sorted by `updatedAt` descending)

#### 4. Habit Statistics
- Total active habits
- Completed today, pending today (only counting scheduled habits)
- Completion rate for today
- Best current streak across all habits

#### 5. Weekly Progress (Last 7 Days)
- For each day: date, day name, tasks completed, habits completed
- Uses existing `dueDate` for tasks and `habitLogs` for habit completion

#### 6. Recent Activity
- Recent tasks (up to 5)
- Recent notes (up to 5)
- No separate collection needed; uses existing timestamps

### Database Queries

All dashboard queries are user-scoped to `req.userId`:

```javascript
// Tasks
Task.find({ userId, completed: { $in: [true, false] } })

// Notes
Note.find({ userId })

// Active habits
Habit.find({ userId, isActive: true })

// Habit logs for the week
HabitLog.find({ userId, date: { $gte: weekStart, $lt: today + 1 day } })
```

### Existing Indexes (Verified)

**Task collection:**
- `{ userId: 1, completed: 1 }` ✓
- `{ userId: 1, dueDate: 1 }` ✓

**Note collection:**
- `{ userId: 1 }` ✓
- `{ userId: 1, isFavorite: 1 }` ✓

**Habit collection:**
- `{ userId: 1, isActive: 1 }` ✓

**HabitLog collection:**
- `{ habitId: 1, date: 1 }` (unique) ✓
- `{ userId: 1, date: 1 }` ✓

### Flutter Dashboard Architecture

#### Models (`lib/models/dashboard_model.dart`)
- `DashboardModel`: Main response container
- `TaskSummary`, `TodayTaskSummary`
- `NoteSummary`, `HabitSummary`, `StreakSummary`
- `WeeklyProgress`
- `DashboardTask`, `DashboardNote`, `DashboardHabit`

All models include `fromJson()` and `toJson()` for serialization.

#### Service (`lib/services/dashboard_service.dart`)
- `DashboardService.getDashboard()`: Calls `/api/dashboard` endpoint
- Uses existing `ApiClient` with automatic JWT attachment

#### Provider (`lib/providers/dashboard_provider.dart`)
- `DashboardProvider`: Manages dashboard state
- `dashboard`: Cached `DashboardModel`
- `isLoading`, `isRefreshing`: Loading states
- `loadDashboard()`: Initial load
- `refreshDashboard()`: Pull-to-refresh
- `errorMessage`: User-friendly error messages

#### Widgets (`lib/screens/home/dashboard_widgets.dart`)
- `DashboardSummaryCard`: Generic card for key metrics
- `TaskProgressCard`: Tasks overview with progress bar
- `HabitProgressCard`: Today's habits with streak display
- `NotesSummaryCard`: Notes count and favorites
- `WeeklyProgressCard`: 7-day bar chart visualization
- `RecentActivityItem`: Activity list item
- `QuickActionsRow`: Quick + Task/Note/Habit buttons
- `EmptyDashboardState`: Welcome state when no data

### Home Screen (Updated)

**`lib/screens/home/home_screen.dart`**
- Replaced manual task/note/habit loading with dashboard provider
- Single `GET /api/dashboard` call instead of multiple API calls
- Smooth `RefreshIndicator` for pull-to-refresh
- Responsive card-based layout
- Error and loading states

### Profile Screen (Polished)

**`lib/screens/profile/profile_screen.dart`**
- User info in a card with avatar
- Links to settings and about screens
- Logout confirmation dialog
- Professional Material 3 design

### Settings & About Screens

**`lib/screens/profile/settings_screen.dart`**
- Notifications, Privacy & Security placeholders
- About MyDay with version and build info
- Features list
- Privacy statement

**`lib/screens/profile/about_screen.dart`**
- App logo and name
- Version and build information
- Feature highlights
- Privacy information

### Weekly Progress Calculation

For each of the last 7 days:
1. Count tasks where `completed: true` and `dueDate` matches the day
2. Count `habitLogs` where `completed: true` and `date` matches the day
3. Return `{ date, day, tasksCompleted, habitsCompleted }`

**Note:** Weekly task completion uses current `completed` state only. If the
Task model doesn't store historical completion states, only the current state
is visible.

### Habit Scheduling in Dashboard

- Only active habits (`isActive: true`) are included
- Daily habits: always scheduled
- Weekly habits: only if `targetDays` includes the current weekday
- Pending today count: `scheduledToday: true && completedToday: false`

### Performance Optimizations

1. **Single Dashboard Endpoint**: One API call aggregates all data
2. **Efficient Queries**: All queries are indexed on `userId`
3. **No Extra Collections**: Uses existing Task, Note, Habit, HabitLog collections
4. **Lean Queries**: Only essential fields returned
5. **In-Memory Caching**: Provider caches dashboard in memory
6. **Limited Results**: Recent items capped at 5 each

### Error Handling

**Backend:**
- `401`: Invalid or expired JWT → `{ success: false, message: "Unauthorized" }`
- `500`: Database error → `{ success: false, message: "Internal server error" }`

**Flutter:**
- Network errors: "Unable to connect to server. Check your internet connection."
- 401 errors: Logged out automatically via `AuthProvider.handleUnauthorized`
- Other errors: "Something went wrong. Please try again."

### Testing Dashboard

#### Backend Test

```bash
# Start server
node backend/src/server.js

# Make an authenticated request (requires valid JWT)
curl -H "Authorization: Bearer <token>" http://localhost:5000/api/dashboard
```

Expected response: `{ success: true, data: { ... } }`

#### User Isolation Test

1. Create User A with tasks, notes, habits
2. Create User B with different data
3. Login User A → Dashboard shows only User A's data
4. Login User B → Dashboard shows only User B's data
5. Verify User A's data is never visible to User B

#### Empty State Test

- Login with new user → "Welcome to MyDay" screen
- Create first task/note/habit → Dashboard updates
- Quick action buttons navigate to correct screens

### API Endpoint Structure

```
GET /api/dashboard
  ├── Queries Task collection (userId-scoped)
  ├── Queries Note collection (userId-scoped)
  ├── Queries Habit collection (userId-scoped + isActive)
  ├── Queries HabitLog collection (userId-scoped + date range)
  ├── Calculates all statistics in-memory
  └── Returns aggregated JSON response
```

### What Wasn't Created

- **No new database collections** (e.g., no `dashboardStats` table)
- **No external chart libraries** (uses simple Flutter widgets)
- **No complex theme system** (uses existing Material 3 theme)
- **No push notifications** (placeholder in settings only)
- **No historical task tracking** (uses current `completed` state)
- **No separate analytics engine** (all calculations done in-memory)

### Files Created/Modified

**Backend:**
- ✓ `src/controllers/dashboardController.js` (new)
- ✓ `src/routes/dashboardRoutes.js` (new)
- ✓ `src/app.js` (modified - added dashboard routes)

**Frontend:**
- ✓ `lib/models/dashboard_model.dart` (new)
- ✓ `lib/services/dashboard_service.dart` (new)
- ✓ `lib/providers/dashboard_provider.dart` (new)
- ✓ `lib/screens/home/dashboard_widgets.dart` (new)
- ✓ `lib/screens/home/home_screen.dart` (modified)
- ✓ `lib/screens/profile/profile_screen.dart` (modified)
- ✓ `lib/screens/profile/settings_screen.dart` (new)
- ✓ `lib/core/constants/api_constants.dart` (modified - added dashboard endpoint)
- ✓ `lib/main.dart` (modified - added dashboard provider)

### Phase 6 Completion Checklist

- [x] Backend dashboard endpoint (`GET /api/dashboard`)
- [x] JWT authentication required
- [x] User-scoped data queries
- [x] Task statistics calculation
- [x] Today's task summary
- [x] Notes summary with recent items
- [x] Habit summary with completion tracking
- [x] Streak calculation (using Phase 5 logic)
- [x] Weekly progress (last 7 days)
- [x] Recent activity section
- [x] Flutter dashboard models
- [x] Dashboard service with API integration
- [x] Dashboard provider with state management
- [x] Dashboard widgets (cards, progress, charts)
- [x] Home screen transformed into dashboard
- [x] Pull-to-refresh functionality
- [x] Loading, error, and empty states
- [x] Profile screen polished
- [x] Settings screen created
- [x] About screen created
- [x] Responsive design
- [x] No existing Phase 1-5 features broken
- [x] Security: No cross-user data leaks
- [x] Performance: Single API call for all dashboard data
- [x] No new unnecessary database collections
- [x] Indexes reviewed (all optimal)
- [x] Error handling for network and auth errors

### Next Steps (Phase 7+)

- Push notifications
- Advanced analytics and charts
- Data export (CSV, PDF)
- Integration with calendar apps
- Dark mode toggle (UI-only, if theme doesn't exist)
- Collaborative features (share habits, tasks)
- Mobile app distribution
