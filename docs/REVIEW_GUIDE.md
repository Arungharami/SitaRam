# SitaRam — Admin Review & Golden Dataset Guide

This document describes the admin feedback review process to improve model alignment and dataset quality.

## Admin Review Process

1. **Feedback Collection**:
   - Thumbs up/down ratings and reported reasons (incorrect citation, translation problem, safety concern) from the app are added to a pending review queue.

2. **Manual Inspection**:
   - The admin reviews the query, retrieved passages, AI answer, and user comments.

3. **Database Correction**:
   - Confirmed dataset errors are corrected in the `data/records` json files.
   - Sarga texts or translations are cleaned and re-exported.

4. **Golden Evaluation Dataset**:
   - Severe model failures are logged as evaluation test records.
   - These are added to `evaluation_dataset.json` for validation in future releases.
