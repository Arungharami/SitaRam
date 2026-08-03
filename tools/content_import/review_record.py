#!/usr/bin/env python3
"""
The human review gate. This is the ONLY way a passage can change trust state.

Every invocation requires a named accountable human. The tool refuses to run
without one, refuses illegal state transitions, refuses to promote records that
fail the structural checks, and appends an immutable audit event for every
decision it accepts.

Claude must not run the `verify`, `approve-retrieval`, or `approve-app`
decisions on real scripture. Preparing evidence is automation's job; deciding
that text faithfully reproduces a printed source is a person's job.

Usage:
    python tools/content_import/review_record.py --passage <id> \
        --reviewer "Arun Kumar Gharami" --decision verify --note "checked vs images 17-24"

Decisions: start-review, verify, approve-retrieval, approve-app,
           revoke-app, revoke-retrieval, reject
"""
import argparse
import datetime
import json
import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(BASE_DIR, "..", ".."))
PASSAGE_DIR = os.path.join(BASE_DIR, "data", "passages")
REGISTRY_PATH = os.path.join(BASE_DIR, "data", "source_registry.json")

sys.path.insert(0, os.path.join(BASE_DIR, "..", "validation"))
import passage_rules  # noqa: E402


def utc_now_iso():
    return datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat()


def load_registry():
    with open(REGISTRY_PATH, encoding="utf-8") as f:
        return json.load(f)


def preconditions_for(decision, passage, registry):
    """
    Structural gates that must hold before a decision is accepted.
    Returns a list of failure strings; empty means the decision may proceed.
    """
    failures = []
    pid = passage.get("passageId")

    # Any forward movement requires the record to be structurally sound.
    if decision in ("verify", "approve-retrieval", "approve-app"):
        if passage_rules.is_placeholder_text(passage_rules.normalized_text(passage)):
            failures.append("normalized text is empty or under %d words (placeholder)"
                            % passage_rules.MIN_PASSAGE_WORD_COUNT)
        passage_rules.has_complete_provenance(passage, failures)
        passage_rules.has_valid_page_range(passage, failures)
        passage_rules.has_source_checksum(passage, failures)
        if not passage_rules.is_supported_edition(passage, registry, failures):
            pass

        raw_ref = (passage.get("source") or {}).get("rawTextRef")
        if not raw_ref or not os.path.exists(os.path.join(REPO_ROOT, raw_ref)):
            failures.append("raw extraction referenced by source.rawTextRef is missing")

    # Retrieval approval additionally requires the text to already be verified.
    if decision == "approve-retrieval" and not (passage.get("trust") or {}).get("verified"):
        failures.append("cannot approve for retrieval before the text is verified")

    if decision == "approve-app" and not (passage.get("trust") or {}).get("approvedForRetrieval"):
        failures.append("cannot approve for app before the passage is approved for retrieval")

    return [f for f in failures if f]


def apply_decision(passage, decision, reviewer, note, timestamp):
    trust = passage.setdefault("trust", {})
    current = trust.get("state", "imported")
    target = passage_rules.REVIEW_DECISIONS[decision]

    if not passage_rules.can_transition(current, target):
        return None, ("illegal transition '%s' -> '%s' (decision '%s'). Allowed from '%s': %s"
                      % (current, target, decision, current,
                         sorted(passage_rules.ALLOWED_TRANSITIONS.get(current, set()))))

    previous = dict(trust)

    trust["state"] = target
    trust["reviewer"] = reviewer
    trust["reviewedAt"] = timestamp

    # Boolean flags are derived from the target state, never set independently.
    if target == "text_verified":
        trust["verified"] = True
        trust["approvedForRetrieval"] = False
        trust["approvedForApp"] = False
    elif target == "approved_for_retrieval":
        trust["verified"] = True
        trust["approvedForRetrieval"] = True
        trust["approvedForApp"] = False
    elif target == "approved_for_app":
        trust["verified"] = True
        trust["approvedForRetrieval"] = True
        trust["approvedForApp"] = True
    elif target in ("needs_review", "imported"):
        trust["verified"] = False
        trust["approvedForRetrieval"] = False
        trust["approvedForApp"] = False
    elif target == "rejected":
        trust["verified"] = False
        trust["approvedForRetrieval"] = False
        trust["approvedForApp"] = False

    passage.setdefault("approvalHistory", []).append({
        "timestamp": timestamp,
        "reviewer": reviewer,
        "decision": decision,
        "fromState": current,
        "toState": target,
        "note": note or "",
        "previousTrust": previous,
    })
    return passage, None


def main():
    ap = argparse.ArgumentParser(description="Human review gate for imported passages.")
    ap.add_argument("--passage", required=True)
    ap.add_argument("--reviewer", required=True, help="Full name of the accountable human reviewer.")
    ap.add_argument("--decision", required=True, choices=sorted(passage_rules.REVIEW_DECISIONS))
    ap.add_argument("--note", default="", help="Why this decision was made (required for reject/corrections).")
    ap.add_argument("--timestamp", help="ISO-8601 UTC. Defaults to now.")
    ap.add_argument("--passage-dir", default=PASSAGE_DIR, help="Override for tests.")
    ap.add_argument("--registry", default=REGISTRY_PATH, help="Override for tests.")
    args = ap.parse_args()

    # --- Gate 1: a real, accountable human reviewer ---
    if not passage_rules.is_valid_reviewer(args.reviewer):
        print("REFUSED: '%s' is not an acceptable reviewer identity." % args.reviewer)
        print("  A reviewer must be a real, accountable person's full name.")
        print("  Placeholder, team, and automation identities are rejected.")
        sys.exit(2)

    path = os.path.join(args.passage_dir, args.passage + ".json")
    if not os.path.exists(path):
        print("REFUSED: no such passage: %s" % args.passage)
        sys.exit(2)
    with open(path, encoding="utf-8") as f:
        passage = json.load(f)

    with open(args.registry, encoding="utf-8") as f:
        registry = json.load(f)

    if args.decision == "reject" and not args.note.strip():
        print("REFUSED: --note is required when rejecting a passage.")
        sys.exit(2)

    # --- Gate 2: structural preconditions ---
    failures = preconditions_for(args.decision, passage, registry)
    if failures:
        print("REFUSED: %s cannot be moved by decision '%s'." % (args.passage, args.decision))
        for f in failures:
            print("  - %s" % f)
        sys.exit(2)

    # --- Gate 3: legal state transition ---
    timestamp = args.timestamp or utc_now_iso()
    before_state = (passage.get("trust") or {}).get("state", "imported")
    updated, err = apply_decision(passage, args.decision, args.reviewer.strip(), args.note, timestamp)
    if err:
        print("REFUSED: %s" % err)
        sys.exit(2)

    with open(path, "w", encoding="utf-8") as f:
        json.dump(updated, f, indent=2, ensure_ascii=False)

    trust = updated["trust"]
    print("Recorded decision '%s' on %s" % (args.decision, args.passage))
    print("  reviewer:   %s" % trust["reviewer"])
    print("  timestamp:  %s" % trust["reviewedAt"])
    print("  state:      %s -> %s" % (before_state, trust["state"]))
    print("  verified=%s  approvedForRetrieval=%s  approvedForApp=%s"
          % (trust["verified"], trust["approvedForRetrieval"], trust["approvedForApp"]))
    print("  audit events: %d" % len(updated["approvalHistory"]))
    if trust["approvedForRetrieval"]:
        print("")
        print("This passage is now retrieval-eligible. Rebuild the indexes to include it:")
        print("  python tools/indexing/build_search_index.py")
        print("  python tools/indexing/build_embeddings.py")


if __name__ == "__main__":
    main()
