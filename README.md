# Vent

Vent is a Flutter social app where people share short, anonymous text posts about
how they feel, and others can view, comment (with replies), **Lift** (repost) and
like them.

The UI is a Weibo-style layout in blue: a top bar with search, tabs
(For You / Latest / Hot), an AI "Recommended for you" feed, posts with view /
comment / lift / like counts, an infinite feed that loads more as you scroll, and
a 24-hour photo **Status**. Light and dark themes are both supported. All UI text
is in English.

This version runs on **local demo data** (no backend yet). Firebase (Auth +
Firestore) will replace the in-memory store; the UI only talks to `AppState`, so
the swap stays contained.

## What works now

- Home: create box, Status row, AI "Recommended for you" + Latest + Hot tabs
- Infinite scroll: the feed loads more posts as you scroll (pagination)
- Posts show **views**, **comments**, **Lifts** (reposts) and **likes**
- Comments support **replies** (nested) and comment likes
- **Status**: add a photo status that disappears after 24 hours
- Discover: search + hot posts
- Notifications, and a cover-photo profile (Posts / Status / About)
- Follows the system light / dark setting

## Run

    flutter pub get
    flutter run

Build an APK:

    flutter build apk --release

## Project layout

- `lib/main.dart` - app entry, bottom-nav shell
- `lib/theme.dart` - brand blue, palettes, theme, Block
- `lib/models.dart` - models + in-memory AppState (demo data, pagination, statuses)
- `lib/widgets.dart` - Avatar, PostCard, CommentTile, StatusRing, etc.
- `lib/screens.dart` - all screens
- `.github/workflows/flutter.yml` - CI that builds the APK

## Notes

- The app name is a working name and can change.
- Posts are text only; photos live in the 24-hour Status.
- Android + web platforms are enabled (one codebase, later a website).
