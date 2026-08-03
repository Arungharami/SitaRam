# SitaRam — Testing & Evaluation Guide

This guide describes the tests implemented for validating the Flutter mobile app and Python RAG pipeline.

## Run All Corpus Validation

Runs every check below and exits non-zero if any fails:
```bash
python tools/validation/run_all.py
```

## Run Individual Ingestion Checks
```bash
# everything at once
python tools/validation/run_all.py

# individually
python tools/validation/validate_schema.py
python tools/validation/check_duplicates.py
python tools/validation/check_numbering.py
python tools/validation/check_provenance.py
python tools/validation/check_placeholder_text.py
python tools/validation/check_language_support.py
python tools/validation/check_review_gate.py
```

| Check | What it enforces |
| --- | --- |
| `validate_schema.py` | Required keys plus value correctness: canonical Kanda IDs, Sarga range, stable `documentId`, correct `kandaOrder`, known review status |
| `check_duplicates.py` | No duplicate `documentId`, Kanda/Sarga pair, or identical `sourceText` |
| `check_numbering.py` | Sarga numbering is sequential, in canonical range, with correct Kanda ordering |
| `check_provenance.py` | Edition, translator, copyright, and source URL present; approved records carry real reviewer attribution |
| `check_placeholder_text.py` | No empty, bootstrap-stub, or stub-length text is marked approved; no translation copied from English |
| `check_language_support.py` | Only supported language codes are claimed |
| `check_review_gate.py` | Declared approval status is actually backed by real text, provenance, and a named reviewer |

## Run Validation Rule Tests
```bash
python tools/validation/test_corpus_validation.py
```

## Regenerate the Coverage Report

The coverage report is **generated, never hand-edited**. Counts are derived from
records that actually pass validation, not from what a record's `review.status`
claims about itself.
```bash
python tools/validation/generate_coverage_report.py
```

## Run Backend Tests
Includes the retrieval trust gate that keeps unverified passages out of the AI corpus:
```bash
cd huggingface_space
python -m unittest test_backend
```

## Run Flutter Tests
Verify compilation and localization logic:
```bash
flutter analyze
flutter test
```

## Trust Model

A record is only usable as verified scripture when it satisfies *all* of:

1. `review.status` is `approved_for_retrieval` (retrieval) or `approved_for_app` (app),
2. its text is real segmented source text — not empty, not a bootstrap placeholder, not stub-length,
3. it carries complete edition provenance, and
4. it names a human reviewer with a review date.

These rules live in one place, `tools/validation/corpus_rules.py`, and are imported by
the validators, the indexers, the exporters, and the coverage report generator. A record
cannot promote itself simply by having its status field edited.

## Real-source ingestion tests

```bash
python tools/validation/test_ingestion.py        # 40 tests
python tools/validation/check_passages.py
python tools/validation/check_source_registry.py
```

`test_ingestion.py` proves both directions of the gate:

- **blocked**: placeholder text, missing provenance, missing or fake reviewer,
  invalid and reversed page ranges, missing checksum, unregistered edition,
  imported-only, verified-but-not-retrieval-approved, and trust flags forged
  without an audit trail;
- **allowed**: a correctly human-approved synthetic fixture becomes retrieval
  eligible, retrieval approval alone is not app approval, and revocation removes
  eligibility while preserving history.

Approval tests use synthetic fixtures only. One test asserts the real imported
Dutt passage is still `imported` with an empty `approvalHistory` and that both
generated indexes are empty, so no automated run can quietly approve scripture.

## Backend security tests

```bash
cd huggingface_space
SITARAM_ALLOW_INSECURE_TEST_KEY=1 python -m unittest test_backend
```

Includes fail-closed tests: the service refuses to start without
`SITARAM_APP_KEY`, refuses blank and short keys, refuses the test key unless
`SITARAM_ALLOW_INSECURE_TEST_KEY=1`, and no endpoint echoes the key.
