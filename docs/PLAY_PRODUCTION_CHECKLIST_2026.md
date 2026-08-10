# SitaRam Google Play Production Checklist — 2026

**Prepared:** August 10, 2026  
**Package:** `com.leadai.sitaram`  
**Current app version:** `1.0.0+1`  
**Current target SDK:** API 35  
**Primary release path:** signed AAB → internal/closed testing → production

## Current repository state

- [x] PR #3 release automation merged
- [x] PR #4 corpus verification gates and Flutter compile fixes merged
- [x] `flutter analyze` passed on the PR #4 validation environment
- [x] `flutter test` passed on the PR #4 validation environment
- [x] Google Play release candidate workflow exists
- [x] Package name in workflow and Android project is `com.leadai.sitaram`
- [x] Public release copy has been rewritten to avoid unsupported completeness claims
- [x] Privacy materials describe the current backend AI architecture
- [x] Simulated donation flow removed from production Settings navigation

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

A production build may expose the verification status and no-evidence behavior, but the owner should decide whether the present content depth provides enough user value for a public launch.

## Android release gate

Before uploading a new release candidate:

- [ ] Confirm `versionCode` has never been used in Play Console
- [ ] Confirm the upload keystore matches the intended Play upload certificate
- [ ] Confirm GitHub Actions signing secrets are present
- [ ] Confirm `SITARAM_HF_ENDPOINT` is the production HTTPS endpoint
- [ ] Confirm the backend does not use a committed fallback application key
- [ ] Confirm backend rate limiting / abuse controls are active
- [ ] Run the Android Release Candidate workflow with Play upload disabled
- [ ] Download and record the AAB SHA-256 checksum
- [ ] Smoke test the resulting build on a physical Android device

## Target API deadline

The project currently targets Android 15 / API 35.

Google Play's published schedule says that beginning **August 31, 2026**, new apps and app updates for standard Android mobile apps must target **Android 16 / API 36 or higher**.

Because this checklist was prepared on August 10, 2026, API 35 is still within the submission window today, but the professional path is to migrate, build, and test API 36 before the August 31 deadline rather than depend on a last-minute submission.

Official reference:

- https://support.google.com/googleplay/android-developer/answer/11926878

## Play Console app setup

- [ ] Developer account verification complete
- [ ] Android device verification complete if Play Console requires it for the account
- [ ] Play App Signing enrolled and certificate details reviewed
- [ ] App category set appropriately (recommended: Books & Reference)
- [ ] Store listing uses the reviewed copy in `docs/store_listing_en.md`
- [ ] App icon uploaded
- [ ] Feature graphic uploaded
- [ ] Phone screenshots uploaded from the actual release build
- [ ] Support email is current and monitored
- [ ] Privacy policy URL points to the published `docs/privacy.html` page (or another canonical hosted policy)

## App content and policy declarations

Complete each Play Console declaration according to the actual release build:

- [ ] App access
- [ ] Ads declaration
- [ ] Content rating questionnaire
- [ ] Target audience and content
- [ ] Data Safety
- [ ] Privacy policy
- [ ] AI-generated content requirements
- [ ] Any additional declarations shown for the account/app

### AI-specific review

- [ ] AI Guide is clearly labeled as educational assistance
- [ ] In-app feedback/report control works
- [ ] Unsafe/unsupported requests are handled safely
- [ ] No-evidence path works when no approved passage is available
- [ ] Store description explains that prompts are sent to the backend
- [ ] Privacy policy matches the actual production hosting/model provider
- [ ] No private provider credential is embedded as a reusable server secret in the app bundle

Google Play's AI-generated content guidance requires developers to prevent prohibited AI output and provide appropriate safeguards and user feedback mechanisms for covered generative-AI experiences.

Official reference:

- https://support.google.com/googleplay/android-developer/answer/14094294

## Testing track

Start with internal testing for release validation.

If this app is being published from a **personal Play developer account created after November 13, 2023**, Google currently requires a closed test with at least **12 opted-in testers for 14 continuous days** before applying for production access.

- [ ] Internal test release installed successfully
- [ ] Core navigation smoke tested
- [ ] AI endpoint tested from the Play-installed build
- [ ] Feedback/report flow tested
- [ ] Privacy policy link verified
- [ ] Crash-free basic test completed
- [ ] Closed test created if the account is subject to the new-personal-account rule
- [ ] Required testers remain opted in for the full required period
- [ ] Production access application completed if required

Official reference:

- https://support.google.com/googleplay/android-developer/answer/14151465

## Production submission gate

Do not press the final production rollout button until all items below are true:

- [ ] Release AAB passed technical checks
- [ ] Store listing matches actual app behavior
- [ ] Data Safety matches actual network/data behavior
- [ ] Privacy policy is publicly reachable
- [ ] Required testing is complete
- [ ] Play Console shows no blocking errors
- [ ] Content claims match the generated corpus coverage report
- [ ] Owner has reviewed the rollout countries/regions
- [ ] Owner has reviewed release notes
- [ ] Owner explicitly approves production publication

## Recommended first release notes

> Initial SitaRam release for Ramayana study and research. Includes seven-Kanda navigation, multilingual interface support, transparent corpus coverage status, AI study assistance with source-safety controls, and in-app feedback. Content verification is ongoing, and the app clearly identifies when approved source evidence is unavailable.
