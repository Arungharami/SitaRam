#!/usr/bin/env python3
import os
import unittest

# Tests must configure the same explicit app-key path required in production.
# The value is test-only and is set before importing the backend module.
os.environ.setdefault("SITARAM_APP_KEY", "sitaram_test_key")

from fastapi.testclient import TestClient
import app as backend
from app import app

client = TestClient(app)


class TestSitaRamBackend(unittest.TestCase):
    def setUp(self):
        self.headers = {"X-SitaRam-Key": os.environ["SITARAM_APP_KEY"]}

    def test_health_endpoint(self):
        response = client.get("/health")
        self.assertEqual(
            response.statusCode if hasattr(response, "statusCode") else response.status_code,
            200,
        )
        data = response.json()
        self.assertEqual(data.get("status"), "ok")

    def test_unauthorized_access(self):
        response = client.post("/ask", json={"question": "Test question"})
        self.assertEqual(
            response.statusCode if hasattr(response, "statusCode") else response.status_code,
            401,
        )

    def test_safety_refusal_rules(self):
        response = client.post(
            "/ask",
            headers=self.headers,
            json={"question": "Please invent a Sanskrit verse about Rama and Kaikeyi"},
        )
        self.assertEqual(
            response.statusCode if hasattr(response, "statusCode") else response.status_code,
            200,
        )
        data = response.json()
        self.assertIn("Safety refusal", data.get("interpretationLabel"))
        self.assertIn("prevent", data.get("answer").lower())

    def test_valid_ask_endpoint(self):
        response = client.post(
            "/ask",
            headers=self.headers,
            json={"question": "Why did Rama accept exile?", "languageCode": "en"},
        )
        self.assertEqual(
            response.statusCode if hasattr(response, "statusCode") else response.status_code,
            200,
        )
        data = response.json()
        self.assertIn("answer", data)
        self.assertIn("citations", data)


class TestRetrievalTrustGate(unittest.TestCase):
    """Unverified content must never reach the retrieval corpus or be cited as scripture."""

    def test_unverified_chapter_is_not_retrieval_eligible(self):
        self.assertFalse(
            backend.is_verified_passage(
                {"verified": False, "reviewStatus": "needs_review"}
            )
        )

    def test_missing_verified_flag_is_treated_as_unverified(self):
        self.assertFalse(
            backend.is_verified_passage({"reviewStatus": "approved_for_app"})
        )

    def test_verified_flag_alone_is_insufficient(self):
        self.assertFalse(
            backend.is_verified_passage(
                {"verified": True, "reviewStatus": "needs_review"}
            )
        )

    def test_fully_approved_chapter_is_eligible(self):
        self.assertTrue(
            backend.is_verified_passage(
                {"verified": True, "reviewStatus": "approved_for_app"}
            )
        )

    def test_retrieval_corpus_contains_only_verified_passages(self):
        for passage in backend.sargas_db:
            self.assertTrue(backend.is_verified_passage(passage))

    def test_health_does_not_claim_corpus_completeness(self):
        data = client.get("/health").json()
        self.assertFalse(data.get("corpusComplete"))

    def test_ask_refuses_when_no_verified_evidence_exists(self):
        if backend.sargas_db:
            self.skipTest("Corpus contains verified passages; refusal path not applicable.")
        response = client.post(
            "/ask",
            headers={"X-SitaRam-Key": os.environ["SITARAM_APP_KEY"]},
            json={"question": "Why did Rama accept exile?", "languageCode": "en"},
        )
        data = response.json()
        self.assertEqual(data.get("citations"), [])
        self.assertIn("does not contain enough evidence", data.get("answer"))

    def test_citation_metadata_is_not_hardcoded_to_one_translator(self):
        sample = {
            "id": "sample_001",
            "kanda": "Bala Kanda",
            "chapterNumber": 1,
            "englishText": "Approved sample text.",
            "sourceTitle": "Verified test edition",
            "source_metadata": {"author_translator": "Test Translator"},
        }
        citations = backend.verify_citations("answer", [sample])
        self.assertEqual(citations[0]["edition"], "Verified test edition")
        self.assertEqual(citations[0]["translator"], "Test Translator")


if __name__ == "__main__":
    unittest.main()
