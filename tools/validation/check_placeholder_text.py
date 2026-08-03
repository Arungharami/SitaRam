#!/usr/bin/env python3
"""
Flags empty, bootstrap-placeholder, or stub-length text so it can never be
mistaken for verified scripture, regardless of what review.status claims.
"""
import os
import json
import sys
import argparse
import glob

import corpus_rules

def check_placeholder_text(records_dir):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)

    issues = []
    placeholder_count = 0

    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception:
                continue
            name = os.path.basename(file_path)
            source_text = record.get("sourceText", "")

            if corpus_rules.is_placeholder_text(source_text):
                placeholder_count += 1
                status = corpus_rules.declared_status(record)
                reason = "empty text" if not source_text or not source_text.strip() else (
                    "known bootstrap placeholder sentence" if source_text.strip() in corpus_rules.KNOWN_PLACEHOLDER_TEXTS
                    else f"only {corpus_rules.word_count(source_text)} words (< {corpus_rules.MIN_SOURCE_WORD_COUNT})"
                )
                if status in corpus_rules.RETRIEVAL_ELIGIBLE_STATUSES:
                    issues.append(
                        f"{name}: BLOCKING - status is '{status}' but sourceText is placeholder ({reason})"
                    )
                else:
                    print(f"Note: {name}: placeholder text ({reason}); correctly not marked retrieval-eligible.")

            # A translation claiming non-empty text identical to the English source is
            # very likely a copy-paste stand-in rather than a real translation.
            translations = record.get("translations", {}) or {}
            en_text = (translations.get("en") or "").strip()
            for lang in corpus_rules.SUPPORTED_LANGUAGES:
                if lang == "en":
                    continue
                lang_text = (translations.get(lang) or "").strip()
                if lang_text and en_text and lang_text == en_text:
                    issues.append(f"{name}: translations.{lang} is identical to translations.en (not a real translation)")

    if issues:
        print("Placeholder/text integrity errors found:")
        for i in issues:
            print(f" - {i}")
        return False

    print(f"Placeholder text check passed ({placeholder_count} placeholder record(s) correctly unapproved).")
    return True

def main():
    parser = argparse.ArgumentParser(description="Detect empty, placeholder, or stub-length passage text.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing JSON records.")
    args = parser.parse_args()

    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    if not os.path.exists(records_path):
        print(f"Records directory '{records_path}' does not exist.")
        sys.exit(1)

    success = check_placeholder_text(records_path)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
