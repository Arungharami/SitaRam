#!/usr/bin/env python3
"""Runs every corpus validation check and reports a single pass/fail summary."""
import os
import subprocess
import sys

CHECKS = [
    "validate_schema.py",
    "check_duplicates.py",
    "check_numbering.py",
    "check_provenance.py",
    "check_placeholder_text.py",
    "check_language_support.py",
    "check_review_gate.py",
]

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    failed = []

    for check in CHECKS:
        print(f"\n=== {check} ===")
        result = subprocess.run([sys.executable, os.path.join(base_dir, check)], cwd=base_dir)
        if result.returncode != 0:
            failed.append(check)

    print("\n=== Summary ===")
    if failed:
        print(f"FAILED: {len(failed)}/{len(CHECKS)} checks did not pass: {', '.join(failed)}")
        sys.exit(1)

    print(f"PASSED: all {len(CHECKS)} corpus validation checks passed.")
    sys.exit(0)

if __name__ == "__main__":
    main()
