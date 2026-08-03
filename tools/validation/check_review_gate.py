#!/usr/bin/env python3
"""
The authoritative retrieval-eligibility / app-eligibility gate.

This is the check that directly answers: "can this record be used by the AI
backend for retrieval, or shipped in the app as verified scripture?" It does
not trust review.status alone - see corpus_rules.is_retrieval_eligible /
is_app_eligible for the full set of requirements a record must actually meet.
"""
import os
import json
import sys
import argparse
import glob

import corpus_rules

def check_review_gate(records_dir):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)

    reasons = []
    retrieval_eligible = 0
    app_eligible = 0
    total = 0

    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception:
                continue
            total += 1
            status = corpus_rules.declared_status(record)

            if status in corpus_rules.RETRIEVAL_ELIGIBLE_STATUSES:
                if corpus_rules.is_retrieval_eligible(record, reasons):
                    retrieval_eligible += 1
            if status in corpus_rules.APP_ELIGIBLE_STATUSES:
                if corpus_rules.is_app_eligible(record, reasons):
                    app_eligible += 1

    if reasons:
        print("Review gate violations found (declared status not backed by real verification):")
        for r in reasons:
            print(f" - {r}")
        return False

    print(
        f"Review gate check passed. {retrieval_eligible}/{total} records are retrieval-eligible, "
        f"{app_eligible}/{total} are app-eligible."
    )
    return True

def main():
    parser = argparse.ArgumentParser(description="Verify declared review/approval status is backed by real verification.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing JSON records.")
    args = parser.parse_args()

    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    if not os.path.exists(records_path):
        print(f"Records directory '{records_path}' does not exist.")
        sys.exit(1)

    success = check_review_gate(records_path)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
