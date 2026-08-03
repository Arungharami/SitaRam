# SitaRam — Source Ingestion & Human Review

How real public-domain scripture enters SitaRam, and why nothing reaches the AI
or the app until a named person has checked it against the printed page.

## The rule this whole pipeline exists to enforce

**No text is treated as scripture until a human has compared it to the source.**

Automation may download, checksum, extract, segment, and present. It may not
decide that text is faithful. That decision is a person's, it is recorded with
their name, and it is auditable afterwards.

## Trust states

```
imported ──► needs_review ──► text_verified ──► approved_for_retrieval ──► approved_for_app
    │             │                 │                     │                        │
    └─────────────┴─────────────────┴─────────► rejected ◄┴────────────────────────┘
```

A record cannot skip a state. `imported → text_verified` is refused; it must
pass through `needs_review`. Approval is revocable: `revoke-retrieval` drops a
passage back to `text_verified` and it leaves the indexes on the next rebuild.

| State | Meaning | In search/embeddings? | In app as verified? |
| --- | --- | --- | --- |
| `imported` | extracted from source, untouched by human eyes | no | no |
| `needs_review` | queued for a reviewer | no | no |
| `text_verified` | a human confirmed it matches the printed page | no | no |
| `approved_for_retrieval` | cleared as AI grounding evidence | **yes** | no |
| `approved_for_app` | cleared to ship as verified scripture | **yes** | **yes** |
| `rejected` | failed review | no | no |

Trust is computed, never merely declared. Even at `approved_for_retrieval`, a
passage is withheld unless it *also* has real non-placeholder text, a verified
source checksum, a valid page range, complete provenance, a named accountable
reviewer, and a non-empty audit history. Hand-editing the booleans does not
work — see the `test_flags_forged_without_history_are_blocked` test.

## Reproducing the sample import

The registered source is not committed: it is a 3.4 MB scan derivative,
retrievable from archive.org and pinned by SHA-256.

```bash
# 1. fetch the registered source
curl -L -o tools/content_import/sources/ramayanablaknda00vlgoog_djvu.xml \
  https://archive.org/download/ramayanablaknda00vlgoog/ramayanablaknda00vlgoog_djvu.xml

# 2. confirm it is the exact artefact the registry describes
python tools/validation/check_source_registry.py

# 3. import Bala Kanda Sarga 1
python tools/content_import/import_source.py \
  --edition-id m_n_dutt_1891_bala_kanda \
  --source tools/content_import/sources/ramayanablaknda00vlgoog_djvu.xml \
  --kanda bala_kanda --sarga-start 1 --sarga-end 1 \
  --import-date 2026-08-03

# 4. validate what was produced
python tools/validation/check_passages.py
python tools/validation/run_all.py

# 5. generate the reviewer's evidence pack
python tools/content_import/review_report.py \
  --passage m_n_dutt_1891_bala_kanda_sarga_001_p001 \
  --out docs/review/m_n_dutt_1891_bala_kanda_sarga_001_p001.md
```

The import is deterministic: the same source file produces byte-identical raw
extraction and passage records. The importer **aborts** rather than overwrite an
existing raw extraction that would change.

## Reviewing a passage

Open the generated report under `docs/review/`. It shows source metadata, the
exact page mapping, current trust state, warnings (placeholder, duplicate, page
range, OCR noise), the normalization operations applied, a raw-vs-normalized
diff, and the proposed text.

**Compare it against the page images.** Scan index N is image N+1 in the
archive.org viewer; the report states the exact image range.

Then, and only then:

```bash
# move it into review
python tools/content_import/review_record.py --passage <id> \
  --reviewer "Your Full Name" --decision start-review

# record that the text matches the printed source
python tools/content_import/review_record.py --passage <id> \
  --reviewer "Your Full Name" --decision verify \
  --note "compared against images 17-24"

# only then allow the AI to retrieve it
python tools/content_import/review_record.py --passage <id> \
  --reviewer "Your Full Name" --decision approve-retrieval

# rebuild indexes so the approved passage becomes searchable
python tools/indexing/build_search_index.py
python tools/indexing/build_embeddings.py
python tools/validation/generate_coverage_report.py
```

To refuse it (a note is mandatory):

```bash
python tools/content_import/review_record.py --passage <id> \
  --reviewer "Your Full Name" --decision reject --note "why"
```

### Who may be a reviewer

A real, accountable person's full name. The tool refuses blanks, single-token
handles, and placeholder/team/automation identities — `SitaRam QA Team`,
`Claude`, `admin`, `system`, `AI`, `test`, `unknown`, and similar. This exists
because an earlier version of this repo stamped `"reviewer_name": "SitaRam QA
Team"` onto text nobody had read.

**Claude must not run `verify`, `approve-retrieval`, or `approve-app` on real
scripture.** Preparing evidence is automation's job; judging fidelity is not.

## OCR corrections

The 1891 Google scan renders transliterated Sanskrit badly: `RSma` for Rama,
`SitS` for Sita, `NSrada` for Narada, `pfowess^`. **These are preserved
verbatim.** No automated correction is permitted.

Normalization is mechanical only — running headers and scan furniture removed,
hyphenated line-breaks rejoined, repeated whitespace collapsed. Every operation
is recorded in `text.normalizationOperations` so a reviewer can audit it.

A human correction must be recorded in the passage's `corrections[]` array with
the original form, the corrected form, and the reason. The raw extraction under
`data/raw_extractions/` is immutable and is never rewritten.

## Layout

```
tools/content_import/
  sources/                     downloaded scans (gitignored, checksum-pinned)
  data/source_registry.json    edition provenance + SHA-256
  data/raw_extractions/        verbatim per-Sarga extraction (immutable, tracked)
  data/passages/               v2 passage records (tracked)
  data/records/                legacy v1 placeholder records (tracked)
  import_source.py             stages 1-8
  review_report.py             reviewer evidence
  review_record.py             the human gate — the only way to change trust state
tools/validation/
  passage_rules.py             v2 trust states + eligibility
  corpus_rules.py              v1 eligibility
  corpus_loader.py             the single "what may the AI retrieve?" answer
  check_passages.py            v2 structural validation
  check_source_registry.py     registry validation
  test_ingestion.py            40 ingestion/approval tests
```

## Recovery

**Lost the source file.** Re-download with the command above; the checksum in
the registry proves you got the same artefact. Nothing else needs to change.

**Raw extraction was deleted.** Re-run the import. It regenerates byte-identical
raw text. Passage records are overwritten, so re-apply review decisions —
`approvalHistory` in git history shows what they were.

**Import aborts with "refusing to overwrite existing raw extraction".** The
source file differs from the one used originally. Confirm you downloaded the
right artefact. Do not delete the raw extraction to force it through unless you
have genuinely decided to re-ingest from a new source.

**A passage was approved in error.** Revoke it, then rebuild:

```bash
python tools/content_import/review_record.py --passage <id> \
  --reviewer "Your Full Name" --decision revoke-retrieval --note "why"
python tools/indexing/build_search_index.py
python tools/indexing/build_embeddings.py
python tools/validation/generate_coverage_report.py
```

The audit history is preserved; revocation appends an event rather than erasing.

**Indexes look wrong.** They are fully derived. Delete and rebuild — they can
only ever contain approved content.
