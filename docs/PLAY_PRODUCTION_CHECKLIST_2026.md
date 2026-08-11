# SitaRam Google Play Production Checklist — 2026

**Prepared:** August 10, 2026  
**Release engineering updated:** August 10, 2026  
**Package:** `com.leadai.sitaram`  
**Current app version:** `1.0.0+1`  
**Current target SDK:** Android 16 / API 36  
**Primary release path:** signed AAB → internal/closed testing → production
**Canonical privacy policy:** https://lead-ai.us/sitaram/privacy.html

## Current repository state

- [x] PR #3 release automation merged
- [x] PR #4 corpus verification gates and Flutter compile fixes merged
- [x] PR #6 professional Play-release preparation merged
- [x] API 36 Quality Gate passed
- [x] `flutter analyze` passes
- [x] `flutter test` passes
- [x] Google Play release candidate workflow exists
- [x] Package name in workflow and Android project is `com.leadai.sitaram`
- [x] Public release copy has been rewritten to avoid unsupported completeness claims
- [x] Privacy materials describe the current backend AI architecture
- [x] Production privacy policy is publicly reachable over HTTPS
- [x] Simulated donation flow removed from production Settings navigation
- [x] Android target upgraded to Android 16 / API 36
- [x] Android Gradle Plugin 9.0.1 satisfies the Android packaging baseline for 16 KB page-size alignment
- [x] Credentialed release pipeline was executed once and correctly failed closed when repository secrets were absent

## Current credential gate

The August 10 release attempt passed Flutter setup, dependency resolution, static analysis, tests, and the Home-screen smoke test, then stopped at the release-secret validation step before any signing or Play upload occurred.

The following GitHub Actions secrets are still required:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`
- `SITARAM_HF_ENDPOINT`
- `SITARAM_HF_APP_KEY`
- `PLAY_SERVICE_ACCOUNT_JSON` for automated Google Play upload

Use `docs/RELEASE_SECRETS_SETUP.md`. Do not put secret values in source control, issues, screenshots, or chat.

## Hard content gate

The committed `assets/content/coverage_report.json` currently reports:

- `corpusComplete: false`
- 645 expected Sargas
- 7 imported records
- 7 placeholder/stub records
- 0 human-verified Sargas
- 0 Sargas approved for retrieval
- 0 Sargas approved for app use

**Production rule:** Do not market the app as a complete Ramayana edition, a fully verified scripture library, or a complete multilingual corpus until the generated coverage report supports those claims.

A production build may expose the verification status and no-evidence behavior, but public claims must remain limited to functionality actually present in the shipping build.

## Android release gate

Before uploading a new release candidate:

- [ ] Confirm `versionCode` has never been used in Play Console
- [ ] Confirm the existing SitaRam upload keystore fingerprint matches the certificate already registered for `com.leadai.sitaram`
- [ ] Configure all GitHub Actions signing/backend secrets
- [ ] Confirm `SITARAM_HF_ENDPOINT` is the production HTTPS endpoint
- [ ] Confirm the production backend has `SITARAM_APP_KEY` configured as a deployment secret
- [ ] Confirm backend rate limiting / abuse controls are active
- [ ] Run the Android Release Candidate workflow
- [ ] Download and record the signed AAB SHA-256 checksum
- [ ] Confirm the resulting AAB targets API 36
- [ ] Confirm Play Console reports no 16 KB page-size compatibility blocker
- [ ] Smoke test the Play-installed build on a physical Android device

## Target API status

The release targets **Android 16 / API 36**.

Google Play's published schedule says that beginning **August 31, 2026**, standard Android new apps and updates must target **Android 16 / API 36 or higher**. The project meets that target-SDK requirement ahead of the deadline, subject to successful signed-build and runtime validation.

Official reference:

- https://support.google.com/googleplay/android-developer/answer/11926878

## 16 KB page-size compatibility

Google Play requires new apps and updates submitted for Android 15/API 35+ devices to support 16 KB memory page sizes. SitaRam is a Flutter application and ships native libraries, so final validation must use the generated signed release AAB.

- [x] Android Gradle Plugin is 9.0.1 (above Android's AGP 8.5.1 packaging baseline)
- [ ] Build the signed production AAB using the release workflow
- [ ] Check Play Console compatibility results for the uploaded AAB
- [ ] Confirm there is no 16 KB page-size compatibility error
- [ ] When possible, run the release build on a 16 KB Android 15/16 emulator or supported device

Official reference:

- https://developer.android.com/guide/practices/page-sizes

## Play Console app setup

- [ ] Developer account verification complete
- [ ] Android device verification complete if Play Console requires it for the account
- [ ] Play App Signing enrolled and certificate details reviewed
- [ ] App category set appropriately (recommended: Books & Reference)
- [ ] Store listing uses the reviewed copy in `docs/store_listing_en.md`
- [ ] App icon uploaded
- [ ] Feature graphic uploaded
- [ ] Phone screenshots uploaded from the actual release build
- [ ] Support email is `support@lead-ai.us` and monitored
- [x] Privacy policy is live at `https://lead-ai.us/sitaram/privacy.html`

## App content and policy declarations

Complete each Play Console declaration according to the actual release build:

- [ ] App access
- [ ] Ads declaration
- [ ] Content rating questionnaire
- [ ] Target audience and content
- [ ] Data Safety
- [ ] Privacy policy URL entered in Play Console
- [ ] AI-generated content requirements
- [ ] Any additional declarations shown for the account/app

### AI-specific review

- [x] AI Guide is clearly labeled as educational assistance
- [x] In-app feedback/report control exists
- [ ] Verify feedback/report submission against the production backend
- [ ] Verify unsafe/unsupported requests are handled safely on the production backend
- [ ] Verify the no-evidence path from the Play-installed build
- [x] Store description explains that prompts may be sent to the backend
- [x] Privacy policy describes the current online AI/feedback data flow
- [x] No private provider credential is committed as a reusable server secret

## Testing track

Start with internal testing for release validation.

If this app is being published from a **personal Play developer account created after November 13, 2023**, Google currently requires a closed test with at least **12 opted-in testers for 14 continuous days** before applying for production access.

- [ ] Internal test release installed successfully
- [ ] Core navigation smoke tested from Play-installed build
- [ ] AI endpoint tested from Play-installed build
- [ ] Feedback/report flow tested
- [x] Privacy-policy URL verified publicly reachable
- [ ] Crash-free basic test completed
- [ ] Closed test created if the account is subject to the new-personal-account rule
- [ ] Required testers remain opted in for the full required period
- [ ] Production access application completed if required

Official reference:

- https://support.google.com/googleplay/android-developer/answer/14151465

## Production submission gate

Do not press the final production rollout button until all items below are true:

- [ ] Signed release AAB passed technical checks
- [ ] Store listing matches actual app behavior
- [ ] Data Safety matches actual network/data behavior
- [x] Privacy policy is publicly reachable
- [ ] Required testing is complete
- [ ] Play Console shows no blocking errors
- [ ] Content claims match the generated corpus coverage report
- [ ] Release countries/regions reviewed
- [ ] Release notes reviewed
- [x] Owner authorized professional release engineering and publication work

## Recommended first release notes

> Initial SitaRam release for Ramayana study and research. Includes seven-Kanda navigation, multilingual interface support, transparent corpus coverage status, AI study assistance with source-safety controls, and in-app feedback. Content verification is ongoing, and the app clearly identifies when approved source evidence is unavailable.
