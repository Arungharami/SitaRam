# SitaRam Production Release Checklist

Use this checklist to prepare and build the SitaRam application for Google Play Store and Apple App Store.

---

## 1. Pre-Release Ingestion Compilation

Before compiling the application binary, ensure only approved chapters are packaged in the assets bundle:

1. Clean the ingestion folder and run the exporter in release mode:
   ```bash
   cd tools/content_import/
   python3 export_json.py --release
   ```
2. Validate the exported schema to prevent runtime parsing crashes:
   ```bash
   python3 validate_json.py
   ```

---

## 2. Android Release Steps

### A. Signing Configuration
1. Generate an upload keystore file (if not already done):
   ```bash
   keytool -genkey -v -keystore ~/sitaram-upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create a file named `android/key.properties` containing the keystore paths and credentials:
   ```properties
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=/Users/username/sitaram-upload-keystore.jks
   ```
3. Verify that `android/app/build.gradle` is configured to read the `key.properties` file and apply the signing settings to the release build.

### B. Compile Build
1. Clean and fetch packages:
   ```bash
   flutter clean
   ```
2. Build Android App Bundle (AAB):
   ```bash
   flutter build appbundle --release
   ```
3. The compiled binary will be located at:
   `build/app/outputs/bundle/release/app-release.aab`
4. Upload this file to the Google Play Console for internal testing or production tracks.

---

## 3. iOS Release Steps

### A. Signing Configuration
1. Open the project's iOS folder in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In the project sidebar, select **Runner** (top node).
3. Under the **Signing & Capabilities** tab:
   - Select your developer team under **Team**.
   - Ensure **Automatically manage signing** is checked.
   - Xcode will generate signing certificates and provisioning profiles automatically.

### B. Build and Distribute
1. Build the iOS App Store Archive (IPA) via terminal:
   ```bash
   flutter build ipa --release
   ```
2. Open the Xcode Organizer:
   - Go to **Product > Archive**.
   - Click **Distribute App** to upload the build to App Store Connect / TestFlight.
3. Once processed in App Store Connect, invite native reviewers and release to the App Store.
