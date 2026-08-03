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
