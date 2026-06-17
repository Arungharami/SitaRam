# SitaRam — Final QA Checklist

## Build Quality
- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — All tests passed
- [x] `flutter build apk --debug` — ✓ Built
- [x] `flutter build apk --release` — ✓ Built (54.5 MB)
- [x] `flutter build appbundle --release` — ✓ Built (54.2 MB)

## Android Configuration
- [x] Package ID: `com.leadai.sitaram`
- [x] App label: `SitaRam`
- [x] INTERNET permission declared in AndroidManifest
- [x] MainActivity package matches namespace
- [x] versionName: 1.0.0 / versionCode: 1

## Code Quality
- [x] Deprecated `withOpacity` replaced with `withValues`
- [x] Deprecated `background`/`onBackground` color scheme fixed
- [x] `use_build_context_synchronously` fixed in AI chat screen
- [x] `avoid_print` fixed (using `debugPrint`)
- [x] Search controller anti-pattern fixed in ResearchDashboard

## UI Screens
- [ ] Home — Kanda expansion tiles render correctly
- [ ] Reader — 4 tabs: English, Bangla, Insights, Audio work
- [ ] AI Guide — disclaimer banner visible, API key dialog works
- [ ] Research — search, filter chips, reflection notes save/load
- [ ] Donate — One-Time and Monthly tabs both display

## Content & Safety
- [x] AI Guide disclaimer shown on every open of AI tab
- [x] AI simulation mode works without API key
- [x] Source metadata (translator, copyright status) shown in reader
- [x] Bangla text displays correctly (Unicode 0x0980–0x09FF range)
- [x] No subscriptions, no ads, no paywalls in UI

## Before Publishing to Play Store
- [ ] Create production signing keystore
- [ ] Add signing config to build.gradle.kts
- [ ] Set up Privacy Policy page (host privacy_policy_draft.md online)
- [ ] Add app icon (1024×1024) — `flutter_launcher_icons`
- [ ] Add splash screen — `flutter_native_splash`
- [ ] Capture 8 screenshots per device category
- [ ] Complete IARC content rating questionnaire
- [ ] Upload AAB to Internal Testing track first
- [ ] Test on physical Android device

## APK / AAB Paths
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- Release AAB: `build/app/outputs/bundle/release/app-release.aab`

## Next Command (after keystore setup)
```bash
flutter build appbundle --release
```
Then upload `app-release.aab` to Google Play Console → Internal Testing.
