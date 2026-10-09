# Vent

Vent is a Flutter social app where people share short, anonymous posts about how
they feel, and others like, comment and share them.

The UI follows a Facebook-style layout: a blue top bar with search, a
"What is on your mind?" create box, a Stories row, posts with
Like / Comment / Share, and a cover-photo profile with tabs. Light and dark
themes are both supported. All UI text is in English.

This version runs on **local demo data** (no backend yet), so it builds and runs
immediately. Firebase (Auth + Firestore) will replace the in-memory store later;
the UI only talks to `AppState`, so the swap stays contained.

## What works now

- Home: create box, Stories row, "Suggested for you" (AI-ranked) and Latest feed
- Friends: people you may know, with Add friend / Friends toggle
- Watch: trending posts
- Notifications: activity feed
- Compose: public post with mood tags and an anonymous toggle
- Post detail with comments and a comment composer
- Profile: cover photo, avatar, friends count, tabs (Posts / About / Friends / Photos)
- Follows the system light / dark setting

## Run

    flutter pub get
    flutter run

Build an APK:

    flutter build apk --release

## Project layout

- `lib/main.dart` - app entry, bottom-nav shell
- `lib/theme.dart` - brand colours, palettes, theme, FbCard
- `lib/models.dart` - models + in-memory AppState (demo data, AI ranking)
- `lib/widgets.dart` - Avatar, PostCard, ActionRow, StoryCircle, etc.
- `lib/screens.dart` - all screens
- `.github/workflows/flutter.yml` - CI that builds the APK

## Notes

- The app name is a working name and can change.
- Android + web platforms are enabled (one codebase, later a website).
