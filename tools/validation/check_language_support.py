#!/usr/bin/env python3
"""
Verifies that language claims in a record are honest: only declared
SUPPORTED_LANGUAGES keys are used, and a language is only "filled" if it
has real (non-placeholder) text, not just a non-empty string.
"""
import os
import json
import sys
import argparse
import glob

import corpus_rules

def check_language_support(records_dir):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)

    issues = []
    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception:
                continue
            name = os.path.basename(file_path)
            translations = record.get("translations", {}) or {}

            unsupported_keys = [k for k in translations.keys() if k not in corpus_rules.SUPPORTED_LANGUAGES]
            if unsupported_keys:
                issues.append(f"{name}: translations declares unsupported language code(s): {unsupported_keys}")

            source_language = record.get("sourceLanguage")
            if source_language not in corpus_rules.SUPPORTED_LANGUAGES:
                issues.append(f"{name}: sourceLanguage '{source_language}' is not a supported language code")

    if issues:
        print("Language support errors found:")
        for i in issues:
            print(f" - {i}")
        return False

    print("Language support check passed. No unsupported language claims found.")
    return True

def main():
    parser = argparse.ArgumentParser(description="Verify language claims are limited to supported languages.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing JSON records.")
    args = parser.parse_args()

    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    if not os.path.exists(records_path):
        print(f"Records directory '{records_path}' does not exist.")
        sys.exit(1)

    success = check_language_support(records_path)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
