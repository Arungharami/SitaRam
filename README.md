# SitaRam - Valmiki Ramayana Reader & AI Research App

SitaRam is a premium mobile application designed for clean reading, listening, language study (English/Bangla), and AI-driven scriptural research of the Valmiki Ramayana.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (channel stable)
- [Python 3](https://www.python.org/downloads/) (for the content import pipeline)

### Installation
1. Clone or navigate into the workspace.
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application (supports iOS, Android, macOS, and Web):
   ```bash
   flutter run
   ```

---

## 1. Content Pipeline Guide

The book content is imported and compiled using scripts under `tools/content_import/`.

### How to Add Book Content
1. Place your source Valmiki Ramayana PDF in the `tools/content_import/` directory.
2. From the `tools/content_import/` folder, run the PDF importer:
   ```bash
   python3 import_pdf.py --pdf your_ramayana_source.pdf
   ```
   *This extracts text from the pages and stores them as separate files under `data/pages/page_XXX.json` in `raw_ocr` status.*

### How to Review OCR Content
Because scanned PDFs can produce OCR spelling mistakes, we use a review state system:
1. Run the OCR cleanup script:
   ```bash
   python3 clean_text.py
   ```
   *This cleans page headers, running numbers, and transitions the pages to the `cleaned` state.*
2. Partition the text into chapters:
   ```bash
   python3 split_chapters.py
   ```
   *This aggregates the pages and partitions them into chapter JSON templates: `data/chapters/en_bala_kanda_001.json` etc.*
3. Open the generated chapter files under `data/chapters/` to manually edit the English text, summaries, moral lessons, themes, and characters.
4. Set `"review_status": "approved_for_app"` when a chapter is verified.

### How to Add Bangla Translations & Explanations
1. When you run `split_chapters.py`, matching Bangla chapter templates are generated in the same directory (e.g. `bn_bala_kanda_001.json`).
2. Open these files and edit the following fields:
   - `"chapter_title_bn"`: Title of the chapter in Bengali.
   - `"bangla_summary"`: Bengali summary.
   - `"bangla_explanation"`: Detailed explanation or commentary in Bengali.
3. Once verified, change the status to `"review_status": "approved_for_app"`.
4. Run the exporter to merge English and Bangla data into the final app asset:
   ```bash
   # In development (compiles all draft pages):
   python3 export_json.py
   
   # For production release (compiles ONLY approved pages):
   python3 export_json.py --release
   ```
5. Validate the schema is correct:
   ```bash
   python3 validate_json.py
   ```

### How to Add Audiobook Files
Audiobooks are indexed in the compiled JSON and played in the app's reader page.
1. Place your audiobook MP3 files in the assets folders:
   - English voice tracks: `assets/audio/en/<chapter_id>.mp3`
   - Bangla voice tracks: `assets/audio/bn/<chapter_id>.mp3`
2. Update the audio metadata inside the exporter script (`tools/content_import/export_json.py`) to set `"status": "ready"` and specify the `"duration"` in seconds once files are uploaded.
3. The app's reader audio player will automatically switch from displaying the warning/placeholder banner to displaying the fully functional audio playback controls.

---

## 2. AI Research Upgrade & API Connection

SitaRam includes an AI Research Assistant to help query context-specific moral lessons and character actions.

### How it Works
When a user opens the AI Chat from a chapter, the app automatically constructs a system context prompt including the **Chapter Title**, **Kanda**, **Summary**, **Themes**, **Characters**, **Source Metadata**, and **Selected Passage text**. The prompt commands the AI model to:
- Cite the app's internal chapter title and Kanda.
- Never invent verses or claim exact scriptural wording unless it is present in the attached passage.
- Maintain a respectful tone.

### Connecting the API Key
1. The app runs in **Simulation Mode** by default.
2. To enable live AI, click the **key icon** in the top-right corner of the AI Research screen.
3. Enter your **Gemini API Key** and press **Save**. The key is stored locally on the device via `SharedPreferences`.
4. To remove or replace the key, reopen the settings dialog and click **Delete Key**.

---

## 3. Preparing iOS & Android Release

Before publishing, ensure all chapters are compiled in release mode (filtering out unapproved drafts):
```bash
cd tools/content_import
python3 export_json.py --release
python3 validate_json.py
```

### Android Release Setup
1. **Config App Signing**: Create a keystore and add signing configurations in `android/key.properties` and configure `android/app/build.gradle`.
2. **Review Permissions**: Check `android/app/src/main/AndroidManifest.xml`. Ensure only necessary permissions (like Internet access for streaming) are declared.
3. **Build App Bundle (AAB)**:
   ```bash
   flutter build appbundle --release
   ```
4. Upload the generated `.aab` file from `build/app/outputs/bundle/release/` to the Google Play Console.

### iOS Release Setup
1. **Xcode Configuration**: Open the `ios/` folder in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. **Setup Signing & Capabilities**: Select the Runner target, go to **Signing & Capabilities**, select your developer team, and let Xcode manage provisioning profiles.
3. **App Store Connect Metadata**: Add app icons and configure release versions.
4. **Build iOS Archive**:
   ```bash
   flutter build ipa --release
   ```
5. Distribute the archive to App Store Connect / TestFlight through Xcode or Transporter.
