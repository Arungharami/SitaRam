#!/usr/bin/env python3
"""
Tests for the corpus validation rules.

Uses stdlib unittest so it runs with no extra dependencies:
    python3 tools/validation/test_corpus_validation.py
"""
import copy
import json
import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import corpus_rules
import validate_schema
import check_duplicates
import check_numbering
import check_provenance
import check_placeholder_text
import check_language_support
import check_review_gate
import generate_coverage_report

REAL_TEXT = " ".join(["word"] * 60)


def make_record(**overrides):
    record = {
        "documentId": "test_edition_bala_kanda_sarga_001",
        "work": "Valmiki Ramayana",
        "editionId": "test_edition",
        "kandaId": "bala_kanda",
        "kandaOrder": 1,
        "kandaName": "Bala Kanda",
        "sargaNumber": 1,
        "sargaTitleEnglish": "Sarga 1",
        "sargaTitleBangla": "",
        "sargaTitleSpanish": "",
        "sourceLanguage": "en",
        "sourceText": REAL_TEXT,
        "translations": {"en": REAL_TEXT, "bn": "", "es": "", "hi": "", "sa": ""},
        "summary": {"en": "", "bn": "", "es": ""},
        "moralLesson": {"en": "", "bn": "", "es": ""},
        "characters": [],
        "places": [],
        "events": [],
        "themes": [],
        "relationships": [],
        "keywords": [],
        "contentType": "source_text",
        "sourceMetadata": {
            "sourceTitle": "Valmiki Ramayana",
            "translator": "Manmatha Nath Dutt",
            "publicationYear": 1891,
            "copyrightStatus": "public_domain",
            "sourceUrl": "https://archive.org/details/valmikiramayana",
            "sourcePage": "",
            "contentHash": "",
        },
        "review": {
            "status": "raw_import",
            "textReviewer": "",
            "translationReviewer": "",
            "reviewedAt": "",
            "notes": "",
        },
    }
    record.update(overrides)
    return record


def approved_record(**overrides):
    record = make_record(**overrides)
    record["review"] = {
        "status": "approved_for_app",
        "textReviewer": "A Human Reviewer",
        "translationReviewer": "A Human Reviewer",
        "reviewedAt": "2026-07-01",
        "notes": "",
    }
    return record


class TempRecordsDir:
    """Writes records to a temp dir so the file-walking checks can run against them."""

    def __init__(self, records):
        self.records = records

    def __enter__(self):
        self.path = tempfile.mkdtemp()
        for i, record in enumerate(self.records):
            doc_id = record.get("documentId", f"record_{i}")
            with open(os.path.join(self.path, f"{doc_id}.json"), 'w', encoding='utf-8') as f:
                json.dump(record, f)
        return self.path

    def __exit__(self, *exc):
        shutil.rmtree(self.path, ignore_errors=True)


class TestPlaceholderDetection(unittest.TestCase):
    def test_empty_and_none_are_placeholders(self):
        self.assertTrue(corpus_rules.is_placeholder_text(""))
        self.assertTrue(corpus_rules.is_placeholder_text("   "))
        self.assertTrue(corpus_rules.is_placeholder_text(None))

    def test_known_bootstrap_stub_is_placeholder(self):
        stub = "Rama met Sugriva and Hanuman, forming an alliance to search for Sita."
        self.assertTrue(corpus_rules.is_placeholder_text(stub))

    def test_short_text_is_placeholder(self):
        self.assertTrue(corpus_rules.is_placeholder_text("Rama went to the forest."))

    def test_long_real_text_is_not_placeholder(self):
        self.assertFalse(corpus_rules.is_placeholder_text(REAL_TEXT))


class TestRetrievalEligibility(unittest.TestCase):
    def test_raw_import_is_not_eligible(self):
        self.assertFalse(corpus_rules.is_retrieval_eligible(make_record()))

    def test_fully_approved_record_is_eligible(self):
        self.assertTrue(corpus_rules.is_retrieval_eligible(approved_record()))

    def test_approved_status_with_placeholder_text_is_rejected(self):
        """A record cannot self-certify: claiming approval over stub text must fail."""
        record = approved_record(sourceText="Rama met Sugriva and Hanuman, forming an alliance to search for Sita.")
        reasons = []
        self.assertFalse(corpus_rules.is_retrieval_eligible(record, reasons))
        self.assertTrue(any("placeholder" in r for r in reasons))

    def test_approved_status_without_reviewer_is_rejected(self):
        record = approved_record()
        record["review"]["textReviewer"] = ""
        reasons = []
        self.assertFalse(corpus_rules.is_retrieval_eligible(record, reasons))
        self.assertTrue(any("textReviewer" in r for r in reasons))

    def test_approved_status_without_provenance_is_rejected(self):
        record = approved_record()
        record["sourceMetadata"]["translator"] = ""
        reasons = []
        self.assertFalse(corpus_rules.is_retrieval_eligible(record, reasons))
        self.assertTrue(any("provenance" in r for r in reasons))

    def test_retrieval_approved_is_not_app_approved(self):
        record = approved_record()
        record["review"]["status"] = "approved_for_retrieval"
        self.assertTrue(corpus_rules.is_retrieval_eligible(record))
        self.assertFalse(corpus_rules.is_app_eligible(record))


class TestSchemaValidation(unittest.TestCase):
    def test_valid_record_passes(self):
        self.assertEqual(validate_schema.validate_record(make_record(), "r.json"), [])

    def test_missing_key_fails(self):
        record = make_record()
        del record["sargaNumber"]
        self.assertTrue(validate_schema.validate_record(record, "r.json"))

    def test_unknown_kanda_fails(self):
        errors = validate_schema.validate_record(make_record(kandaId="middle_kanda"), "r.json")
        self.assertTrue(any("canonical Kandas" in e for e in errors))

    def test_sarga_number_beyond_canonical_count_fails(self):
        record = make_record(sargaNumber=999, documentId="test_edition_bala_kanda_sarga_999")
        errors = validate_schema.validate_record(record, "r.json")
        self.assertTrue(any("exceeds the canonical count" in e for e in errors))

    def test_unstable_document_id_fails(self):
        errors = validate_schema.validate_record(make_record(documentId="whatever_id"), "r.json")
        self.assertTrue(any("stable ID" in e for e in errors))

    def test_wrong_kanda_order_fails(self):
        errors = validate_schema.validate_record(make_record(kandaOrder=1, kandaId="uttara_kanda",
                                                            documentId="test_edition_uttara_kanda_sarga_001"), "r.json")
        self.assertTrue(any("kandaOrder" in e for e in errors))

    def test_unknown_review_status_fails(self):
        record = make_record()
        record["review"]["status"] = "totally_fine_trust_me"
        errors = validate_schema.validate_record(record, "r.json")
        self.assertTrue(any("lifecycle state" in e for e in errors))


class TestDuplicateChecks(unittest.TestCase):
    def test_unique_records_pass(self):
        second = make_record(
            kandaId="ayodhya_kanda", kandaOrder=2, kandaName="Ayodhya Kanda",
            documentId="test_edition_ayodhya_kanda_sarga_001", sourceText=REAL_TEXT + " distinct",
        )
        with TempRecordsDir([make_record(), second]) as path:
            self.assertTrue(check_duplicates.check_duplicates(path))

    def test_duplicate_sarga_number_fails(self):
        dup = make_record(sourceText=REAL_TEXT + " other")
        dup["documentId"] = "test_edition_bala_kanda_sarga_001_copy"
        with TempRecordsDir([make_record(), dup]) as path:
            self.assertFalse(check_duplicates.check_duplicates(path))

    def test_identical_source_text_fails(self):
        twin = make_record(
            kandaId="ayodhya_kanda", kandaOrder=2, kandaName="Ayodhya Kanda",
            documentId="test_edition_ayodhya_kanda_sarga_001",
        )
        with TempRecordsDir([make_record(), twin]) as path:
            self.assertFalse(check_duplicates.check_duplicates(path))


class TestNumberingChecks(unittest.TestCase):
    def test_sequential_numbering_passes(self):
        second = make_record(sargaNumber=2, documentId="test_edition_bala_kanda_sarga_002")
        with TempRecordsDir([make_record(), second]) as path:
            self.assertTrue(check_numbering.check_numbering(path))

    def test_gap_in_numbering_fails(self):
        third = make_record(sargaNumber=3, documentId="test_edition_bala_kanda_sarga_003")
        with TempRecordsDir([make_record(), third]) as path:
            self.assertFalse(check_numbering.check_numbering(path))

    def test_out_of_range_sarga_fails(self):
        with TempRecordsDir([make_record(sargaNumber=500)]) as path:
            self.assertFalse(check_numbering.check_numbering(path))

    def test_wrong_kanda_order_fails(self):
        with TempRecordsDir([make_record(kandaId="yuddha_kanda", kandaOrder=1)]) as path:
            self.assertFalse(check_numbering.check_numbering(path))


class TestProvenanceChecks(unittest.TestCase):
    def test_complete_provenance_passes(self):
        with TempRecordsDir([make_record()]) as path:
            self.assertTrue(check_provenance.check_provenance(path))

    def test_missing_translator_fails(self):
        record = make_record()
        record["sourceMetadata"]["translator"] = ""
        with TempRecordsDir([record]) as path:
            self.assertFalse(check_provenance.check_provenance(path))

    def test_missing_source_url_fails(self):
        record = make_record()
        record["sourceMetadata"]["sourceUrl"] = ""
        with TempRecordsDir([record]) as path:
            self.assertFalse(check_provenance.check_provenance(path))

    def test_approved_without_reviewer_attribution_fails(self):
        record = approved_record()
        record["review"]["reviewedAt"] = ""
        with TempRecordsDir([record]) as path:
            self.assertFalse(check_provenance.check_provenance(path))


class TestPlaceholderCheckScript(unittest.TestCase):
    def test_unapproved_placeholder_is_allowed(self):
        with TempRecordsDir([make_record(sourceText="Short stub text.")]) as path:
            self.assertTrue(check_placeholder_text.check_placeholder_text(path))

    def test_approved_placeholder_is_blocking(self):
        with TempRecordsDir([approved_record(sourceText="Short stub text.")]) as path:
            self.assertFalse(check_placeholder_text.check_placeholder_text(path))

    def test_translation_copied_from_english_fails(self):
        record = make_record()
        record["translations"]["bn"] = record["translations"]["en"]
        with TempRecordsDir([record]) as path:
            self.assertFalse(check_placeholder_text.check_placeholder_text(path))


class TestLanguageSupportCheck(unittest.TestCase):
    def test_supported_languages_pass(self):
        with TempRecordsDir([make_record()]) as path:
            self.assertTrue(check_language_support.check_language_support(path))

    def test_unsupported_language_key_fails(self):
        record = make_record()
        record["translations"]["kl"] = "unsupported language claim"
        with TempRecordsDir([record]) as path:
            self.assertFalse(check_language_support.check_language_support(path))

    def test_unsupported_source_language_fails(self):
        with TempRecordsDir([make_record(sourceLanguage="zz")]) as path:
            self.assertFalse(check_language_support.check_language_support(path))


class TestReviewGate(unittest.TestCase):
    def test_unapproved_records_pass_gate(self):
        with TempRecordsDir([make_record()]) as path:
            self.assertTrue(check_review_gate.check_review_gate(path))

    def test_legitimately_approved_record_passes(self):
        with TempRecordsDir([approved_record()]) as path:
            self.assertTrue(check_review_gate.check_review_gate(path))

    def test_falsely_approved_record_fails(self):
        with TempRecordsDir([approved_record(sourceText="Too short to be scripture.")]) as path:
            self.assertFalse(check_review_gate.check_review_gate(path))


class TestCoverageReportGeneration(unittest.TestCase):
    def _generate(self, records):
        with TempRecordsDir(records) as path:
            out = os.path.join(path, "out", "coverage_report.json")
            generate_coverage_report.generate_coverage_report(path, out)
            with open(out, encoding='utf-8') as f:
                return json.load(f)

    def test_counts_are_derived_not_declared(self):
        """A record claiming approval over stub text must not be counted as verified."""
        liar = approved_record(sourceText="Rama went to the forest.")
        report = self._generate([liar])
        self.assertEqual(report["sargasImported"], 1)
        self.assertEqual(report["sargasTextVerified"], 0)
        self.assertEqual(report["sargasApprovedForRetrieval"], 0)
        self.assertEqual(report["sargasApprovedForApp"], 0)
        self.assertTrue(report["blockingIssues"])

    def test_genuinely_approved_record_is_counted(self):
        report = self._generate([approved_record()])
        self.assertEqual(report["sargasTextVerified"], 1)
        self.assertEqual(report["sargasApprovedForRetrieval"], 1)
        self.assertEqual(report["sargasApprovedForApp"], 1)

    def test_expected_totals_are_canonical(self):
        report = self._generate([make_record()])
        self.assertEqual(report["kandasExpected"], 7)
        self.assertEqual(report["sargasExpected"], 645)

    def test_never_claims_completeness_for_partial_corpus(self):
        report = self._generate([approved_record()])
        self.assertFalse(report["corpusComplete"])
        self.assertEqual(report["kandasComplete"], 0)

    def test_placeholder_records_are_reported_as_blocking(self):
        report = self._generate([make_record(sourceText="stub")])
        self.assertEqual(report["sargasPlaceholder"], 1)
        self.assertTrue(any("placeholder" in i for i in report["blockingIssues"]))

    def test_language_only_counted_when_text_is_real(self):
        report = self._generate([make_record()])
        self.assertEqual(report["languages"]["en"]["sargasFilled"], 1)
        self.assertEqual(report["languages"]["bn"]["sargasFilled"], 0)


class TestCanonicalConstants(unittest.TestCase):
    def test_seven_kandas(self):
        self.assertEqual(len(corpus_rules.CANONICAL_SARGA_COUNTS), 7)
        self.assertEqual(len(corpus_rules.KANDA_ORDER), 7)

    def test_total_sargas_is_645(self):
        self.assertEqual(sum(corpus_rules.CANONICAL_SARGA_COUNTS.values()), 645)

    def test_kanda_order_is_one_through_seven(self):
        self.assertEqual(sorted(corpus_rules.KANDA_ORDER.values()), [1, 2, 3, 4, 5, 6, 7])


if __name__ == "__main__":
    unittest.main(verbosity=2)
