# MyDay

MyDay is a full-stack personal productivity app for tracking tasks, notes,
and habits. **Plan. Track. Grow.**

This repository is currently at the end of **Phase 1**: the frontend,
backend, and database foundations are in place, but no feature logic
(CRUD, authentication) has been implemented yet.

## 1. Project Overview

- Flutter mobile app with screens and navigation for auth, home, tasks,
  notes, habits, and profile.
- Node.js + Express REST API with a health check endpoint and placeholder
  routes for auth, tasks, notes, and habits.
- MongoDB Atlas database with Mongoose schemas for User, Task, Note, Habit,
  and HabitLog.

## 2. Tech Stack

| Layer     | Technology                     |
|-----------|---------------------------------|
| Frontend  | Flutter (Dart), Material 3      |
| Backend   | Node.js, Express.js             |
| Database  | MongoDB Atlas                   |
| ODM       | Mongoose                        |
| HTTP      | `http` package (Flutter)        |

Authentication (JWT), Tasks/Notes/Habits CRUD, and payments are **not**
implemented yet — see [Phase 2](#12-what-will-be-implemented-in-phase-2).

## 3. Flutter Setup

Requirements: Flutter SDK (3.x), an Android emulator or device.

```bash
flutter pub get
flutter run
```

## 4. Backend Setup

Requirements: Node.js 18+.

```bash
cd backend
npm install
npm run dev
```

## 5. MongoDB Atlas Setup

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

## 6. Environment Variables

Backend configuration lives in `backend/.env` (never commit this file).
Copy `backend/.env.example` and fill in your own values:

```
PORT=5000
MONGO_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your_secret_key
```

## 7. How to Run the Backend

```bash
cd backend
npm install
npm run dev
```

The API starts on `http://localhost:5000` (or the port set in `.env`).
It starts even if MongoDB isn't reachable yet — the connection is
attempted in the background and logged to the console.

## 8. How to Run the Flutter App

```bash
flutter pub get
flutter run
```

Select an emulator/device when prompted, or run with a specific device id,
e.g. `flutter run -d emulator-5554`.

## 9. Android Emulator API URL

The Android emulator can't reach your machine via `localhost`. It uses the
special alias `10.0.2.2` instead. This is already configured in
`lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

For a physical device, replace this with your computer's LAN IP
(e.g. `http://192.168.1.10:5000/api`). For production, replace it with your
deployed API URL.

## 10. Project Folder Structure

```
my_day/
├── lib/
│   ├── main.dart
│   ├── app/                  # App widget, routes, theme
│   ├── core/
│   │   ├── constants/        # API and app-wide constants
│   │   ├── network/          # Reusable HTTP client
│   │   └── utils/            # Validators, date helpers
│   ├── models/                # (empty — Phase 2)
│   ├── services/              # (empty — Phase 2)
│   ├── screens/
│   │   ├── splash/
│   │   ├── auth/              # login, register
│   │   ├── home/
│   │   ├── tasks/
│   │   ├── notes/
│   │   ├── habits/
│   │   └── profile/
│   └── widgets/                # Reusable buttons, fields, cards, empty state
│
└── backend/
    ├── src/
    │   ├── server.js
    │   ├── app.js
    │   ├── config/db.js         # MongoDB connection
    │   ├── models/               # User, Task, Note, Habit, HabitLog
    │   ├── routes/                # auth, tasks, notes, habits
    │   ├── controllers/
    │   └── middleware/errorMiddleware.js
    ├── .env / .env.example
    ├── .gitignore
    └── package.json
```

## 11. Phase 1 Completed Items

- [x] Flutter project with clean, scalable folder structure
- [x] Named routes and navigation between all 8 screens
- [x] Bottom navigation (Home, Tasks, Notes, Habits, Profile)
- [x] Reusable widgets: buttons, text fields, cards, empty states
- [x] `ApiConstants` + `ApiClient` foundation for future API calls
- [x] Express server with `GET /api/health`
- [x] CORS, JSON body parsing, centralized error middleware
- [x] MongoDB connection via `MONGO_URI` (no hardcoded credentials)
- [x] Mongoose schemas: User, Task, Note, Habit, HabitLog
- [x] Placeholder routes for `/api/auth`, `/api/tasks`, `/api/notes`,
      `/api/habits` returning `"Coming in next phase"`
- [x] `.env.example` and `.gitignore` for both frontend and backend

## 12. What Will Be Implemented in Phase 2

- Real authentication (register/login) with JWT and password hashing
- Tasks, Notes, and Habits CRUD (controllers + persistence)
- Habit logging/streak tracking
- Connecting Flutter screens to the live API via `ApiClient`
- Form submission wired to real endpoints instead of local navigation
- Input validation on the backend with `express-validator`
- Basic user session handling in the Flutter app

## 13. How to Test `/api/health`

With the backend running:

```bash
curl http://localhost:5000/api/health
```

Expected response:

```json
{
  "success": true,
  "message": "MyDay API is running"
}
```
