# SitaRam — Valmiki Ramayana Study & AI Research App

SitaRam is an open-source Flutter application for respectful Ramayana study, source review, multilingual reading workflows, and evidence-grounded AI assistance.

> **Content status matters:** SitaRam does not treat imported text as verified scripture automatically. The committed coverage report is the source of truth for what has been imported, human-verified, approved for the app, and approved for AI retrieval.

## Current project status

- Android package: `com.leadai.sitaram`
- Flutter app with English, Bangla, and Spanish UI support
- Seven-Kanda navigation structure
- Corpus validation and provenance gates
- AI Guide with no-evidence behavior and citation safeguards
- In-app AI feedback/reporting flow
- Signed Android App Bundle release workflow for Google Play internal testing
- Google Play release runbook and policy checklist

The current committed corpus is **not complete**. Do not advertise SitaRam as a complete or fully verified Valmiki Ramayana edition until `assets/content/coverage_report.json` reports that status.

## Trust model

SitaRam separates four states that must not be confused:

1. **Imported** — a record exists in the corpus.
2. **Human-verified** — source text has been checked against the registered edition.
3. **Approved for app** — the record may be shown as approved content in the mobile app.
4. **Approved for retrieval** — the record may be used as grounding evidence by the AI system.

Unverified or placeholder records are excluded from trusted AI retrieval. When approved evidence is unavailable, the AI Guide is expected to return a clear no-evidence response instead of inventing scripture, quotations, verse numbers, or citations.

## Architecture

### Flutter mobile app

The client provides the reading/study interface, language controls, corpus coverage status, AI Guide, citations, and feedback controls.

### FastAPI AI backend

The backend under `huggingface_space/` provides health, coverage, search, ask, citation-verification, and feedback endpoints. Production deployments must use HTTPS and owner-managed configuration. Secrets and signing credentials must never be committed to the repository.

### Corpus pipeline

Content tools under `tools/` handle source registration, segmentation, normalization, schema generation, validation, indexing, and export. Shared eligibility rules prevent a simple status edit from promoting unverified text into trusted app or retrieval content.

## Validate the corpus

Run the master validation suite before any content release:

```bash
python tools/validation/run_all.py
python tools/validation/test_corpus_validation.py
python tools/validation/verify_text_integrity.py --baseline <trusted-baseline-ref>
python tools/content_import/validate_json.py
```

For pull requests targeting `main`, use `origin/main` as the trusted baseline after fetching the full branch history.

Then inspect:

```text
assets/content/coverage_report.json
```

Store-listing and marketing claims must match that generated report.

## Run the Flutter app

```bash
flutter pub get
flutter analyze
flutter test
flutter run \
  --dart-define=SITARAM_HF_ENDPOINT=https://YOUR-HTTPS-ENDPOINT \
  --dart-define=SITARAM_HF_APP_KEY=YOUR-APP-TOKEN
```

The client token is an application access control, not a substitute for server-side abuse protection. Production backends should also use rate limiting, monitoring, and least-privilege infrastructure credentials.

## Google Play release

The repository includes a manually triggered workflow:

```text
.github/workflows/android-release-candidate.yml
```

It can:

- run Flutter analysis and tests;
- restore the upload keystore from GitHub Actions secrets;
- build a signed AAB;
- record the AAB SHA-256 checksum;
- retain the release artifact;
- optionally upload a **draft** release to Google Play internal testing.

Release guidance:

- `docs/PLAY_STORE_RELEASE_RUNBOOK.md`
- `docs/PLAY_PRODUCTION_CHECKLIST_2026.md`
- `docs/store_listing_en.md`
- `docs/privacy_policy_draft.md`

Production rollout remains an explicit account-owner action after testing, policy declarations, and store review are complete.

## Content contribution rules

Contributions that add or modify Ramayana content must preserve source provenance and pass the corpus validation gates. Do not:

- invent missing scripture text;
- fabricate reviewer names or approval dates;
- attribute text to a translator without source evidence;
- mark placeholder content as verified;
- add unverified passages to retrieval indexes;
- make completeness claims unsupported by the generated coverage report.

## AI safety principles

SitaRam AI is an educational study assistant, not a religious authority. The system is designed to:

- prefer source-grounded answers;
- expose citations only for approved passages;
- label AI interpretation;
- refuse unsupported or unsafe requests;
- allow users to report incorrect or inappropriate AI output;
- return no-evidence responses when trusted source material is unavailable.

## Contributing

Pull requests are welcome. Keep changes focused, run the relevant Flutter/backend/corpus tests, and explain any content provenance or release impact in the PR description.

**Jai Shri Ram**
