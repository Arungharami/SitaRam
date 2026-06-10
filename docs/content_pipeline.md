# SitaRam Content Ingestion & Import Pipeline

This document outlines the professional content ingestion workflow to import, OCR, clean, translate, and validate Valmiki Ramayana book chapters for the SitaRam app.

---

## 1. Content Pipeline Overview

Every page of text imported into the app must transition through a multi-stage verification pipeline before being compiled into production releases. This protects the app from uncorrected OCR typos, broken translations, or copyright infringements.

```
[PDF/Scanned Pages] 
       │
       ▼
 1. import_pdf.py (Status: raw_ocr)
       │
       ▼
 2. ocr_pipeline.py (Simulated or Local spelling corrections)
       │
       ▼
 3. clean_text.py (Status: cleaned - Strips page headers/numbers)
       │
       ▼
 4. split_chapters.py (Status: needs_review / needs_native_review)
       │
       ▼
 5. Manual Verification & Translation (Editors review chapters)
       │
       ▼
 6. export_json.py (Status: approved_for_app - Compiles final asset)
       │
       ▼
 7. validate_json.py (Ensures schema integrity)
```

---

## 2. Ingestion Review Statuses

We enforce 6 distinct review states for quality control:

1. **`placeholder`**: The chapter has been registered in the database index, but full text is not yet imported. The reader will show summaries or stubs until text is verified.
2. **`raw_ocr`**: The text was extracted directly from the scanned PDF/images. It may contain spelling errors, hyphenations, and line breaks.
3. **`cleaned`**: Running headers (e.g. "VALMIKI RAMAYANA"), footers, and page numbers have been stripped by automated regex scripts.
4. **`needs_review`**: Chapter text is segmented but has not been read by an English language editor.
5. **`reviewed`**: The chapter content has been verified by a reviewer for typos and readability.
6. **`approved_for_app`**: Fully signed off. Ready for the compiled production asset.

---

## 3. Formatting Rules

To keep the reader UI premium:
- **No Line Breaks Inside Verses**: Clean up hyphenations caused by page transitions.
- **No Page Numbers**: Ensure scripts in `clean_text.py` remove page labels like `[PAGE 12]` or standalone numbers.
- **Natural Paragraphs**: Spacing between paragraphs must be standardized to a single blank line (`\n\n`).
- **Bangla Readability**: Bengali translations and commentaries must use traditional phrasing, avoiding direct machine translations.

---

## 4. Audiobook Audio Files Ingestion

Audio file records are declared in the chapter database:
- Path: `assets/audio/en/<chapter_id>.mp3` (English narrations)
- Path: `assets/audio/bn/<chapter_id>.mp3` (Bangla explanations)

When new audio files are recorded and placed in the folders, update the `export_json.py` pipeline mapping:
1. Set the `"status"` field from `"placeholder"` to `"ready"`.
2. Enter the exact `"duration"` of the audio track in seconds.
3. Re-run `export_json.py` to rebuild the asset JSON.
