# Snip — real backend & push notifications (optional, later)

The app already talks to the outside world through **one boundary**: `lib/repository.dart`.
Screens only ever talk to `AppState` (data) and `auth` (sign-in). So moving from the
local demo store to a real backend is a **one-file swap** — no screen changes.

```
screens  ->  AppState  ->  DataRepository  ->  LocalRepository   (today: on-device)
                                          \-> FirestoreRepository (later: real backend)
```

## What is already done

- Local persistence: posts, profile (with photo/banner), follows, bookmarks, drafts,
  blocked/muted lists, language and settings all survive an app restart
  (`shared_preferences`, key `snip_state_v1`).
- Auth is behind `AuthService` (`lib/auth.dart`); the demo uses `LocalAuthService`.
- Ads are behind a conditional import (`lib/ads.dart`).

## Step 1 — create the Firebase project (you do this, once)

1. Go to https://console.firebase.google.com and create a project (e.g. `snip-app`).
2. Add an **Android app** with package name `com.ventapp.vent`.
3. Download `google-services.json`.
4. Enable **Authentication** (Email/Password, and optionally Phone).
5. Create a **Cloud Firestore** database.

## Step 2 — give the build file (do NOT commit it to a public repo)

The repo is public, so never commit `google-services.json` or `google-services.json`'s
contents. Instead add it as a **GitHub Actions secret** and write it out in the workflow:

- Repo → Settings → Secrets and variables → Actions → New repository secret
  - Name: `GOOGLE_SERVICES_JSON`
  - Value: the full text of your `google-services.json`

Then, in `.github/workflows/flutter.yml`, before `flutter build apk`, add:

```yaml
      - name: Add google-services.json
        run: echo "${{ secrets.GOOGLE_SERVICES_JSON }}" > android/app/google-services.json
```

And add the Google Services Gradle plugin (follow the current Firebase Flutter docs for
`android/settings.gradle.kts` and `android/app/build.gradle.kts`).

## Step 3 — add the packages

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.4     # for post/profile images
  firebase_messaging: ^15.1.3   # push notifications (FCM)
```

Run `flutterfire configure` (the FlutterFire CLI) — it wires the platforms for you.

## Step 4 — implement the real repositories (the only code change)

**Data:** add a `FirestoreRepository implements DataRepository` in `lib/repository.dart`
that reads/writes the same JSON map `AppState.toJson()` already produces (e.g. one
document per user under `users/{uid}` and a `posts` collection). Then in `main.dart`:

```dart
final appState = AppState(repository: FirestoreRepository());
```

That is it — every screen keeps working unchanged.

**Auth:** add a `FirebaseAuthService implements AuthService` in `lib/auth.dart` and swap
`final auth = FirebaseAuthService();`.

**Images:** today avatars/banners/post images are stored as base64 inside the local
state. On a real backend, upload the bytes to Firebase Storage and store the download URL
instead — change only `toJson()`/`applyJson()`.

## Step 5 — push notifications (FCM)

1. Add `firebase_messaging` (above).
2. On startup, request permission and print/store the device token:
   `final token = await FirebaseMessaging.instance.getToken();`
3. Store each user's token in Firestore (`users/{uid}.fcmToken`).
4. Send notifications from a **Cloud Function** when someone likes/comments/follows —
   look up the target user's token and call `admin.messaging().send(...)`.
5. Handle taps with `FirebaseMessaging.onMessageOpenedApp` to deep-link into the post.

Until you do this, the app shows **in-app** notifications only (the Notifications screen);
nothing arrives while the app is closed.

## Step 6 — real AdMob

Replace the Google **test** IDs with your own:
- App ID in `android/app/src/main/AndroidManifest.xml`
- Native / interstitial / rewarded unit IDs in `lib/ads_mobile.dart`

Live ads only serve after the app is approved in the AdMob console.
