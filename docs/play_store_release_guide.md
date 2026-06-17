# SitaRam — Play Store Release Guide

## App Details
| Field | Value |
|---|---|
| App Name | SitaRam |
| Package ID | com.leadai.sitaram |
| Version Name | 1.0.0 |
| Version Code | 1 |
| Min SDK | flutter.minSdkVersion (API 21) |
| Target SDK | flutter.targetSdkVersion (API 35) |

## Pre-Release Checklist
- [ ] Create a keystore for signing: `keytool -genkey -v -keystore sitaram-release.keystore -alias sitaram -keyalg RSA -keysize 2048 -validity 10000`
- [ ] Add signing config to `android/app/build.gradle.kts` (release block)
- [ ] Store keystore safely — NEVER commit to git
- [ ] Create `android/key.properties` and add to `.gitignore`
- [ ] Set final versionCode and versionName in `pubspec.yaml`
- [ ] Add app icon (1024×1024 PNG) via flutter_launcher_icons package
- [ ] Add splash screen via flutter_native_splash package
- [ ] Run `flutter build appbundle --release`

## Signing Setup (key.properties)
```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=sitaram
storeFile=../sitaram-release.keystore
```

## build.gradle.kts signing config to add
```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## Build Commands
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
AAB Output: `build/app/outputs/bundle/release/app-release.aab`

## Play Console Upload Steps
1. Go to https://play.google.com/console
2. Create new app → App name: SitaRam
3. Default language: English (United States)
4. App or game: App
5. Free or paid: Free
6. Upload AAB to Internal Testing first
7. Fill Store Listing (see store_listing.md)
8. Add Privacy Policy URL (see privacy_policy_draft.md)
9. Complete Content Rating questionnaire (select: Hindu religious content, no violence/mature)
10. Set price: Free
11. Countries: All countries
12. Roll out to Production after internal testing passes
