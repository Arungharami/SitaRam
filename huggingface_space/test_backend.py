#!/usr/bin/env python3
import json
import unittest
from fastapi.testclient import TestClient
from app import app

client = TestClient(app)

class TestSitaRamBackend(unittest.TestCase):
    def setUp(self):
        self.headers = {
            "X-SitaRam-Key": "sitaram_secret_key_108"
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

if __name__ == "__main__":
    unittest.main()
