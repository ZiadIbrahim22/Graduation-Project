# 🚨 Reporting System

A Flutter mobile & web application that allows citizens to **submit and track incident reports** (fires, accidents, road damage, etc.) with **AI-powered categorization**, real-time status tracking, and push notifications.

---

## ✨ Features

- 🔐 **Authentication** — Secure login with JWT token management
- 📝 **Submit Reports** — Report incidents with title, description, location & photo
- 🤖 **AI Categorization** — Each report is automatically tagged and confidence-scored by AI
- 📊 **Dashboard** — Visual chart showing Pending / In-Progress / Solved counts
- 📋 **Reports History** — Browse and filter all submitted reports
- 🔔 **Push Notifications** — Firebase Cloud Messaging (foreground + background)
- 👤 **Profile Management** — Edit name, email, password, and profile image
- 🌍 **Localization** — Full Arabic & English support
- 🌙 **Dark / Light Theme** — Persisted theme preference
- 📍 **Location Data** — Latitude & longitude stored per report

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend | REST API (via `API_BASE_URL`) |
| Auth | JWT Token |
| Database / Realtime | Firebase Firestore |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| State Management | Provider + ValueNotifier |
| Charts | fl_chart |
| Fonts | Google Fonts (Inter) |
| Environment Config | flutter_dotenv |

---

## 📁 Project Structure

```
lib/
├── config/
│   └── api_config.dart         # Base URL and headers from .env
├── models/
│   ├── report.dart             # Report model + status enum + AI tag parsing
│   ├── user_model.dart         # User model
│   ├── notification.dart       # Notification model
│   └── auth_response.dart      # Login response model
├── screens/
│   ├── login_page.dart
│   ├── home_page.dart          # Dashboard + chart
│   ├── reports_history_page.dart
│   ├── profile_settings_page.dart
│   ├── change_email_page.dart
│   └── ...
├── services/
│   ├── auth_provider.dart      # Auth state (Provider)
│   ├── user_service.dart       # User CRUD + token storage
│   ├── notification_service.dart
│   ├── localization_service.dart
│   └── theme_service.dart
├── widgets/
│   ├── bottom_nav_bar.dart     # Custom animated bottom nav
│   ├── report_chart.dart       # Bar chart widget
│   └── custom_button.dart
├── firebase_options.dart       # Auto-generated, reads from .env
└── main.dart
```

---

## ⚙️ Setup & Installation

### Prerequisites

- Flutter SDK `>= 3.0.0`
- Dart `>= 3.0.0`
- Android Studio / VS Code
- A configured Firebase project

### 1. Clone the repository

```bash
git clone https://github.com/your-username/reporting-system.git
cd reporting-system
```

### 2. Create the `.env` file

Create a file named `.env` in the **root of the project** (next to `pubspec.yaml`):

```env
# ── REST API ──────────────────────────────────
API_BASE_URL=https://your-api-domain.com

# ── Firebase Shared ───────────────────────────
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com

# ── Firebase Android ──────────────────────────
FIREBASE_ANDROID_API_KEY=your-android-api-key
FIREBASE_ANDROID_APP_ID=1:xxxx:android:xxxx

# ── Firebase Web ──────────────────────────────
FIREBASE_WEB_API_KEY=your-web-api-key
FIREBASE_WEB_APP_ID=1:xxxx:web:xxxx
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_MEASUREMENT_WEB_ID=G-XXXXXXXXXX
```

> ⚠️ **Never commit `.env` to Git.** Make sure it's listed in `.gitignore`.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
# Android
flutter run

# Web
flutter run -d chrome
```

---

## 🔔 Push Notifications

The app handles FCM in **three states**:

| State | Handler |
|---|---|
| Foreground | `NotificationService.handleForegroundMessage()` |
| Background | `_firebaseMessagingBackgroundHandler()` in `main.dart` |
| Terminated | Handled by Firebase automatically |

The device token is sent to the backend on login and stored on the user profile.

---

## 🤖 AI Report Categorization

Each submitted report is processed by an AI model that returns:

- **`incidentType`** — Category (Fire, Accident, Pothole, etc.)
- **`aiTag`** — AI-assigned label
- **`confidence`** — Score as decimal (e.g. `0.89`) or percentage (`89`)

The app normalizes the confidence value automatically:
```
0.89  →  "89 %"
89    →  "89 %"
```

---

## 🌍 Localization

Supported languages: **English 🇬🇧** and **Arabic 🇸🇦**

Language preference is saved locally and applied on app restart. RTL layout is handled automatically by Flutter's localization delegates.

To switch language: go to **Profile → Settings → Language**.

---

## 📊 Report Statuses

| Status | Color | Description |
|---|---|---|
| Pending | ⬜ Grey | Submitted, awaiting review |
| In Progress | 🟠 Orange | Being handled |
| Solved | 🟢 Green | Resolved |

---

## 🔒 Security Notes

- All API keys and secrets are stored in `.env` and **never hardcoded**
- JWT token is stored locally and sent in request headers
- Firebase keys are loaded at runtime via `flutter_dotenv`
- `.env` must be added to `.gitignore` before pushing to any repository

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.