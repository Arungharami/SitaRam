# SitaRam Production Release Secrets Setup

This document covers the credentials that must remain outside source control before SitaRam can be signed and published through GitHub Actions.

## Security rule

**Never paste keystore passwords, application keys, Hugging Face tokens, or Google Play service-account JSON into commits, issues, pull requests, screenshots, or chat.** Enter them only into the intended GitHub/Hugging Face secret interfaces.

## 1. Identify the correct Google Play certificate

Google Play App Signing uses two distinct keys:

- **Upload key** — held by the developer and used to sign the `.aab` before upload.
- **App signing key** — held by Google Play and used to sign the APKs delivered to users.

For CI signing, use the SHA-256 shown specifically under **Upload key certificate** in Google Play Console. Do not use the App signing key certificate fingerprint for the local upload keystore check.

Play Console path:

`SitaRam → App integrity / Play app signing → Upload key certificate`

Copy the **SHA-256 certificate fingerprint** exactly and store it as the GitHub Actions secret:

```text
ANDROID_UPLOAD_CERT_SHA256
```

The SHA-1 value is useful for some integrations but is not used by the release workflow's signing verification.

On the computer that contains the existing SitaRam upload keystore, verify it locally:

```bash
keytool -list -v -keystore /secure/path/to/sitaram-upload-keystore.jks -alias YOUR_ALIAS
```

The SHA-256 printed by `keytool` must match Google Play's **Upload key certificate SHA-256**.

**If it does not match, stop. Do not create or substitute another key merely to make CI pass.** If Play App Signing is enabled and the original upload key is lost, use Google Play's upload-key reset process.

## 2. GitHub Actions secrets

Open:

`Arungharami/SitaRam` → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Configure these repository secrets:

| Secret | Required value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64 of the verified SitaRam upload `.jks` file |
| `ANDROID_KEY_ALIAS` | Alias inside that SitaRam keystore |
| `ANDROID_KEY_PASSWORD` | Password for the upload key entry |
| `ANDROID_STORE_PASSWORD` | Password for the keystore |
| `ANDROID_UPLOAD_CERT_SHA256` | SHA-256 from Play Console's **Upload key certificate** section |
| `SITARAM_HF_ENDPOINT` | Production SitaRam backend HTTPS endpoint |
| `SITARAM_HF_APP_KEY` | App-to-backend access token matching the backend `SITARAM_APP_KEY` secret |
| `PLAY_SERVICE_ACCOUNT_JSON` | Full JSON for the Google Play publishing service account authorized for `com.leadai.sitaram` |

### Base64 the keystore locally

macOS:

```bash
base64 -i /secure/path/to/sitaram-upload-keystore.jks | pbcopy
```

Linux:

```bash
base64 -w 0 /secure/path/to/sitaram-upload-keystore.jks
```

Windows PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\secure\path\sitaram-upload-keystore.jks")) | Set-Clipboard
```

Paste that output only into `ANDROID_KEYSTORE_BASE64` in GitHub Actions secrets.

## 3. Backend secret

The production SitaRam backend must have a deployment secret named:

```text
SITARAM_APP_KEY
```

Its value must match the GitHub Actions secret `SITARAM_HF_APP_KEY` used to compile the production client.

Do not put this value in the repository. The hardened backend intentionally fails closed when `SITARAM_APP_KEY` is absent.

The client endpoint stored in `SITARAM_HF_ENDPOINT` must be HTTPS and must point to the production SitaRam backend, not a local, preview, or placeholder URL.

## 4. Google Play service account

Use a dedicated Google Cloud service account with the minimum Google Play Console permissions required to upload/manage releases for only `com.leadai.sitaram` where possible.

Store the entire service-account JSON document as the GitHub Actions secret:

```text
PLAY_SERVICE_ACCOUNT_JSON
```

Never commit the JSON key file.

## 5. Privacy-policy URL

The production privacy policy is live at:

```text
https://lead-ai.us/sitaram/privacy.html
```

Use that exact URL in Google Play Console.

## 6. Release after secrets are configured

The normal production workflow is:

```text
.github/workflows/android-release-candidate.yml
```

A signed release should proceed only after:

1. the local upload keystore SHA-256 matches Google Play's **Upload key certificate SHA-256**;
2. all required GitHub Actions secrets above exist;
3. the production backend is healthy and has `SITARAM_APP_KEY` configured;
4. the API 36 release build passes tests;
5. the generated AAB passes Google Play technical validation, including 16 KB page-size requirements;
6. store listing, Data Safety, content rating, AI-related declarations, and required testing are complete.

## 7. Google references

- Play App Signing / upload-key concepts and reset flow: https://support.google.com/googleplay/android-developer/answer/9842756
- Android Studio signing setup: https://developer.android.com/studio/publish/app-signing
