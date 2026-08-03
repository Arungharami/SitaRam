# SitaRam — Source Registry

Register of verified editions of the Valmiki Ramayana used in the SitaRam project.

The machine-readable registry is `tools/content_import/data/source_registry.json`.
It is validated by `tools/validation/check_source_registry.py`. This page summarises it.

## Sourced Editions

### 1. `m_n_dutt_1891_bala_kanda` — INGESTED (1 Sarga, awaiting human review)

| Field | Value |
| --- | --- |
| Title | The Ramayana |
| Original author | Valmiki |
| Translator / editor | Manmatha Nath Dutt |
| Publisher | Printed by Girish Chandra Chackravarti, Deva Press |
| Publication city | Calcutta |
| Publication year | 1891 |
| Volume | Bala Kandam |
| Edition | First edition |
| Language | English |
| Archive identifier | `ramayanablaknda00vlgoog` |
| Source URL | https://archive.org/details/ramayanablaknda00vlgoog |
| Scanned by | Google, from the Harvard University copy |
| Scan pages | 198 |
| Page map file | `ramayanablaknda00vlgoog_djvu.xml` (3,427,624 bytes) |
| Page map SHA-256 | `08dbf4d095bac9e199872eacbf7a7721c721bfe4abddcd331af5284dfa907c70` |
| Plain text SHA-256 | `20afd5065e95ff632cf96ccc651ef5d625273a1c49f8a3a0f2458838c5b4b1a8` |
| archive.org copyright field | `NOT_IN_COPYRIGHT` |
| Date accessed | 2026-08-03 |

**Public-domain basis:** published 1891 in Calcutta, prior to 1929, so no US
copyright renewal is possible. archive.org records the item as NOT_IN_COPYRIGHT.
The translator (1855-1912) died more than 70 years ago, so it is also public
domain in life+70 jurisdictions.

**Ingested so far:** Bala Kanda Sarga 1 only — printed pages 1-8, scan indices
16-23, archive viewer images 17-24. Trust state `imported`. **Not verified, not
approved for retrieval, not approved for the app.** It is excluded from the
search index, the embedding index, the FastAPI retrieval corpus, and the app.

**OCR caveat:** the scan renders transliterated Sanskrit poorly (`RSma`, `SitS`,
`NSrada`). That text is preserved verbatim. Corrections require a human decision
recorded in the passage's `corrections[]` audit trail. See
[INGESTION_AND_REVIEW.md](INGESTION_AND_REVIEW.md).

### 2. `m_n_dutt_public_domain` — REGISTERED, NOT INGESTED

The 7 records under `tools/content_import/data/records/` carry this edition's
metadata but hold bootstrap placeholder sentences, not Dutt's prose. They are
excluded from retrieval and must be replaced by real imports.

## Unregistered Content

The 9 chapters under `tools/content_import/data/chapters/` are an **editorial retelling
of unverified provenance**. They are not verbatim text from any registered edition and
are deliberately not attributed to a translator. They ship flagged `verified: false`,
are excluded from the AI retrieval corpus, and require human source verification before
they may be attributed to an edition or approved.
