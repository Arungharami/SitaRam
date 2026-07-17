#!/usr/bin/env python3
import os
import json
import sys
import argparse

REQUIRED_KEYS = [
    "documentId", "work", "editionId", "kandaId", "kandaOrder", "kandaName",
    "sargaNumber", "sargaTitleEnglish", "sourceLanguage", "sourceText",
    "translations", "summary", "moralLesson", "characters", "places",
    "events", "themes", "relationships", "keywords", "contentType",
    "sourceMetadata", "review"
]

def validate_record(record, file_path):
    missing = [key for key in REQUIRED_KEYS if key not in record]
    if missing:
        print(f"Error: {os.path.basename(file_path)} is missing keys: {missing}")
        return False
        
    # Check translations sub-object
    t_keys = ["en", "bn", "es", "hi", "sa"]
    missing_t = [k for k in t_keys if k not in record.get("translations", {})]
    if missing_t:
        print(f"Error: {os.path.basename(file_path)} is missing translations keys: {missing_t}")
        return False
        
    # Check summary sub-object
    s_keys = ["en", "bn", "es"]
    missing_s = [k for k in s_keys if k not in record.get("summary", {})]
    if missing_s:
        print(f"Error: {os.path.basename(file_path)} is missing summary keys: {missing_s}")
        return False
        
    return True

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
                    if not validate_record(record, file_path):
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
