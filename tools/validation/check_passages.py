#!/usr/bin/env python3
"""
Structural validation for v2 passage records (data/passages/*.json).

Checks schema shape, stable IDs, canonical Kanda/Sarga numbering, duplicates,
placeholder text, page ranges, checksums, edition support, reviewer identity,
trust-state consistency, and audit-history integrity.

This never approves anything; it only reports whether records are well formed
and whether their trust claims are internally consistent.
"""
import argparse
import glob
import json
import os
import re
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _HERE)
import corpus_rules  # noqa: E402
import passage_rules  # noqa: E402

REPO_ROOT = os.path.abspath(os.path.join(_HERE, "..", ".."))
DEFAULT_PASSAGES = os.path.join(_HERE, "..", "content_import", "data", "passages")
DEFAULT_REGISTRY = os.path.join(_HERE, "..", "content_import", "data", "source_registry.json")

TOP_LEVEL_KEYS = [
    "schemaVersion", "passageId", "editionId", "work", "kandaId", "kandaNumber",
    "sargaNumber", "passageSequence", "language", "source", "provenance",
    "text", "trust", "approvalHistory", "corrections",
]

TRUST_KEYS = ["state", "verified", "approvedForRetrieval", "approvedForApp", "reviewer", "reviewedAt"]


def validate_passage(p, registry, seen_ids, seen_slots, errors):
    pid = p.get("passageId", "<no id>")

    missing = [k for k in TOP_LEVEL_KEYS if k not in p]
    if missing:
        errors.append("%s: missing top-level keys %s" % (pid, missing))
        return

    if p.get("schemaVersion") != 2:
        errors.append("%s: schemaVersion must be 2, got %r" % (pid, p.get("schemaVersion")))

    # --- stable, derivable ID ---
    expected = "%s_sarga_%03d_p%03d" % (
        p.get("editionId"), p.get("sargaNumber", 0), p.get("passageSequence", 0))
    if pid != expected:
        errors.append("%s: unstable passageId, expected '%s'" % (pid, expected))
    if pid in seen_ids:
        errors.append("%s: duplicate passageId" % pid)
    seen_ids.add(pid)

    # --- canonical numbering ---
    kanda = p.get("kandaId")
    if kanda not in corpus_rules.CANONICAL_KANDA_IDS:
        errors.append("%s: kandaId '%s' is not one of the 7 canonical Kandas" % (pid, kanda))
    else:
        if p.get("kandaNumber") != corpus_rules.KANDA_ORDER[kanda]:
            errors.append("%s: kandaNumber %r should be %d for %s"
                          % (pid, p.get("kandaNumber"), corpus_rules.KANDA_ORDER[kanda], kanda))
        limit = corpus_rules.CANONICAL_SARGA_COUNTS[kanda]
        sarga = p.get("sargaNumber")
        if not isinstance(sarga, int) or isinstance(sarga, bool) or not (1 <= sarga <= limit):
            errors.append("%s: sargaNumber %r outside canonical range 1-%d for %s"
                          % (pid, sarga, limit, kanda))

    slot = (p.get("editionId"), kanda, p.get("sargaNumber"), p.get("passageSequence"))
    if slot in seen_slots:
        errors.append("%s: duplicate edition/Kanda/Sarga/sequence slot %s" % (pid, slot))
    seen_slots.add(slot)

    if p.get("language") not in corpus_rules.SUPPORTED_LANGUAGES:
        errors.append("%s: language '%s' is not supported" % (pid, p.get("language")))

    # --- source integrity ---
    passage_rules.has_valid_page_range(p, errors)
    passage_rules.has_source_checksum(p, errors)
    src = p.get("source") or {}
    raw_ref = src.get("rawTextRef")
    if not raw_ref:
        errors.append("%s: source.rawTextRef is missing" % pid)
    elif not os.path.exists(os.path.join(REPO_ROOT, raw_ref)):
        errors.append("%s: raw extraction not found at %s" % (pid, raw_ref))
    if not re.fullmatch(r"[0-9a-f]{64}", str(src.get("rawTextSha256", ""))):
        errors.append("%s: source.rawTextSha256 is missing or malformed" % pid)

    passage_rules.has_complete_provenance(p, errors)
    passage_rules.is_supported_edition(p, registry, errors)

    # --- trust block consistency ---
    trust = p.get("trust") or {}
    for k in TRUST_KEYS:
        if k not in trust:
            errors.append("%s: trust.%s is missing" % (pid, k))
    state = trust.get("state")
    if state not in passage_rules.TRUST_STATES:
        errors.append("%s: trust.state '%s' is not a declared state" % (pid, state))

    # The booleans must agree with the state; neither may drift from the other.
    expect = {
        "imported": (False, False, False),
        "needs_review": (False, False, False),
        "text_verified": (True, False, False),
        "approved_for_retrieval": (True, True, False),
        "approved_for_app": (True, True, True),
        "rejected": (False, False, False),
    }.get(state)
    if expect:
        actual = (bool(trust.get("verified")), bool(trust.get("approvedForRetrieval")),
                  bool(trust.get("approvedForApp")))
        if actual != expect:
            errors.append("%s: trust flags %s do not match state '%s' (expected %s)"
                          % (pid, actual, state, expect))

    if state != "imported" and not passage_rules.is_valid_reviewer(trust.get("reviewer")):
        errors.append("%s: state '%s' requires an accountable human reviewer, got %r"
                      % (pid, state, trust.get("reviewer")))

    # --- audit history ---
    history = p.get("approvalHistory")
    if not isinstance(history, list):
        errors.append("%s: approvalHistory must be a list" % pid)
    else:
        if state != "imported" and not history:
            errors.append("%s: state '%s' but approvalHistory is empty" % (pid, state))
        prev_to = None
        for i, ev in enumerate(history):
            for k in ["timestamp", "reviewer", "decision", "fromState", "toState"]:
                if not ev.get(k):
                    errors.append("%s: approvalHistory[%d].%s is missing" % (pid, i, k))
            if prev_to is not None and ev.get("fromState") != prev_to:
                errors.append("%s: approvalHistory[%d] starts at '%s' but previous ended at '%s'"
                              % (pid, i, ev.get("fromState"), prev_to))
            if ev.get("fromState") and ev.get("toState"):
                if not passage_rules.can_transition(ev["fromState"], ev["toState"]):
                    errors.append("%s: approvalHistory[%d] records illegal transition %s -> %s"
                                  % (pid, i, ev["fromState"], ev["toState"]))
            prev_to = ev.get("toState")
        if history and prev_to != state:
            errors.append("%s: trust.state '%s' does not match last audit event '%s'"
                          % (pid, state, prev_to))


def main():
    ap = argparse.ArgumentParser(description="Validate v2 passage records.")
    ap.add_argument("--passages-dir", default=DEFAULT_PASSAGES)
    ap.add_argument("--registry", default=DEFAULT_REGISTRY)
    args = ap.parse_args()

    passages_dir = os.path.abspath(args.passages_dir)
    if not os.path.isdir(passages_dir):
        print("No passages directory at %s; nothing to validate." % passages_dir)
        sys.exit(0)

    registry = {"sources": {}}
    if os.path.exists(args.registry):
        with open(args.registry, encoding="utf-8") as f:
            registry = json.load(f)

    files = sorted(glob.glob(os.path.join(passages_dir, "*.json")))
    errors, seen_ids, seen_slots = [], set(), set()
    for fp in files:
        try:
            with open(fp, encoding="utf-8") as f:
                p = json.load(f)
        except Exception as e:
            errors.append("%s: unreadable JSON: %s" % (os.path.basename(fp), e))
            continue
        validate_passage(p, registry, seen_ids, seen_slots, errors)

    if errors:
        print("Passage validation FAILED:")
        for e in errors:
            print("  - %s" % e)
        sys.exit(1)

    print("Passage validation passed: %d passage record(s) are well formed and "
          "their trust claims are internally consistent." % len(files))
    sys.exit(0)


if __name__ == "__main__":
    main()
