# Vent

Vent is a Flutter social app where people share short, anonymous text posts about
how they feel, and others can view, comment (with replies), **Lift** (repost) and
like them. Weibo-style layout in blue, English UI, light + dark themes.

This version runs on **local demo data** (no backend yet). Firebase (Auth +
Firestore) will replace the in-memory store; the UI only talks to `AppState`.

## Features

- **Feed**: tabs For You / Latest / Hot; AI "Recommended for you" (~70% matched
  to the moods you engage with); infinite scroll (loads more as you scroll)
- **Counts** on every post: views, comments, Lifts (reposts), likes
- **Comments with replies** (nested) and comment likes
- **Follow** button on every user profile; tap an avatar to open their profile
- **Verified** badges
- **Hashtags** (#tags) are tappable and open a topic feed; **Trending topics**
- **Post visibility**: public / followers only / private
- **Auto-delete**: every post deletes itself 1 month after it is created
- **Groups**: create and join groups; share a post to your followers or a group
- **Admin panel**: analytics (views, likes, comments, followers, weekly chart),
  quick post, links, about us
- **Settings**: notification toggles, privacy, username generator, sponsored toggle
- **Status**: a 24-hour photo status that deletes itself
- **Sponsored** slot in the feed (native-ad style)

## Run

    flutter pub get
    flutter run

Build an APK:

    flutter build apk --release

## Project layout

- `lib/main.dart` - app entry, bottom-nav shell
- `lib/theme.dart` - brand blue, palettes, theme, Block
- `lib/models.dart` - models + in-memory AppState
- `lib/widgets.dart` - Avatar, PostCard, CommentTile, StatusRing, SponsoredCard, etc.
- `lib/screens.dart` - all screens
- `.github/workflows/flutter.yml` - CI that builds the APK

## Notes

- The app name is a working name and can change.
- Posts are text only; photos live in the 24-hour Status.
- Real AdMob ads and multi-user data need the Firebase / AdMob setup (next step).
