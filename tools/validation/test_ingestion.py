#!/usr/bin/env python3
"""
Tests for the real-source ingestion and human-review gates.

Every approval test uses a SYNTHETIC fixture. The real imported Dutt passage is
never approved here: automated tests must not manufacture the human decision
this whole milestone exists to require. One test asserts precisely that the real
passage is still unapproved and unindexed.

Run:
    python tools/validation/test_ingestion.py
"""
import copy
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _HERE)
REPO_ROOT = os.path.abspath(os.path.join(_HERE, ".."   , ".."))

import corpus_loader  # noqa: E402
import passage_rules  # noqa: E402

REVIEW_TOOL = os.path.join(REPO_ROOT, "tools", "content_import", "review_record.py")
REAL_PASSAGES = os.path.join(REPO_ROOT, "tools", "content_import", "data", "passages")
REAL_REGISTRY = os.path.join(REPO_ROOT, "tools", "content_import", "data", "source_registry.json")

# 60 words of clearly synthetic filler. Deliberately NOT scripture: using real
# Ramayana text in a fixture that gets auto-approved would defeat the point.
SYNTHETIC_TEXT = " ".join(["synthetic fixture sentence number %d for automated gate testing only." % i
                           for i in range(1, 13)])

SYNTHETIC_REGISTRY = {
    "sources": {
        "test_edition_1900": {
            "editionId": "test_edition_1900",
            "sourceTitle": "Synthetic Test Edition",
            "publicationYear": 1900,
        }
    }
}


def make_passage(**overrides):
    p = {
        "schemaVersion": 2,
        "passageId": "test_edition_1900_sarga_001_p001",
        "editionId": "test_edition_1900",
        "work": "Valmiki Ramayana",
        "kandaId": "bala_kanda",
        "kandaNumber": 1,
        "sargaNumber": 1,
        "passageSequence": 1,
        "language": "en",
        "source": {
            "archiveIdentifier": "synthetic_test_item",
            "sourceFilename": "synthetic.xml",
            "sha256": "a" * 64,
            "pageStart": 1,
            "pageEnd": 4,
            "scanIndexStart": 10,
            "scanIndexEnd": 13,
            "rawTextRef": "tools/validation/fixtures/synthetic_raw.txt",
            "rawTextSha256": "b" * 64,
            "importDate": "2026-08-03",
        },
        "provenance": {
            "sourceTitle": "Synthetic Test Edition",
            "originalAuthor": "Valmiki",
            "translator": "Test Translator",
            "editor": "",
            "publisher": "Test Press",
            "publicationCity": "Testville",
            "publicationYear": 1900,
            "volume": "I",
            "edition": "First",
            "sourceUrl": "https://example.invalid/synthetic",
            "publicDomainBasis": "Synthetic fixture, not a real publication.",
            "copyrightStatus": "public_domain",
            "dateAccessed": "2026-08-03",
        },
        "text": {"normalized": SYNTHETIC_TEXT, "normalizationOperations": []},
        "trust": {
            "state": "imported",
            "verified": False,
            "approvedForRetrieval": False,
            "approvedForApp": False,
            "reviewer": None,
            "reviewedAt": None,
        },
        "approvalHistory": [],
        "corrections": [],
    }
    for k, v in overrides.items():
        if isinstance(v, dict) and isinstance(p.get(k), dict):
            p[k].update(v)
        else:
            p[k] = v
    return p


def approved_passage(state="approved_for_retrieval"):
    """A synthetic passage carrying a complete, legitimate human approval trail."""
    p = make_passage()
    history = [
        {"timestamp": "2026-08-03T10:00:00+00:00", "reviewer": "Test Reviewer",
         "decision": "start-review", "fromState": "imported", "toState": "needs_review", "note": ""},
        {"timestamp": "2026-08-03T10:05:00+00:00", "reviewer": "Test Reviewer",
         "decision": "verify", "fromState": "needs_review", "toState": "text_verified", "note": "checked"},
    ]
    flags = {"verified": True, "approvedForRetrieval": False, "approvedForApp": False}
    if state in ("approved_for_retrieval", "approved_for_app"):
        history.append({"timestamp": "2026-08-03T10:10:00+00:00", "reviewer": "Test Reviewer",
                        "decision": "approve-retrieval", "fromState": "text_verified",
                        "toState": "approved_for_retrieval", "note": ""})
        flags["approvedForRetrieval"] = True
    if state == "approved_for_app":
        history.append({"timestamp": "2026-08-03T10:15:00+00:00", "reviewer": "Test Reviewer",
                        "decision": "approve-app", "fromState": "approved_for_retrieval",
                        "toState": "approved_for_app", "note": ""})
        flags["approvedForApp"] = True
    p["approvalHistory"] = history
    p["trust"].update(flags)
    p["trust"]["state"] = state
    p["trust"]["reviewer"] = "Test Reviewer"
    p["trust"]["reviewedAt"] = history[-1]["timestamp"]
    return p


class ReviewerIdentityTests(unittest.TestCase):
    def test_placeholder_and_team_names_are_refused(self):
        for name in ["SitaRam QA Team", "QA Team", "Claude", "Claude Code", "admin",
                     "system", "AI", "automated", "unknown", "tbd", "test", ""]:
            self.assertFalse(passage_rules.is_valid_reviewer(name),
                             "reviewer %r should be refused" % name)

    def test_single_token_handles_are_refused(self):
        for name in ["bob", "arun", "reviewer1"]:
            self.assertFalse(passage_rules.is_valid_reviewer(name))

    def test_real_full_names_are_accepted(self):
        for name in ["Arun Kumar Gharami", "Jane Doe", "A. K. Gharami"]:
            self.assertTrue(passage_rules.is_valid_reviewer(name))

    def test_none_and_non_strings_are_refused(self):
        for name in [None, 123, [], {}]:
            self.assertFalse(passage_rules.is_valid_reviewer(name))


class TransitionTests(unittest.TestCase):
    def test_imported_cannot_skip_to_verified(self):
        self.assertFalse(passage_rules.can_transition("imported", "text_verified"))

    def test_imported_cannot_skip_to_retrieval(self):
        self.assertFalse(passage_rules.can_transition("imported", "approved_for_retrieval"))

    def test_needs_review_cannot_skip_to_app(self):
        self.assertFalse(passage_rules.can_transition("needs_review", "approved_for_app"))

    def test_declared_path_is_allowed_step_by_step(self):
        self.assertTrue(passage_rules.can_transition("imported", "needs_review"))
        self.assertTrue(passage_rules.can_transition("needs_review", "text_verified"))
        self.assertTrue(passage_rules.can_transition("text_verified", "approved_for_retrieval"))
        self.assertTrue(passage_rules.can_transition("approved_for_retrieval", "approved_for_app"))

    def test_revocation_paths_exist(self):
        self.assertTrue(passage_rules.can_transition("approved_for_app", "approved_for_retrieval"))
        self.assertTrue(passage_rules.can_transition("approved_for_retrieval", "text_verified"))


class BlockedRecordTests(unittest.TestCase):
    """Everything that must NOT become retrieval eligible."""

    def assert_blocked(self, passage, expect_fragment=None):
        reasons = []
        ok = passage_rules.is_retrieval_eligible(passage, reasons, registry=SYNTHETIC_REGISTRY)
        self.assertFalse(ok, "passage should be blocked but was eligible")
        if expect_fragment:
            joined = " | ".join(reasons)
            self.assertIn(expect_fragment, joined)

    def test_imported_only_is_blocked(self):
        self.assert_blocked(make_passage(), "not retrieval-eligible")

    def test_needs_review_is_blocked(self):
        p = make_passage()
        p["trust"]["state"] = "needs_review"
        self.assert_blocked(p)

    def test_verified_but_not_retrieval_approved_is_blocked(self):
        p = approved_passage("text_verified")
        self.assert_blocked(p, "not retrieval-eligible")

    def test_placeholder_text_is_blocked(self):
        p = approved_passage()
        p["text"]["normalized"] = "too short"
        self.assert_blocked(p, "under %d words" % passage_rules.MIN_PASSAGE_WORD_COUNT)

    def test_empty_text_is_blocked(self):
        p = approved_passage()
        p["text"]["normalized"] = ""
        self.assert_blocked(p)

    def test_missing_provenance_is_blocked(self):
        p = approved_passage()
        p["provenance"]["translator"] = ""
        self.assert_blocked(p, "incomplete provenance")

    def test_missing_public_domain_basis_is_blocked(self):
        p = approved_passage()
        p["provenance"]["publicDomainBasis"] = ""
        self.assert_blocked(p, "incomplete provenance")

    def test_missing_reviewer_is_blocked(self):
        p = approved_passage()
        p["trust"]["reviewer"] = None
        self.assert_blocked(p, "not an accountable human identity")

    def test_fake_reviewer_is_blocked(self):
        p = approved_passage()
        p["trust"]["reviewer"] = "SitaRam QA Team"
        self.assert_blocked(p, "not an accountable human identity")

    def test_invalid_page_range_is_blocked(self):
        p = approved_passage()
        p["source"]["pageEnd"] = 0
        self.assert_blocked(p, "pageEnd")

    def test_reversed_page_range_is_blocked(self):
        p = approved_passage()
        p["source"]["pageStart"], p["source"]["pageEnd"] = 9, 3
        self.assert_blocked(p, "before pageStart")

    def test_missing_checksum_is_blocked(self):
        p = approved_passage()
        p["source"]["sha256"] = ""
        self.assert_blocked(p, "not a sha256 digest")

    def test_unsupported_edition_is_blocked(self):
        p = approved_passage()
        p["editionId"] = "some_unregistered_edition"
        self.assert_blocked(p, "not in the source registry")

    def test_empty_audit_history_is_blocked(self):
        p = approved_passage()
        p["approvalHistory"] = []
        self.assert_blocked(p, "approvalHistory is empty")

    def test_flags_forged_without_history_are_blocked(self):
        """Hand-editing the booleans without an audit trail must not work."""
        p = make_passage()
        p["trust"].update({"state": "approved_for_retrieval", "verified": True,
                           "approvedForRetrieval": True, "reviewer": "Real Person",
                           "reviewedAt": "2026-08-03T00:00:00+00:00"})
        self.assert_blocked(p, "approvalHistory is empty")


class PositiveApprovalTests(unittest.TestCase):
    """A correctly human-approved synthetic fixture must become eligible."""

    def test_valid_approved_fixture_is_retrieval_eligible(self):
        reasons = []
        ok = passage_rules.is_retrieval_eligible(
            approved_passage("approved_for_retrieval"), reasons, registry=SYNTHETIC_REGISTRY)
        self.assertTrue(ok, "valid approved fixture should be eligible; reasons: %s" % reasons)

    def test_retrieval_approved_is_not_app_eligible(self):
        self.assertFalse(passage_rules.is_app_eligible(
            approved_passage("approved_for_retrieval"), registry=SYNTHETIC_REGISTRY))

    def test_app_approved_fixture_is_app_eligible(self):
        reasons = []
        ok = passage_rules.is_app_eligible(
            approved_passage("approved_for_app"), reasons, registry=SYNTHETIC_REGISTRY)
        self.assertTrue(ok, "reasons: %s" % reasons)

    def test_revocation_removes_retrieval_eligibility(self):
        p = approved_passage("approved_for_retrieval")
        self.assertTrue(passage_rules.is_retrieval_eligible(p, registry=SYNTHETIC_REGISTRY))
        # Reviewer revokes back to text_verified.
        p["trust"].update({"state": "text_verified", "approvedForRetrieval": False})
        p["approvalHistory"].append({
            "timestamp": "2026-08-03T11:00:00+00:00", "reviewer": "Test Reviewer",
            "decision": "revoke-retrieval", "fromState": "approved_for_retrieval",
            "toState": "text_verified", "note": "withdrawn"})
        self.assertFalse(passage_rules.is_retrieval_eligible(p, registry=SYNTHETIC_REGISTRY))


class ReviewToolTests(unittest.TestCase):
    """End-to-end tests of review_record.py against a temp copy."""

    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.passages = os.path.join(self.tmp, "passages")
        os.makedirs(self.passages)
        self.registry = os.path.join(self.tmp, "registry.json")
        with open(self.registry, "w", encoding="utf-8") as f:
            json.dump(SYNTHETIC_REGISTRY, f)
        # The raw-text reference must resolve for forward decisions.
        fixtures = os.path.join(REPO_ROOT, "tools", "validation", "fixtures")
        os.makedirs(fixtures, exist_ok=True)
        self.raw = os.path.join(fixtures, "synthetic_raw.txt")
        if not os.path.exists(self.raw):
            with open(self.raw, "w", encoding="utf-8") as f:
                f.write(SYNTHETIC_TEXT)
        self.pid = "test_edition_1900_sarga_001_p001"
        self.write(make_passage())

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def write(self, passage):
        with open(os.path.join(self.passages, self.pid + ".json"), "w", encoding="utf-8") as f:
            json.dump(passage, f, indent=2)

    def read(self):
        with open(os.path.join(self.passages, self.pid + ".json"), encoding="utf-8") as f:
            return json.load(f)

    def run_tool(self, reviewer, decision, note=""):
        cmd = [sys.executable, REVIEW_TOOL, "--passage", self.pid, "--reviewer", reviewer,
               "--decision", decision, "--passage-dir", self.passages, "--registry", self.registry]
        if note:
            cmd += ["--note", note]
        return subprocess.run(cmd, capture_output=True, encoding="utf-8", errors="replace")

    def test_tool_refuses_fake_reviewer(self):
        r = self.run_tool("SitaRam QA Team", "start-review")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("not an acceptable reviewer identity", r.stdout)
        self.assertEqual(self.read()["trust"]["state"], "imported")

    def test_tool_refuses_state_skip(self):
        r = self.run_tool("Test Reviewer", "verify")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("illegal transition", r.stdout)
        self.assertEqual(self.read()["trust"]["state"], "imported")

    def test_tool_refuses_reject_without_note(self):
        r = self.run_tool("Test Reviewer", "reject")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("--note is required", r.stdout)

    def test_tool_refuses_placeholder_text_on_verify(self):
        p = make_passage()
        p["text"]["normalized"] = "tiny"
        self.write(p)
        self.assertEqual(self.run_tool("Test Reviewer", "start-review").returncode, 0)
        r = self.run_tool("Test Reviewer", "verify")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("placeholder", r.stdout)

    def test_tool_refuses_missing_provenance_on_verify(self):
        p = make_passage()
        p["provenance"]["publisher"] = ""
        self.write(p)
        self.assertEqual(self.run_tool("Test Reviewer", "start-review").returncode, 0)
        r = self.run_tool("Test Reviewer", "verify")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("provenance", r.stdout)

    def test_tool_refuses_unregistered_edition_on_verify(self):
        p = make_passage(editionId="not_registered")
        p["passageId"] = self.pid
        self.write(p)
        self.assertEqual(self.run_tool("Test Reviewer", "start-review").returncode, 0)
        r = self.run_tool("Test Reviewer", "verify")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("not in the source registry", r.stdout)

    def test_tool_refuses_retrieval_before_verify(self):
        self.assertEqual(self.run_tool("Test Reviewer", "start-review").returncode, 0)
        r = self.run_tool("Test Reviewer", "approve-retrieval")
        self.assertNotEqual(r.returncode, 0)

    def test_full_human_path_records_audit_history(self):
        self.assertEqual(self.run_tool("Test Reviewer", "start-review").returncode, 0)
        self.assertEqual(self.run_tool("Test Reviewer", "verify", "matches page images").returncode, 0)
        self.assertEqual(self.run_tool("Test Reviewer", "approve-retrieval").returncode, 0)

        p = self.read()
        self.assertEqual(p["trust"]["state"], "approved_for_retrieval")
        self.assertTrue(p["trust"]["verified"])
        self.assertTrue(p["trust"]["approvedForRetrieval"])
        self.assertFalse(p["trust"]["approvedForApp"])
        self.assertEqual(p["trust"]["reviewer"], "Test Reviewer")
        self.assertEqual(len(p["approvalHistory"]), 3)
        self.assertEqual([e["decision"] for e in p["approvalHistory"]],
                         ["start-review", "verify", "approve-retrieval"])
        # history is append-only and chains correctly
        self.assertEqual(p["approvalHistory"][0]["fromState"], "imported")
        self.assertEqual(p["approvalHistory"][-1]["toState"], "approved_for_retrieval")
        self.assertTrue(all(e["reviewer"] == "Test Reviewer" for e in p["approvalHistory"]))

    def test_revocation_preserves_history_and_removes_eligibility(self):
        for d in ["start-review", "verify", "approve-retrieval"]:
            self.assertEqual(self.run_tool("Test Reviewer", d, "n").returncode, 0)
        self.assertEqual(self.run_tool("Test Reviewer", "revoke-retrieval", "withdrawn").returncode, 0)
        p = self.read()
        self.assertEqual(p["trust"]["state"], "text_verified")
        self.assertFalse(p["trust"]["approvedForRetrieval"])
        self.assertEqual(len(p["approvalHistory"]), 4)
        self.assertFalse(passage_rules.is_retrieval_eligible(p, registry=SYNTHETIC_REGISTRY))


class RealPassageNotSelfApprovedTests(unittest.TestCase):
    """
    The real imported Dutt passage must still be waiting for a human.
    If this test ever fails, something approved scripture without a person.
    """

    def test_real_passages_are_all_unapproved(self):
        if not os.path.isdir(REAL_PASSAGES):
            self.skipTest("no real passages imported")
        found = 0
        for name in sorted(os.listdir(REAL_PASSAGES)):
            if not name.endswith(".json"):
                continue
            found += 1
            with open(os.path.join(REAL_PASSAGES, name), encoding="utf-8") as f:
                p = json.load(f)
            t = p["trust"]
            self.assertEqual(t["state"], "imported", "%s must remain 'imported'" % name)
            self.assertFalse(t["verified"])
            self.assertFalse(t["approvedForRetrieval"])
            self.assertFalse(t["approvedForApp"])
            self.assertIsNone(t["reviewer"])
            self.assertEqual(p["approvalHistory"], [])
        self.assertGreater(found, 0, "expected at least one imported real passage")

    def test_nothing_real_is_retrieval_eligible(self):
        eligible, withheld = corpus_loader.retrieval_eligible()
        self.assertEqual(eligible, [], "no real record may be retrieval eligible yet")
        self.assertGreater(withheld, 0)

    def test_generated_indexes_are_empty(self):
        for rel in ["assets/indexes/search_index.json", "assets/indexes/embeddings.json"]:
            path = os.path.join(REPO_ROOT, rel)
            if not os.path.exists(path):
                continue
            with open(path, encoding="utf-8") as f:
                data = json.load(f)
            self.assertEqual(len(data), 0, "%s must be empty while nothing is approved" % rel)


if __name__ == "__main__":
    unittest.main(verbosity=2)
