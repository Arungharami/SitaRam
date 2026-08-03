#!/usr/bin/env python3
import os
import json
import sys
import argparse
import glob

def check_duplicates(records_dir):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)

    seen_ids = set()
    seen_sarga_keys = set()
    seen_texts = {}
    duplicates = []

    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception as e:
                print(f"Error reading {file_path}: {e}")
                continue

            doc_id = record.get("documentId")
            kanda_id = record.get("kandaId")
            sarga_num = record.get("sargaNumber")

            sarga_key = f"{kanda_id}_{sarga_num}"

            if doc_id in seen_ids:
                duplicates.append(f"Duplicate documentId: {doc_id} in {os.path.basename(file_path)}")
            else:
                seen_ids.add(doc_id)

            if sarga_key in seen_sarga_keys:
                duplicates.append(f"Duplicate Sarga numbering: Kanda {kanda_id} Sarga {sarga_num} in {os.path.basename(file_path)}")
            else:
                seen_sarga_keys.add(sarga_key)

            source_text = (record.get("sourceText") or "").strip()
            if source_text:
                if source_text in seen_texts:
                    duplicates.append(
                        f"Duplicate sourceText: {os.path.basename(file_path)} has identical text to "
                        f"{seen_texts[source_text]} (copy-paste or mis-split Sarga)"
                    )
                else:
                    seen_texts[source_text] = os.path.basename(file_path)

    if duplicates:
        print("Duplicate errors found:")
        for dup in duplicates:
            print(f" - {dup}")
        return False
    else:
        print("No duplicates found. All Sargas are uniquely numbered with unique text.")
        return True

def main():
    parser = argparse.ArgumentParser(description="Check for duplicate document IDs, Sarga numbering, or source text in records.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing JSON records.")
    args = parser.parse_args()

    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    if not os.path.exists(records_path):
        print(f"Records directory '{records_path}' does not exist.")
        sys.exit(1)

    success = check_duplicates(records_path)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
