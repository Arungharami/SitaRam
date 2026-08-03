#!/usr/bin/env python3
import os
import json
import sys
import argparse

import corpus_rules

REQUIRED_KEYS = [
    "documentId", "work", "editionId", "kandaId", "kandaOrder", "kandaName",
    "sargaNumber", "sargaTitleEnglish", "sourceLanguage", "sourceText",
    "translations", "summary", "moralLesson", "characters", "places",
    "events", "themes", "relationships", "keywords", "contentType",
    "sourceMetadata", "review"
]


def validate_record(record, file_path):
    errors = []
    name = os.path.basename(file_path)

    missing = [key for key in REQUIRED_KEYS if key not in record]
    if missing:
        errors.append(f"missing keys: {missing}")
        # Structural check must pass before value checks can run safely.
        return errors

    t_keys = ["en", "bn", "es", "hi", "sa"]
    missing_t = [k for k in t_keys if k not in record.get("translations", {})]
    if missing_t:
        errors.append(f"missing translations keys: {missing_t}")

    s_keys = ["en", "bn", "es"]
    missing_s = [k for k in s_keys if k not in record.get("summary", {})]
    if missing_s:
        errors.append(f"missing summary keys: {missing_s}")

    # --- Value-level checks (not just key presence) ---
    doc_id = record.get("documentId")
    if not isinstance(doc_id, str) or not doc_id.strip():
        errors.append("documentId must be a non-empty string")

    kanda_id = record.get("kandaId")
    if kanda_id not in corpus_rules.CANONICAL_KANDA_IDS:
        errors.append(f"kandaId '{kanda_id}' is not one of the 7 canonical Kandas")

    sarga_num = record.get("sargaNumber")
    if not isinstance(sarga_num, int) or isinstance(sarga_num, bool) or sarga_num < 1:
        errors.append(f"sargaNumber must be a positive integer, got {sarga_num!r}")
    elif kanda_id in corpus_rules.CANONICAL_SARGA_COUNTS and sarga_num > corpus_rules.CANONICAL_SARGA_COUNTS[kanda_id]:
        errors.append(
            f"sargaNumber {sarga_num} exceeds the canonical count "
            f"({corpus_rules.CANONICAL_SARGA_COUNTS[kanda_id]}) for {kanda_id}"
        )

    expected_id = f"{record.get('editionId')}_{kanda_id}_sarga_{sarga_num:03d}" if isinstance(sarga_num, int) and not isinstance(sarga_num, bool) else None
    if expected_id and doc_id != expected_id:
        errors.append(f"documentId '{doc_id}' is not a stable ID; expected '{expected_id}'")

    kanda_order = record.get("kandaOrder")
    expected_order = corpus_rules.KANDA_ORDER.get(kanda_id)
    if expected_order is not None and kanda_order != expected_order:
        errors.append(f"kandaOrder {kanda_order!r} does not match canonical order {expected_order} for {kanda_id}")

    status = corpus_rules.declared_status(record)
    if status not in corpus_rules.VALID_REVIEW_STATUSES:
        errors.append(f"review.status '{status}' is not a recognized lifecycle state")

    translations = record.get("translations", {})
    if not isinstance(translations, dict) or not isinstance(translations.get("en"), str):
        errors.append("translations.en must be a string")

    if errors:
        for e in errors:
            print(f"Error: {name}: {e}")
        return errors

    return errors


def main():
    parser = argparse.ArgumentParser(description="Validate ingestion records schema.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing JSON records.")
    args = parser.parse_args()

    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    if not os.path.exists(records_path):
        print(f"Records directory '{records_path}' does not exist.")
        sys.exit(1)

    all_valid = True
    count = 0
    for root, _, files in os.walk(records_path):
        for f in files:
            if f.endswith(".json"):
                count += 1
                file_path = os.path.join(root, f)
                try:
                    with open(file_path, 'r', encoding='utf-8') as src:
                        record = json.load(src)
                    if validate_record(record, file_path):
                        all_valid = False
                except Exception as e:
                    print(f"Error parsing {f}: {e}")
                    all_valid = False

    if all_valid and count > 0:
        print(f"All {count} records successfully validated against the schema.")
        sys.exit(0)
    elif count == 0:
        print("No records found to validate.")
        sys.exit(0)
    else:
        print("Schema validation failed.")
        sys.exit(1)

if __name__ == "__main__":
    main()
