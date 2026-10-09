# Vent

Vent is a small Flutter app where people write short, anonymous posts about how they feel - anger, stress, sadness, gratitude - and others can react and comment. The UI follows a clean Zoho-style look: light background, white cards, blue accent, top bar and bottom navigation.

This first version runs on local demo data (no backend yet), so it builds and runs immediately. Firebase (Auth + Firestore) will replace the in-memory store later.

## What works now

- Home feed with a daily prompt banner
- Explore: Naya and Trending tabs
- Create post: mood chips, anonymous toggle, 300-char limit
- Post detail with reactions and comments
- Alerts and Profile (streak, badges, your posts)

## Run

    flutter pub get
    flutter run

Build an APK:

    flutter build apk --release

## Notes

- The app name is a working name and can change.
- Android + web platforms are enabled (one codebase, later a website).
