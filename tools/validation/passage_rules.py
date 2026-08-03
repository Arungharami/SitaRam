#!/usr/bin/env python3
"""
Trust rules for real-source passage records (schema v2, `data/passages/*.json`).

This is the v2 counterpart to `corpus_rules.py`, which governs the older
placeholder Sarga records in `data/records/`. Both are enforced; neither is
relaxed. A passage produced by importing real source text starts life as
`imported` and can only reach retrieval or the app by passing through explicit
human decisions that are recorded in an audit trail.

The central rule, unchanged from PR #4: a status field is a *claim*. It is only
honoured when the record also carries real non-placeholder text, a verified
source checksum, a real page range, complete edition provenance, and a named
human reviewer. Nothing in this module can approve anything - approval requires
a human running `review_record.py`.
"""
import re

# ---------------------------------------------------------------------------
# Trust state machine
# ---------------------------------------------------------------------------

# Ordered lifecycle. A record may only move along a declared transition; it can
# never skip from `imported` straight to `approved_for_retrieval`.
TRUST_STATES = [
    "imported",
    "needs_review",
    "text_verified",
    "approved_for_retrieval",
    "approved_for_app",
    "rejected",
]

# Explicit allowed transitions. Anything not listed here is refused.
ALLOWED_TRANSITIONS = {
    "imported": {"needs_review", "rejected"},
    "needs_review": {"text_verified", "rejected"},
    "text_verified": {"approved_for_retrieval", "needs_review", "rejected"},
    # Retrieval approval may be revoked back to text_verified, or escalated to app.
    "approved_for_retrieval": {"approved_for_app", "text_verified", "rejected"},
    # App approval may be revoked back down to retrieval-only.
    "approved_for_app": {"approved_for_retrieval", "text_verified", "rejected"},
    # A rejected record may be sent back for another review pass.
    "rejected": {"needs_review"},
}

# Only these states may ever be indexed for AI retrieval / shipped as verified.
RETRIEVAL_ELIGIBLE_STATES = {"approved_for_retrieval", "approved_for_app"}
APP_ELIGIBLE_STATES = {"approved_for_app"}

# Decisions a human reviewer may issue, mapped to the state they move a record to.
REVIEW_DECISIONS = {
    "start-review": "needs_review",
    "verify": "text_verified",
    "approve-retrieval": "approved_for_retrieval",
    "approve-app": "approved_for_app",
    "revoke-app": "approved_for_retrieval",
    "revoke-retrieval": "text_verified",
    "reject": "rejected",
}

# Minimum words before text is considered a real passage rather than a stub.
MIN_PASSAGE_WORD_COUNT = 40

# Reviewer identities that are never acceptable. These are the placeholder and
# team-shaped names that previously appeared as fake sign-off in this repo.
# A reviewer must be an actual accountable person.
FORBIDDEN_REVIEWER_NAMES = {
    "sitaram qa team",
    "qa team",
    "sitaram team",
    "claude",
    "claude code",
    "ai",
    "ai reviewer",
    "automated",
    "automation",
    "system",
    "admin",
    "unknown",
    "n/a",
    "na",
    "none",
    "test",
    "tester",
    "reviewer",
    "anonymous",
    "tbd",
}


def word_count(text):
    if not text:
        return 0
    return len(re.findall(r"\S+", text))


def is_placeholder_text(text):
    """Empty, whitespace, or stub-length text is never a real passage."""
    if not text or not text.strip():
        return True
    return word_count(text) < MIN_PASSAGE_WORD_COUNT


def is_valid_reviewer(name):
    """
    A reviewer must be a non-empty, human-looking, accountable identity.
    Rejects blanks, known placeholder/team labels, and single-token handles.
    """
    if not name or not isinstance(name, str):
        return False
    cleaned = name.strip()
    if len(cleaned) < 3:
        return False
    if cleaned.lower() in FORBIDDEN_REVIEWER_NAMES:
        return False
    # Require at least two name tokens so "admin"/"bob" style handles are refused.
    if len(re.findall(r"[^\s.]+", cleaned)) < 2:
        return False
    if not re.search(r"[A-Za-z]", cleaned):
        return False
    return True


def can_transition(current, target):
    """True if `current -> target` is a declared, legal transition."""
    if current not in ALLOWED_TRANSITIONS:
        return False
    return target in ALLOWED_TRANSITIONS[current]


# ---------------------------------------------------------------------------
# Structural requirements
# ---------------------------------------------------------------------------

REQUIRED_PROVENANCE_FIELDS = [
    "sourceTitle", "originalAuthor", "translator", "publisher",
    "publicationCity", "publicationYear", "edition", "sourceUrl",
    "publicDomainBasis", "copyrightStatus", "dateAccessed",
]

REQUIRED_SOURCE_FIELDS = [
    "archiveIdentifier", "sourceFilename", "sha256",
    "pageStart", "pageEnd", "rawTextRef",
]


def has_complete_provenance(passage, reasons=None):
    prov = passage.get("provenance", {}) or {}
    missing = [f for f in REQUIRED_PROVENANCE_FIELDS if not prov.get(f)]
    if missing and reasons is not None:
        reasons.append(f"{passage.get('passageId')}: incomplete provenance, missing {missing}")
    return not missing


def has_valid_page_range(passage, reasons=None):
    src = passage.get("source", {}) or {}
    start, end = src.get("pageStart"), src.get("pageEnd")
    pid = passage.get("passageId")
    for label, v in (("pageStart", start), ("pageEnd", end)):
        if not isinstance(v, int) or isinstance(v, bool) or v < 1:
            if reasons is not None:
                reasons.append(f"{pid}: {label} must be a positive integer, got {v!r}")
            return False
    if end < start:
        if reasons is not None:
            reasons.append(f"{pid}: pageEnd {end} is before pageStart {start}")
        return False
    return True


def has_source_checksum(passage, reasons=None):
    src = passage.get("source", {}) or {}
    digest = src.get("sha256")
    pid = passage.get("passageId")
    if not digest or not re.fullmatch(r"[0-9a-f]{64}", str(digest)):
        if reasons is not None:
            reasons.append(f"{pid}: source.sha256 is missing or not a sha256 digest")
        return False
    return True


def has_reviewer_attribution(passage, reasons=None):
    trust = passage.get("trust", {}) or {}
    pid = passage.get("passageId")
    reviewer, reviewed_at = trust.get("reviewer"), trust.get("reviewedAt")
    if not is_valid_reviewer(reviewer):
        if reasons is not None:
            reasons.append(f"{pid}: reviewer {reviewer!r} is missing or not an accountable human identity")
        return False
    if not reviewed_at:
        if reasons is not None:
            reasons.append(f"{pid}: reviewedAt timestamp is missing")
        return False
    return True


def trust_state(passage):
    return (passage.get("trust", {}) or {}).get("state", "imported")


def normalized_text(passage):
    return (passage.get("text", {}) or {}).get("normalized", "")


def is_supported_edition(passage, registry, reasons=None):
    """The passage's editionId must exist in the source registry."""
    pid = passage.get("passageId")
    edition_id = passage.get("editionId")
    if edition_id not in (registry or {}).get("sources", {}):
        if reasons is not None:
            reasons.append(f"{pid}: editionId {edition_id!r} is not in the source registry")
        return False
    return True


def is_retrieval_eligible(passage, reasons=None, registry=None):
    """
    A passage may be used as AI grounding evidence only when every one of these
    holds. Each is checked independently so the reviewer sees all failures.
    """
    pid = passage.get("passageId", "<unknown>")
    state = trust_state(passage)

    if state not in RETRIEVAL_ELIGIBLE_STATES:
        if reasons is not None:
            reasons.append(f"{pid}: trust state '{state}' is not retrieval-eligible")
        return False

    ok = True
    if is_placeholder_text(normalized_text(passage)):
        ok = False
        if reasons is not None:
            reasons.append(
                f"{pid}: state '{state}' but normalized text is empty or under "
                f"{MIN_PASSAGE_WORD_COUNT} words"
            )
    if not has_complete_provenance(passage, reasons):
        ok = False
    if not has_valid_page_range(passage, reasons):
        ok = False
    if not has_source_checksum(passage, reasons):
        ok = False
    if not has_reviewer_attribution(passage, reasons):
        ok = False
    if not (passage.get("trust", {}) or {}).get("verified"):
        ok = False
        if reasons is not None:
            reasons.append(f"{pid}: state '{state}' but trust.verified is not true")
    if not (passage.get("trust", {}) or {}).get("approvedForRetrieval"):
        ok = False
        if reasons is not None:
            reasons.append(f"{pid}: state '{state}' but trust.approvedForRetrieval is not true")
    if not (passage.get("approvalHistory") or []):
        ok = False
        if reasons is not None:
            reasons.append(f"{pid}: state '{state}' but approvalHistory is empty")
    if registry is not None and not is_supported_edition(passage, registry, reasons):
        ok = False
    return ok


def is_app_eligible(passage, reasons=None, registry=None):
    pid = passage.get("passageId", "<unknown>")
    state = trust_state(passage)
    if state not in APP_ELIGIBLE_STATES:
        if reasons is not None:
            reasons.append(f"{pid}: trust state '{state}' is not approved_for_app")
        return False
    ok = is_retrieval_eligible(passage, reasons, registry)
    if not (passage.get("trust", {}) or {}).get("approvedForApp"):
        ok = False
        if reasons is not None:
            reasons.append(f"{pid}: state '{state}' but trust.approvedForApp is not true")
    return ok
