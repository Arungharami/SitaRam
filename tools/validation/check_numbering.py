#!/usr/bin/env python3
import os
import json
import sys
import argparse
import glob
from collections import defaultdict

import corpus_rules

def check_numbering(records_dir):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)

    kanda_sargas = defaultdict(list)
    success = True

    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception:
                continue
            kanda_id = record.get("kandaId")
            sarga_num = record.get("sargaNumber")
            kanda_order = record.get("kandaOrder")
            name = os.path.basename(file_path)

            if kanda_id not in corpus_rules.CANONICAL_KANDA_IDS:
                print(f"Anomaly in {name}: kandaId '{kanda_id}' is not one of the 7 canonical Kandas")
                success = False
                continue

            expected_order = corpus_rules.KANDA_ORDER[kanda_id]
            if kanda_order != expected_order:
                print(f"Anomaly in {name}: kandaOrder {kanda_order!r} should be {expected_order} for {kanda_id}")
                success = False

            max_allowed = corpus_rules.CANONICAL_SARGA_COUNTS[kanda_id]
            if not isinstance(sarga_num, int) or isinstance(sarga_num, bool) or sarga_num < 1 or sarga_num > max_allowed:
                print(f"Anomaly in {name}: sargaNumber {sarga_num!r} is out of canonical range 1-{max_allowed} for {kanda_id}")
                success = False
                continue

            kanda_sargas[kanda_id].append(sarga_num)

    for kanda_id, numbers in kanda_sargas.items():
        sorted_nums = sorted(numbers)
        if not sorted_nums:
            continue

        if len(sorted_nums) != len(set(sorted_nums)):
            print(f"Anomalies in {kanda_id}: duplicate Sarga numbers {sorted_nums}")
            success = False

        # Verify sequence start from 1 and sequential step by 1 (no gaps below the max imported so far)
        expected = list(range(1, max(sorted_nums) + 1))
        if sorted(set(sorted_nums)) != expected:
            missing = set(expected) - set(sorted_nums)
            if missing:
                print(f"Anomalies in {kanda_id}: missing Sargas {sorted(list(missing))}")
                success = False

    if success:
        print("Sequence validation passed. No numbering gaps or Kanda/Sarga anomalies found.")
    return success

def main():
    parser = argparse.ArgumentParser(description="Verify sequential Sarga numbering and Kanda ordering.")
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
