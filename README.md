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
