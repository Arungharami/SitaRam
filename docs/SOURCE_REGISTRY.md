# SitaRam — Source Registry

Register of verified editions of the Valmiki Ramayana used in the SitaRam project.

## Sourced Editions
1. **Manmatha Nath Dutt (1891)**
   - Language: English
   - Status: Public Domain (worldwide)
   - Scope: Complete 7 Kandas prose translation.
   - Verification status: **Registered, not yet ingested.** No Sarga from this edition has
     been imported, verified, or approved. The 7 records currently under
     `tools/content_import/data/records/` carry this edition's metadata but hold
     bootstrap placeholder sentences, not Dutt's prose. They are excluded from retrieval.

## Unregistered Content

The 9 chapters under `tools/content_import/data/chapters/` are an **editorial retelling
of unverified provenance**. They are not verbatim text from any registered edition and
are deliberately not attributed to a translator. They ship flagged `verified: false`,
are excluded from the AI retrieval corpus, and require human source verification before
they may be attributed to an edition or approved.
