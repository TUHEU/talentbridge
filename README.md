# Talent Bridge — Frontend (Flutter)

> **Repository:** `talent_bridge_frontend`  
> **Backend Repo:** `talent_bridge_backend`  
> Connect Talent. Build Futures.

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.24.0 / Dart 3.x |
| State | Provider + ChangeNotifier |
| HTTP | Dio with JWT auth interceptor |
| Storage | SharedPreferences + FlutterSecureStorage |
| Images | Cached Network Image + Image Picker |
| Charts | fl_chart |
| Fonts | Inter (Google Fonts) |

## Project Structure
```
lib/
├── core/
│   ├── constants/     # AppColors, AppConstants
│   ├── network/       # Dio ApiClient, ApiResult sealed class
│   ├── theme/         # AppTheme (light/dark), ThemeController
│   └── utils/         # Validators
├── features/
│   ├── auth/          # Login, Register, OTP, Forgot/Reset
│   ├── home/          # Dashboard
│   ├── ai_advisor/    # AI Career Chat
│   ├── opportunities/ # Job Board
│   ├── community/     # Posts & Comments
│   ├── messages/      # Inbox
│   ├── startup/       # Startup Ideas
│   └── profile/       # User Profile
└── shared/
    └── widgets/       # GradientButton, TbTextField
```

## Quick Start
```bash
flutter pub get
flutter run
```

## Backend URL
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:5003/api';
```

## Tests
```bash
flutter test                   # all tests
flutter test test/unit/        # unit tests
flutter test test/widget/      # widget tests
flutter test test/integration/ # integration tests
flutter test --coverage        # with coverage
```

## CI/CD
| Workflow | Trigger | Actions |
|----------|---------|---------|
| `flutter_ci.yml` | Push/PR | Format → Analyze → Test → Build APK & Web |
| `release.yml` | `git push --tags` | Release APK + AAB + Web zip |
| `Jenkinsfile` | Jenkins | Quality → Tests → Coverage → APK → Web |

## GitHub Actions Secrets Required
| Secret | Description |
|--------|-------------|
| `API_BASE_URL` | Backend URL e.g. `https://api.talentbridge.com/api` |
| `CODECOV_TOKEN` | Codecov.io token (optional) |
| `KEYSTORE_BASE64` | Android keystore base64 encoded |
| `ANDROID_KEY_ALIAS` | Keystore key alias |
| `ANDROID_KEY_PASSWORD` | Keystore key password |
| `ANDROID_STORE_PASSWORD` | Keystore store password |
