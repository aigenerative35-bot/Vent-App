# Vent

Vent is a small Flutter app where people write short, anonymous posts about how
they feel - anger, stress, sadness, gratitude - and others react and reply.

The UI is a modern, dark-and-light design: an X (Twitter) style feed with
comment / repost / like / share, an AI-driven **For You** feed, and an X-style
profile with a gradient banner and tabs. All UI text is in English.

This first version runs on **local demo data** (no backend yet), so it builds and
runs immediately. Firebase (Auth + Firestore) will replace the in-memory store
later; the UI only talks to `AppState`, so the swap stays contained.

## What works now

- Home feed with filter chips and an **AI "Recommended for you"** ranking
- Search screen with trending posts
- Create post: mood chips, anonymous toggle, live character count, gradient Post button
- Post detail with replies and a reply composer
- Activity (notifications)
- X-style profile: gradient banner, avatar, bio, Following/Followers, tabs
  (Posts / Replies / Media / Likes)
- Follows the system light / dark setting

## Run

    flutter pub get
    flutter run

Build an APK:

    flutter build apk --release

## Project layout

- `lib/main.dart` - app entry, bottom-nav shell, light/dark themes
- `lib/theme.dart` - brand gradient, palettes, theme, SoftCard
- `lib/models.dart` - models + in-memory AppState (demo data, AI ranking)
- `lib/widgets.dart` - Avatar, PostCard, ActionRow, GradientButton, etc.
- `lib/screens.dart` - all screens
- `.github/workflows/flutter.yml` - CI that builds the APK

## Notes

- The app name is a working name and can change.
- Android + web platforms are enabled (one codebase, later a website).
