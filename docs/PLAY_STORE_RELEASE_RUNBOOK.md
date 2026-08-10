# SitaRam Google Play Release Runbook

## Current release identity

- App name: **SitaRam**
- Android application ID: `com.leadai.sitaram`
- Target SDK: **Android 16 / API 36**
- Release artifact: `build/app/outputs/bundle/release/app-release.aab`
- Distribution format: Android App Bundle
- First release path: internal testing before production

## Responsibility split

### Claude/GitHub cloud worker can

- run Flutter analysis and tests;
- build the signed AAB using encrypted repository secrets;
- calculate the artifact checksum;
- retain the release candidate as a GitHub Actions artifact;
- upload the AAB to Google Play internal testing as a draft after service-account access is configured;
- prepare release notes and technical evidence;
- identify policy or quality blockers.

### Account owner must

- complete Google Play developer/organization verification;
- accept Play App Signing and legal declarations;
- create and authorize a Google Cloud service account for this app;
- confirm the upload certificate and signing setup;
- complete App content, Data Safety, privacy-policy, content-rating, and generative-AI declarations truthfully;
- review internal testing results;
- approve production rollout.

## Repository secrets required

Add these under **GitHub repository → Settings → Secrets and variables → Actions**.

| Secret | Purpose |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64 representation of the upload keystore |
| `ANDROID_KEY_ALIAS` | Upload-key alias |
| `ANDROID_KEY_PASSWORD` | Upload-key password |
| `ANDROID_STORE_PASSWORD` | Keystore password |
| `SITARAM_HF_ENDPOINT` | Production HTTPS FastAPI/Hugging Face endpoint |
| `SITARAM_HF_APP_KEY` | Current backend application token |
| `PLAY_SERVICE_ACCOUNT_JSON` | Entire authorized Google Play service-account JSON document |

Do not paste secret values into issues, commits, pull requests, chat messages, or screenshots.

## Encode the keystore locally

### macOS

```bash
base64 -i /secure/path/sitaram-upload-keystore.jks | pbcopy
```

### Linux

```bash
base64 -w 0 /secure/path/sitaram-upload-keystore.jks
```

### Windows PowerShell

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\secure\sitaram-upload-keystore.jks")) | Set-Clipboard
```

Place the resulting value only in the `ANDROID_KEYSTORE_BASE64` GitHub secret.

## Google Play service-account setup

1. Open Play Console using the verified organization owner account.
2. Open **Users and permissions** and connect or select the Google Cloud project used for Play publishing.
3. Create a dedicated service account for SitaRam release automation.
4. Grant only the minimum app-level permissions needed to create and manage releases for `com.leadai.sitaram`.
5. Create a JSON key for the service account and store the complete JSON in `PLAY_SERVICE_ACCOUNT_JSON`.
6. Never commit or email the JSON key.

Use a dedicated release account rather than a personal broad-access credential.

## Run the cloud release workflow

1. Open the repository’s **Actions** tab.
2. Select **Android Release Candidate**.
3. Select **Run workflow**.
4. Keep `upload_to_internal_testing` disabled for the first validation run.
5. Download the generated `sitaram-android-release-candidate` artifact.
6. Confirm the AAB checksum and install/test through an internal testing release.
7. After the build is proven, run the workflow with internal upload enabled.

The automated upload uses `status: draft`. Review and submit the draft in Play Console rather than allowing an unattended production release.

## Required Play Console sections

Complete each section based on the actual app behavior:

- Store listing
- App access
- Ads declaration
- Content rating
- Target audience and content
- News-app declaration, if shown and applicable
- Data Safety
- Privacy policy
- Government-app declaration, if shown and applicable
- Financial-features declaration, if shown and applicable
- Health-app declaration, if shown and applicable
- Generative-AI content/reporting requirements
- Testing and release tracks

Do not choose declarations merely to pass review. The answers must match the shipping build and backend.

## AI and privacy release checks

Before submission, verify:

- user questions are transmitted only over HTTPS;
- the privacy policy explains that questions may be processed by the SitaRam backend and configured AI provider;
- the app provides a visible mechanism to report inappropriate or incorrect AI content;
- the backend does not log unnecessary personal data;
- citations link to actual approved passages;
- the app distinguishes scripture text, translation, summary, and AI interpretation;
- no API provider key exists inside the app bundle;
- unsupported questions return a no-evidence response rather than invented content.

## Corpus-claim release check

Open `assets/content/coverage_report.json` and compare every store-listing claim against it. Do not use phrases such as “complete Valmiki Ramayana,” “all 645 Sargas,” or “fully verified multilingual edition” until the generated report supports those claims.

## Target API requirement

The release branch targets **Android 16 / API level 36**. Google Play requires standard new Android apps and updates to target API 36 or higher beginning August 31, 2026. Keeping API 36 in the first production release avoids a near-term resubmission solely for target-SDK compliance.

## 16 KB page-size compatibility

Google Play requires new apps and updates targeting Android 15/API 35 or higher to support 16 KB memory page sizes. SitaRam uses Flutter and therefore ships native libraries, so validate the generated Play AAB rather than assuming compatibility.

- The project uses Android Gradle Plugin 9.0.1, which is newer than the Android guidance minimum of AGP 8.5.1 for correct 16 KB zip alignment.
- Use the actual release AAB generated by the release workflow for final compatibility validation.
- Confirm Play Console reports no 16 KB page-size compatibility blocker before promotion.
- When possible, smoke test the release on a 16 KB Android 15/16 emulator or supported physical device.

## Internal testing acceptance checklist

- [ ] GitHub workflow succeeds
- [ ] AAB checksum recorded
- [ ] Upload certificate matches the intended new upload key
- [ ] Version code is unique and increasing
- [ ] Play Console shows no 16 KB page-size compatibility blocker
- [ ] App starts on a physical Android device
- [ ] All seven Kanda navigation entries behave correctly
- [ ] Available Sargas open without crashes
- [ ] Search works on approved content
- [ ] AI endpoint health check succeeds
- [ ] Grounded answer contains valid citations
- [ ] No-evidence behavior works
- [ ] Offline fallback is clearly labeled
- [ ] Feedback/report control works
- [ ] Privacy-policy link opens
- [ ] No debug endpoint or debug label appears
- [ ] Accessibility and text scaling receive a basic smoke test
- [ ] At least one tester completes the core reading and question-answer flow

## Production promotion gate

Promote only after:

1. internal testing is successful;
2. all required policy declarations are complete;
3. store listing claims match actual corpus coverage;
4. crash and backend-health evidence is acceptable;
5. the owner explicitly approves the rollout percentage and release notes.

Production publication is an owner decision, not an autonomous agent action.
