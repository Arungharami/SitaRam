# SitaRam — Content Policy

SitaRam enforces strict guidelines to preserve the accuracy and sanctity of the Valmiki Ramayana.

## Rules

1. **No AI-generated text as primary source**: AI is only used to explain human-reviewed source text, never to generate verses, translations, or new stories. Missing scripture is never filled in by a model.
2. **Review status states**:
   - `raw_import`: OCR/text import completed.
   - `cleaned`: scanning noise and headers removed.
   - `segmented`: split into chapter/Sarga units. Segmentation is not review.
   - `needs_review` / `needs_native_review`: awaiting a human reviewer.
   - `reviewed`: checked by a human reviewer.
   - `approved_for_retrieval`: cleared for use as AI grounding evidence.
   - `approved_for_app`: cleared to ship to the client app as verified scripture.
   - `rejected`: failed review.
3. **No automatic approval**: no script may set `approved_for_retrieval` or `approved_for_app`. Only a human may promote a record, and the promotion must record a reviewer name and review date.
4. **Status claims are verified, not trusted**: an approval claim is rejected unless the record also has real (non-placeholder) text, complete edition provenance, and named reviewer attribution. See `tools/validation/corpus_rules.py`.
5. **Unverified content is never presented as verified**: unapproved chapters may appear in the app only when explicitly flagged `verified: false`, and are excluded from the AI retrieval corpus entirely.
6. **No false provenance**: text is only attributed to a source edition once it has been verified against that edition. Unverified editorial retellings are labelled as such, not credited to a translator.
7. **Completeness is never claimed**: the corpus is incomplete until all 645 Sargas across 7 Kandas are approved. Reports state `corpusComplete: false` until then.

## Real-source ingestion (v2 passages)

Text imported from a registered public-domain edition follows a stricter,
audited path. See [INGESTION_AND_REVIEW.md](INGESTION_AND_REVIEW.md).

8. **Sources are registered and checksummed before use**: an edition must carry
   full publication provenance and a documented public-domain basis, and the
   local file's SHA-256 must match the registry before any import runs.
9. **Raw extraction is immutable**: the verbatim per-page extraction is written
   once and never rewritten. Re-importing over changed raw text aborts.
10. **Normalization is mechanical only**: running headers, hyphenated
    line-breaks, and repeated whitespace. Never words, spelling, transliteration,
    or punctuation within a sentence. Every operation applied is recorded.
11. **OCR is never silently corrected**: a correction requires a human decision
    recorded in `corrections[]` with the original form, corrected form, and reason.
12. **Trust states cannot be skipped**: imported -> needs_review -> text_verified
    -> approved_for_retrieval -> approved_for_app. Every transition is a human
    decision appended to an immutable `approvalHistory`.
13. **Reviewers must be accountable people**: placeholder, team, and automation
    identities are refused by the tooling. Claude may prepare review evidence but
    must never issue verify or approve decisions on real scripture.
