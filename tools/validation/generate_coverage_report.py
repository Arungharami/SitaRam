#!/usr/bin/env python3
import os
import json
import argparse
import glob
from datetime import datetime

# Expected total Sargas per Kanda (Valmiki Ramayana canonical count)
CANONICAL_SARGA_COUNTS = {
    "bala_kanda": 77,
    "ayodhya_kanda": 119,
    "aranya_kanda": 75,
    "kishkindha_kanda": 67,
    "sundara_kanda": 68,
    "yuddha_kanda": 128,
    "uttara_kanda": 111
}

def generate_coverage_report(records_dir, output_file):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)
    
    total_expected = sum(CANONICAL_SARGA_COUNTS.values())
    imported_count = len(files)
    
    kanda_counts = {k: 0 for k in CANONICAL_SARGA_COUNTS.keys()}
    review_status_counts = {"raw_import": 0, "approved_for_app": 0, "approved_for_retrieval": 0, "rejected": 0}
    
    lang_sarga_filled = {"en": 0, "bn": 0, "es": 0, "hi": 0, "sa": 0}
    
    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception:
                continue
            
            kanda_id = record.get("kandaId", "").lower()
            if kanda_id in kanda_counts:
                kanda_counts[kanda_id] += 1
                
            rev_status = record.get("review", {}).get("status", "raw_import")
            review_status_counts[rev_status] = review_status_counts.get(rev_status, 0) + 1
            
            translations = record.get("translations", {})
            for lang in lang_sarga_filled.keys():
                text = translations.get(lang, "").strip()
                if text:
                    lang_sarga_filled[lang] += 1

    # Calculate overall language coverage percent
    languages = {}
    for lang, filled in lang_sarga_filled.items():
        languages[lang] = {
            "coveragePercent": round((filled / total_expected) * 100, 2) if total_expected > 0 else 0.0,
            "sargasFilled": filled
        }

    kandas_complete = sum(1 for k, count in kanda_counts.items() if count >= CANONICAL_SARGA_COUNTS[k])

    report = {
        "editionId": "m_n_dutt_public_domain",
        "generatedAt": datetime.utcnow().isoformat() + "Z",
        "kandasExpected": 7,
        "kandasComplete": kandas_complete,
        "sargasExpected": total_expected,
        "sargasImported": imported_count,
        "sargasTextVerified": review_status_counts.get("approved_for_retrieval", 0) + review_status_counts.get("approved_for_app", 0),
        "sargasApprovedForRetrieval": review_status_counts.get("approved_for_retrieval", 0),
        "sargasApprovedForApp": review_status_counts.get("approved_for_app", 0),
        "kandaSargaCoverage": {
            k: {
                "imported": count,
                "expected": CANONICAL_SARGA_COUNTS[k],
                "percent": round((count / CANONICAL_SARGA_COUNTS[k]) * 100, 2)
            } for k, count in kanda_counts.items()
        },
        "languages": languages,
        "blockingIssues": []
    }
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
        
    print(f"Generated coverage report saved to '{output_file}'.")

def main():
    parser = argparse.ArgumentParser(description="Generate Ramayana corpus coverage report.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing JSON records.")
    parser.add_argument("--output", type=str, default="../../assets/content/coverage_report.json", help="Path to save coverage report.")
    args = parser.parse_args()
    
    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.output))
    generate_coverage_report(records_path, output_path)

if __name__ == "__main__":
    main()
