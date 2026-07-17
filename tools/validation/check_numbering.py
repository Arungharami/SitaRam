#!/usr/bin/env python3
import os
import json
import sys
import argparse
import glob
from collections import defaultdict

def check_numbering(records_dir):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)
    
    kanda_sargas = defaultdict(list)
    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception as e:
                continue
            kanda_id = record.get("kandaId")
            sarga_num = record.get("sargaNumber")
            if kanda_id and sarga_num:
                kanda_sargas[kanda_id].append(sarga_num)
                
    success = True
    for kanda_id, numbers in kanda_sargas.items():
        sorted_nums = sorted(numbers)
        if not sorted_nums:
            continue
            
        # Verify sequence start from 1 and sequential step by 1
        expected = list(range(1, max(sorted_nums) + 1))
        if sorted_nums != expected:
            missing = set(expected) - set(sorted_nums)
            print(f"Anomalies in {kanda_id}:")
            if missing:
                print(f" - Missing Sargas: {sorted(list(missing))}")
            else:
                print(f" - Unexpected sequence: {sorted_nums}")
            success = False
            
    if success:
        print("Sequence validation passed. No numbering gaps found.")
    return success

def main():
    parser = argparse.ArgumentParser(description="Verify sequential Sarga numbering.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing JSON records.")
    args = parser.parse_args()
    
    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    if not os.path.exists(records_path):
        print(f"Records directory '{records_path}' does not exist.")
        sys.exit(1)
        
    success = check_numbering(records_path)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
