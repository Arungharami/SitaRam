#!/usr/bin/env python3
import os
import json
import sys
import argparse
import glob

def check_provenance(records_dir):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)
    
    missing_provenance = []
    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception:
                continue
            meta = record.get("sourceMetadata", {})
            title = meta.get("sourceTitle")
            translator = meta.get("translator")
            status = meta.get("copyrightStatus")
            
            if not title or not translator or not status:
                missing_provenance.append(os.path.basename(file_path))
                
    if missing_provenance:
        print(f"Provenance verification failed. Sargas with incomplete metadata:")
        for name in missing_provenance:
            print(f" - {name}")
        return False
    else:
        print("Provenance checks passed. All records have verified metadata.")
        return True

def main():
    parser = argparse.ArgumentParser(description="Verify copyright and translator provenance.")
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
