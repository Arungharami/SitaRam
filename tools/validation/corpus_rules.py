#!/usr/bin/env python3
"""
Single source of truth for what counts as "verified" Ramayana corpus content.

Every script that reads, indexes, exports, or reports on `data/records/*.json`
(validation checks, tools/indexing/*.py, tools/content_import/export_approved.py,
tools/validation/generate_coverage_report.py) must import its eligibility rules
from here instead of re-implementing them. This is what prevents unreviewed or
placeholder text from quietly becoming "verified" in one code path while another
path still treats it as unverified.

A record's `review.status` field is a *claim*. It is only trusted for retrieval
or app use once it also passes the structural checks below (real provenance,
real reviewer attribution, real non-placeholder text). A record cannot upgrade
itself to "verified" just by having its status field edited.
"""
import re

# Canonical Sarga counts per Kanda for the Valmiki Ramayana (Manmatha Nath Dutt
# 1891 edition numbering). This is the only place these numbers should live.
CANONICAL_SARGA_COUNTS = {
    "bala_kanda": 77,
    "ayodhya_kanda": 119,
    "aranya_kanda": 75,
    "kishkindha_kanda": 67,
    "sundara_kanda": 68,
    "yuddha_kanda": 128,
    "uttara_kanda": 111,
}

# Canonical narrative order of the seven Kandas.
KANDA_ORDER = {
    "bala_kanda": 1,
    "ayodhya_kanda": 2,
    "aranya_kanda": 3,
    "kishkindha_kanda": 4,
    "sundara_kanda": 5,
    "yuddha_kanda": 6,
    "uttara_kanda": 7,
}

CANONICAL_KANDA_IDS = set(CANONICAL_SARGA_COUNTS.keys())

# Languages the app/data schema currently declares support for.
SUPPORTED_LANGUAGES = ["en", "bn", "es", "hi", "sa"]

# review.status lifecycle. Anything outside this set is malformed.
VALID_REVIEW_STATUSES = {
    "raw_import",
    "cleaned",
    "needs_review",
    "needs_native_review",
    "reviewed",
    "approved_for_retrieval",
    "approved_for_app",
    "rejected",
}

# Only these statuses may ever be treated as eligible for AI-backend retrieval
# or for shipping in the app as verified scripture.
RETRIEVAL_ELIGIBLE_STATUSES = {"approved_for_retrieval", "approved_for_app"}
APP_ELIGIBLE_STATUSES = {"approved_for_app"}

# Below this word count, a "sourceText"/translation is treated as a stub or
# summary placeholder rather than actual segmented scripture text.
MIN_SOURCE_WORD_COUNT = 40

# Exact bootstrap placeholder sentences written by
# tools/content_import/bootstrap_sample_sargas.py. These are demo/dev stand-ins,
# never real translated scripture, and must never be counted as verified no
# matter what review.status claims.
KNOWN_PLACEHOLDER_TEXTS = {
    "Ascetic Valmiki asked Narada, pre-eminent in virtuous learning: Who in the world today is heroic and righteous?",
    "King Dasaratha resolved to crown Rama. Kaikeyi demanded his exile to the forest.",
    "Entering the deep forest, Rama, Lakshmana, and Sita encountered demons. Ravana abducted Sita.",
    "Rama met Sugriva and Hanuman, forming an alliance to search for Sita.",
    "Hanuman crossed the southern ocean, located Sita in Lanka, and consoled her.",
    "Rama built the bridge to Lanka, slew Ravana, rescued Sita, and returned to Ayodhya.",
    "Rama reigned righteously over Ayodhya. Lava and Kusha sang the epic before him.",
}


def word_count(text):
    if not text:
        return 0
    return len(re.findall(r"\S+", text))


def is_placeholder_text(text):
    """True if text is empty, a known bootstrap stub, or too short to be real segmented Sarga text."""
    if text is None:
        return True
    stripped = text.strip()
    if not stripped:
        return True
    if stripped in KNOWN_PLACEHOLDER_TEXTS:
        return True
    if word_count(stripped) < MIN_SOURCE_WORD_COUNT:
        return True
    return False


def has_complete_provenance(record):
    meta = record.get("sourceMetadata", {}) or {}
    return bool(
        meta.get("sourceTitle")
        and meta.get("translator")
        and meta.get("copyrightStatus")
        and meta.get("sourceUrl")
    )


def has_reviewer_attribution(record):
    review = record.get("review", {}) or {}
    return bool(review.get("textReviewer") and review.get("reviewedAt"))


def declared_status(record):
    return (record.get("review", {}) or {}).get("status", "raw_import")


def is_retrieval_eligible(record, reasons=None):
    """
    A record may be used by the AI backend for retrieval only if:
      1. its declared status says so,
      2. its source text is not empty/placeholder/stub-length, and
      3. it carries complete provenance and a real reviewer attribution.
    `reasons`, if given a list, gets human-readable failure reasons appended.
    """
    ok = True
    status = declared_status(record)
    doc_id = record.get("documentId", "<unknown>")

    if status not in RETRIEVAL_ELIGIBLE_STATUSES:
        ok = False
        if reasons is not None:
            reasons.append(f"{doc_id}: status '{status}' is not retrieval-eligible")
        return ok

    if is_placeholder_text(record.get("sourceText", "")):
        ok = False
        if reasons is not None:
            reasons.append(
                f"{doc_id}: declared '{status}' but sourceText is empty, a known bootstrap "
                f"placeholder, or under {MIN_SOURCE_WORD_COUNT} words"
            )

    if not has_complete_provenance(record):
        ok = False
        if reasons is not None:
            reasons.append(f"{doc_id}: declared '{status}' but sourceMetadata provenance is incomplete")

    if not has_reviewer_attribution(record):
        ok = False
        if reasons is not None:
            reasons.append(f"{doc_id}: declared '{status}' but has no textReviewer/reviewedAt attribution")

    return ok


def is_app_eligible(record, reasons=None):
    """approved_for_app requires everything retrieval-eligible requires, plus the status itself."""
    status = declared_status(record)
    doc_id = record.get("documentId", "<unknown>")
    if status not in APP_ELIGIBLE_STATUSES:
        if reasons is not None:
            reasons.append(f"{doc_id}: status '{status}' is not approved_for_app")
        return False
    return is_retrieval_eligible(record, reasons)
