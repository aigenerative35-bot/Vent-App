# Snip

Snip is a Flutter microblogging app. People write short, anonymous posts (max
300 characters), attach a **poll**, and others view, comment (with replies),
**Lift** (repost) and like them. Weibo-style layout in blue, English UI, light +
dark themes.

Ads: Google AdMob (native in the feed, rewarded before analytics, app-open
interstitial) - currently on Google's TEST ad unit ids.

## What works

- **Auth**: sign up / sign in with email, continue as guest, sign out
- **Home**: For You / Latest / Group Feed tabs, AI "Recommended for you",
  infinite scroll
- **Posts**: 300-char limit, mood tag, **polls** (create, vote, live %),
  hashtags, visibility (public / followers / private)
- **Counts**: views, comments, Lifts (reposts), likes
- **Comments with replies** (nested) and comment likes
- **Follow**, verified badges, tappable profiles
- **Groups** (create/join) and share to followers or a group
- **Status**: a 24-hour photo status that deletes itself
- **Studio**: analytics, quick post, links, about us
- **Settings**: notifications, privacy, username generator, sign out

## Architecture (and how to migrate to Firebase / Google Cloud / AWS / Yotta)

The UI never touches a backend directly - it only talks to two boundaries:

| Layer | File | Swap it for |
|---|---|---|
| Data (posts, users, groups, polls) | `lib/models.dart` (`AppState`) | Firestore, or a REST/gRPC API on your own servers |
| Auth | `lib/auth.dart` (`AuthService`) | Firebase Auth, or your own auth service |
| Ads | `lib/ads.dart` (platform-guarded) | AdMob (already), with your live ids |
| Theme | `lib/theme.dart` | - |

**To move to a real backend:**
1. Write a new class that implements `AuthService` (e.g. `FirebaseAuthService`)
   and point the `auth` instance in `lib/auth.dart` at it.
2. Replace `AppState`'s in-memory lists with calls to your API/DB - keep the
   same method names (`addPost`, `toggleLike`, `votePoll`, `toggleFollow`, ...).
3. Keep push on FCM, move media to S3-compatible storage, run your services on
   the host of your choice.

No screen has to change - that is the whole point of the two boundaries above.

## Run

    flutter pub get
    flutter run

Build an APK:

    flutter build apk --release

## Notes

- Internal package id is still `com.ventapp.vent`; the display name is **Snip**.
- Android + web platforms are enabled (one codebase, later a website).
