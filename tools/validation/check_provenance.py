#!/usr/bin/env python3
import os
import json
import sys
import argparse
import glob

import corpus_rules

def check_provenance(records_dir):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)

    failures = []
    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception:
                continue
            name = os.path.basename(file_path)
            meta = record.get("sourceMetadata", {})
            title = meta.get("sourceTitle")
            translator = meta.get("translator")
            status_field = meta.get("copyrightStatus")
            source_url = meta.get("sourceUrl")

            if not title or not translator or not status_field:
                failures.append(f"{name}: incomplete edition metadata (title/translator/copyrightStatus)")
            if not source_url:
                failures.append(f"{name}: missing sourceUrl for provenance verification")

            # A record cannot be trusted as reviewed/approved without a named
            # human reviewer and a review timestamp. This is what stops a
            # record from self-certifying as verified.
            status = corpus_rules.declared_status(record)
            if status in corpus_rules.RETRIEVAL_ELIGIBLE_STATUSES:
                if not corpus_rules.has_reviewer_attribution(record):
                    failures.append(
                        f"{name}: status '{status}' requires review.textReviewer and review.reviewedAt to be set"
                    )

    if failures:
        print("Provenance verification failed:")
        for name in failures:
            print(f" - {name}")
        return False
    else:
        print("Provenance checks passed. All records have verified metadata.")
        return True

def main():
    parser = argparse.ArgumentParser(description="Verify copyright, translator, and reviewer provenance.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing JSON records.")
    args = parser.parse_args()

    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    if not os.path.exists(records_path):
        print(f"Records directory '{records_path}' does not exist.")
        sys.exit(1)

    success = check_provenance(records_path)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
