#!/usr/bin/env python3
import os
import json
import argparse
import glob

def get_kanda_display_name(kanda_id):
    mapping = {
        "bala_kanda": "Bala Kanda",
        "ayodhya_kanda": "Ayodhya Kanda",
        "aranya_kanda": "Aranya Kanda",
        "kishkindha_kanda": "Kishkindha Kanda",
        "sundara_kanda": "Sundara Kanda",
        "yuddha_kanda": "Yuddha Kanda",
        "uttara_kanda": "Uttara Kanda"
    }
    return mapping.get(kanda_id.lower(), kanda_id.title())

def generate_records(edition_id):
    base_dir = os.path.dirname(__file__)
    sargas_dir = os.path.join(base_dir, "data", "sargas")
    records_dir = os.path.join(base_dir, "data", "records")
    os.makedirs(records_dir, exist_ok=True)
    
    # Load sources meta
    sources_file = os.path.join(base_dir, "data", "sources.json")
    meta = {}
    if os.path.exists(sources_file):
        with open(sources_file, 'r', encoding='utf-8') as f:
            meta = json.load(f).get(edition_id, {})

    pattern = os.path.join(sargas_dir, "*.txt")
    files = glob.glob(pattern)
    
    for file_path in files:
        filename = os.path.basename(file_path).replace(".txt", "")
        # format: kanda_sarga_001
        parts = filename.split("_sarga_")
        if len(parts) != 2:
            continue
        kanda_id = parts[0]
        try:
            sarga_num = int(parts[1])
        except ValueError:
            sarga_num = 1
            
        with open(file_path, 'r', encoding='utf-8') as f:
            source_text = f.read()

        record = {
            "documentId": f"{edition_id}_{filename}",
            "work": "Valmiki Ramayana",
            "editionId": edition_id,
            "kandaId": kanda_id,
            "kandaOrder": 1, # would dynamically map this in production
            "kandaName": get_kanda_display_name(kanda_id),
            "sargaNumber": sarga_num,
            "sargaTitleEnglish": f"Sarga {sarga_num}",
            "sargaTitleBangla": "",
            "sargaTitleSpanish": "",
            "sourceLanguage": "en",
            "sourceText": source_text,
            "translations": {
                "en": source_text,
                "bn": "",
                "es": "",
                "hi": "",
                "sa": ""
            },
            "summary": {
                "en": "",
                "bn": "",
                "es": ""
            },
            "moralLesson": {
                "en": "",
                "bn": "",
                "es": ""
            },
            "characters": [],
            "places": [],
            "events": [],
            "themes": [],
            "relationships": [],
            "keywords": [],
            "contentType": "source_text",
            "sourceMetadata": {
                "sourceTitle": meta.get("title", ""),
                "translator": meta.get("translator", ""),
                "publicationYear": meta.get("publicationYear"),
                "copyrightStatus": meta.get("copyrightStatus", ""),
                "sourceUrl": meta.get("sourceUrl", ""),
                "sourcePage": "",
                "contentHash": ""
            },
            "review": {
                "status": "raw_import",
                "textReviewer": "",
                "translationReviewer": "",
                "reviewedAt": "",
                "notes": ""
            }
        }
        
        out_path = os.path.join(records_dir, f"{record['documentId']}.json")
        with open(out_path, 'w', encoding='utf-8') as f:
            json.dump(record, f, indent=2, ensure_ascii=False)
        print(f"Generated structured record: {record['documentId']}")

def main():
    parser = argparse.ArgumentParser(description="Generate structured corpus records from split Sargas.")
    parser.add_argument("--edition-id", type=str, default="m_n_dutt_public_domain", help="Registered edition ID.")
    args = parser.parse_args()
    
    generate_records(args.edition_id)

if __name__ == "__main__":
    main()
