# SitaRam — Testing & Evaluation Guide

This guide describes the tests implemented for validating the Flutter mobile app and Python RAG pipeline.

## Run Ingestion Tests
Verify that all records conform to the schema:
```bash
python tools/validation/validate_schema.py
python tools/validation/check_duplicates.py
python tools/validation/check_numbering.py
python tools/validation/check_provenance.py
```

## Run Flutter Tests
Verify compilation and localization logic:
```bash
flutter analyze
flutter test
```
