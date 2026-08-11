# SitaRam — Google Play Data Safety Draft

**Package:** `com.leadai.sitaram`  
**Prepared:** August 10, 2026  
**Canonical privacy policy:** https://lead-ai.us/sitaram/privacy.html

This is a submission aid based on the current SitaRam source code and privacy architecture. Re-check it against the actual production backend and every SDK in the signed AAB before submitting the Play Console form.

## Current app architecture relevant to Data Safety

The Flutter client currently uses standard UI/localization packages plus `shared_preferences`, `http`, `just_audio`, and Google Fonts. It does not currently include an advertising SDK, account/authentication SDK, Firebase Analytics, Crashlytics, precise-location SDK, contacts SDK, camera SDK, or microphone SDK in `pubspec.yaml`.

The Android manifest requests `INTERNET` so the optional AI Guide and feedback/report flows can communicate with the configured SitaRam backend.

## Recommended form posture

### Does the app collect or share required user data?

**Yes — declare collection for the online AI/feedback flows.**

Google Play treats transmitting user data off the device as collection, even when it is transmitted for app functionality. Do not answer “no data collected” while the AI Guide or feedback feature sends user-entered content to a backend.

### Data type: Messages → Other in-app messages

Use this for user-entered AI chat questions if Play Console presents this category for conversational prompt content.

Suggested answers:

- **Collected:** Yes
- **Shared:** Confirm against the production provider relationship before submission. Do not guess.
- **Ephemeral processing:** Mark only if the production backend/provider truly retains the prompt only in memory for the real-time request. Current privacy wording allows limited operational logs, so do not claim ephemeral-only processing unless production logging proves it.
- **Required or optional:** Optional — users can use the reader without sending an AI question.
- **Purpose:** App functionality
- **Encrypted in transit:** Yes, but only after `SITARAM_HF_ENDPOINT` is configured to the verified production HTTPS endpoint.

### Data type: App activity → Other user-generated content

Use this for optional free-text feedback/report comments if Play Console categorization matches the final implementation.

Suggested answers:

- **Collected:** Yes when the user submits feedback
- **Required or optional:** Optional
- **Purpose:** App functionality; safety/quality improvement where applicable
- **Encrypted in transit:** Yes when sent to the production HTTPS backend

### Data type: App activity → Other actions

The AI feedback flow also transmits user-selected report/rating/reason choices. If Play Console treats those selections as user activity rather than user-generated text, disclose them here.

Suggested answers:

- **Collected:** Yes when the user submits feedback/reporting
- **Required or optional:** Optional
- **Purpose:** App functionality and safety/quality moderation

## Data types not currently evidenced by the app source

Do not declare these as collected unless the signed build, production backend, hosting provider, or an SDK actually collects them:

- precise or approximate location
- contacts
- photos/videos
- microphone/voice recordings
- financial/payment data
- health/fitness data
- advertising ID
- account/user ID
- address book

The absence of a permission alone is not enough to conclude that a third-party SDK collects nothing. Re-audit the final dependency graph and production provider configuration before submission.

## Data sharing

Whether sending prompt/feedback data to a hosting or AI provider counts as “sharing” in the Play form depends on the provider relationship and applicable Play definitions/exemptions. Confirm the production processor/provider terms before selecting the answer. Do not mark “not shared” solely because the transfer is server-to-server.

## Security practices

Target answers after production configuration is verified:

- **Data encrypted in transit:** Yes — production app/backend traffic must use HTTPS.
- **Deletion request mechanism:** `support@lead-ai.us` can receive privacy/deletion requests. Only claim the Play deletion badge if the production system can honor the request for data that can be identified and is not already automatically deleted/anonymized.
- **Independent security review:** Do not claim unless a qualifying review has actually been completed.

## Ads

Current release source does not contain an advertising SDK. The Play Ads declaration should be **No ads** unless the signed production build changes.

## App access

Current app experience does not require a user account or login. If that remains true in the signed build, Play review should not require test login credentials.

## AI policy consistency

The app includes an in-app feedback/report mechanism for AI responses. Verify the production submission path works end-to-end before release. The store listing and privacy policy must continue to disclose that AI questions can be sent to the backend.

## Final verification before submitting Data Safety

- [ ] Review signed AAB dependencies/SDKs
- [ ] Verify production backend logging/retention
- [ ] Verify hosting/model-provider processing terms
- [ ] Verify HTTPS endpoint
- [ ] Verify AI feedback/report submission
- [ ] Confirm no ads SDK was introduced
- [ ] Confirm no account/auth flow was introduced
- [ ] Match Play answers to the live privacy policy
- [ ] Re-submit Data Safety whenever production data practices change

## Official Google Play reference

- https://support.google.com/googleplay/android-developer/answer/10787469
- https://support.google.com/googleplay/android-developer/answer/13985936
