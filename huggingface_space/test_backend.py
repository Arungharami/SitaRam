#!/usr/bin/env python3
import os

# The backend now fails closed when SITARAM_APP_KEY is absent, so the test
# process opts explicitly into the throwaway local key before importing it.
os.environ.setdefault("SITARAM_ALLOW_INSECURE_TEST_KEY", "1")

import json
import unittest
from fastapi.testclient import TestClient
import app as backend
from app import app

client = TestClient(app)

class TestSitaRamBackend(unittest.TestCase):
    def setUp(self):
        self.headers = {
            "X-SitaRam-Key": backend.SITARAM_APP_KEY
        }

    def test_health_endpoint(self):
        response = client.get("/health")
        self.assertEqual(response.statusCode if hasattr(response, "statusCode") else response.status_code, 200)
        data = response.json()
        self.assertEqual(data.get("status"), "ok")

    def test_unauthorized_access(self):
        # Access with missing headers
        response = client.post("/ask", json={"question": "Test question"})
        self.assertEqual(response.statusCode if hasattr(response, "statusCode") else response.status_code, 401)

    def test_safety_refusal_rules(self):
        # Question triggering Sanskrit verse creation safety rule
        response = client.post(
            "/ask",
            headers=self.headers,
            json={"question": "Please invent a Sanskrit verse about Rama and Kaikeyi"}
        )
        self.assertEqual(response.statusCode if hasattr(response, "statusCode") else response.status_code, 200)
        data = response.json()
        self.assertIn("Safety refusal", data.get("interpretationLabel"))
        self.assertIn("prevent", data.get("answer").lower() or "safety" in data.get("answer").lower())

    def test_valid_ask_endpoint(self):
        response = client.post(
            "/ask",
            headers=self.headers,
            json={"question": "Why did Rama accept exile?", "languageCode": "en"}
        )
        self.assertEqual(response.statusCode if hasattr(response, "statusCode") else response.status_code, 200)
        data = response.json()
        self.assertIn("answer", data)
        self.assertIn("citations", data)


class TestRetrievalTrustGate(unittest.TestCase):
    """Unverified content must never reach the retrieval corpus or be cited as scripture."""

    def test_unverified_chapter_is_not_retrieval_eligible(self):
        self.assertFalse(backend.is_verified_passage({"verified": False, "reviewStatus": "needs_review"}))

    def test_missing_verified_flag_is_treated_as_unverified(self):
        self.assertFalse(backend.is_verified_passage({"reviewStatus": "approved_for_app"}))

    def test_verified_flag_alone_is_insufficient(self):
        self.assertFalse(backend.is_verified_passage({"verified": True, "reviewStatus": "needs_review"}))

    def test_fully_approved_chapter_is_eligible(self):
        self.assertTrue(backend.is_verified_passage({"verified": True, "reviewStatus": "approved_for_app"}))

    def test_retrieval_corpus_contains_only_verified_passages(self):
        for passage in backend.sargas_db:
            self.assertTrue(backend.is_verified_passage(passage))

    def test_health_does_not_claim_corpus_completeness(self):
        data = client.get("/health").json()
        self.assertFalse(data.get("corpusComplete"))

    def test_ask_refuses_when_no_verified_evidence_exists(self):
        """With an unverified corpus the AI must refuse rather than answer from unverified text."""
        if backend.sargas_db:
            self.skipTest("Corpus contains verified passages; refusal path not applicable.")
        response = client.post(
            "/ask",
            headers={"X-SitaRam-Key": backend.SITARAM_APP_KEY},
            json={"question": "Why did Rama accept exile?", "languageCode": "en"},
        )
        data = response.json()
        self.assertEqual(data.get("citations"), [])
        self.assertIn("does not contain enough evidence", data.get("answer"))


if __name__ == "__main__":
    unittest.main()


class TestAppKeyFailsClosed(unittest.TestCase):
    """
    The backend must refuse to start rather than fall back to a committed
    default key. These tests exercise resolve_app_key directly with explicit
    environments so they never depend on the ambient process environment.
    """

    def test_missing_key_raises(self):
        with self.assertRaises(backend.InsecureConfigurationError) as ctx:
            backend.resolve_app_key(env={})
        self.assertIn("SITARAM_APP_KEY is not set", str(ctx.exception))

    def test_blank_key_raises(self):
        for blank in ["", "   ", "\t"]:
            with self.assertRaises(backend.InsecureConfigurationError):
                backend.resolve_app_key(env={"SITARAM_APP_KEY": blank})

    def test_short_key_raises(self):
        with self.assertRaises(backend.InsecureConfigurationError) as ctx:
            backend.resolve_app_key(env={"SITARAM_APP_KEY": "tooshort"})
        self.assertIn("shorter than 16", str(ctx.exception))

    def test_no_committed_production_default_exists(self):
        """The old hardcoded fallback must be gone from the source entirely."""
        here = os.path.dirname(os.path.abspath(__file__))
        with open(os.path.join(here, "app.py"), encoding="utf-8") as f:
            source = f.read()
        self.assertNotIn("sitaram_secret_key_108", source)
        self.assertNotIn('os.getenv("SITARAM_APP_KEY", ', source)

    def test_test_key_requires_explicit_opt_in(self):
        with self.assertRaises(backend.InsecureConfigurationError):
            backend.resolve_app_key(env={"SITARAM_APP_KEY": backend.SITARAM_TEST_KEY})

    def test_test_key_allowed_only_with_flag(self):
        key = backend.resolve_app_key(env={"SITARAM_ALLOW_INSECURE_TEST_KEY": "1"})
        self.assertEqual(key, backend.SITARAM_TEST_KEY)

    def test_real_key_is_accepted(self):
        key = backend.resolve_app_key(env={"SITARAM_APP_KEY": "a-sufficiently-long-real-key"})
        self.assertEqual(key, "a-sufficiently-long-real-key")

    def test_key_is_never_exposed_by_endpoints(self):
        """No endpoint may echo the application key."""
        for path in ["/health", "/coverage"]:
            body = client.get(path).text
            self.assertNotIn(backend.SITARAM_APP_KEY, body)

    def test_wrong_key_is_rejected(self):
        r = client.post("/search", json={"query": "rama"},
                        headers={"X-SitaRam-Key": "definitely-the-wrong-key"})
        self.assertEqual(r.status_code, 401)

    def test_missing_header_is_rejected(self):
        r = client.post("/search", json={"query": "rama"})
        self.assertEqual(r.status_code, 401)
