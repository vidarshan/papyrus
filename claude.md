# Papyrus

PDF chat app. Users upload PDFs and chat with them via the Gemini API.

## Stack
- Flutter (stable channel), Dart
- State management: Provider (ChangeNotifier)
- Backend: Firebase Auth + Cloud Firestore
- LLM: Google Gemini API
- UI: custom built

## Commands
- `flutter pub get` — install deps
- `flutter run` — dev
- `flutter analyze` — static analysis (run before considering any task done)
- `flutter test` — run tests
- `dart format .` — format
- `flutter build apk` / `flutter build ios` — release builds

## Conventions
- State lives in ChangeNotifier providers under lib/providers/
- Async Firestore/Gemini calls wrapped with proper loading + error states

## Rules for changes
- Always run `flutter analyze` after edits and fix any new warnings
- Dispose controllers (TextEditingController, etc.) in dispose()
- Don't introduce new state management libraries; stick with Provider