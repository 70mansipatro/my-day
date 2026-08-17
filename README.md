# MyDay

MyDay is a full-stack personal productivity app for tracking tasks, notes,
and habits. **Plan. Track. Grow.**

This repository is at the end of **Phase 2**: a complete, secure
authentication system (register, login, session persistence, logout) is
implemented end-to-end across the Flutter app and the Node.js API. Tasks,
Notes, and Habits CRUD are **not** implemented yet — see
[What's Next](#13-whats-next-phase-3).

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
