#!/usr/bin/env python3
import os
import sys
import json
import argparse
import glob

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "validation"))
import corpus_rules

def export_approved(output_file):
    base_dir = os.path.dirname(__file__)
    records_dir = os.path.join(base_dir, "data", "records")
    
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)
    
    approved_list = []
    skipped = []
    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            record = json.load(f)
        status = corpus_rules.declared_status(record)
        reasons = []
        if corpus_rules.is_app_eligible(record, reasons):
            # Convert to production mobile schema format if required
            prod_record = {
                "id": record["documentId"],
                "kandaId": record["kandaId"],
                "kanda": record["kandaName"],
                "chapterNumber": record["sargaNumber"],
                "chapterTitleEnglish": record["sargaTitleEnglish"],
                "chapterTitleBangla": record["sargaTitleBangla"],
                "chapterTitleSpanish": record["sargaTitleSpanish"],
                "englishText": record["translations"]["en"],
                "banglaText": record["translations"]["bn"],
                "spanishText": record["translations"]["es"],
                "shortSummaryEnglish": record["summary"]["en"],
                "shortSummaryBangla": record["summary"]["bn"],
                "shortSummarySpanish": record["summary"]["es"],
                "moralLessonEnglish": record["moralLesson"]["en"],
                "moralLessonBangla": record["moralLesson"]["bn"],
                "moralLessonSpanish": record["moralLesson"]["es"],
                "characters": record["characters"],
                "themes": record["themes"],
                "sourceTitle": record["sourceMetadata"]["sourceTitle"],
                "sourceStatus": record["sourceMetadata"]["copyrightStatus"],
                "reviewStatus": status,
                "audioEnglish": {
                    "chapter_id": record["documentId"],
                    "language": "en",
                    "voice_type": "narration",
                    "audio_file": f"assets/audio/en/{record['documentId']}.mp3",
                    "duration": None,
                    "status": "placeholder"
                },
                "audioBangla": {
                    "chapter_id": record["documentId"],
                    "language": "bn",
                    "voice_type": "bangla_explanation",
                    "audio_file": f"assets/audio/bn/{record['documentId']}.mp3",
                    "duration": None,
                    "status": "placeholder"
                },
                "source_metadata": {
                    "source_title": record["sourceMetadata"]["sourceTitle"],
                    "author_translator": record["sourceMetadata"]["translator"],
                    "publication_year": record["sourceMetadata"]["publicationYear"],
                    "copyright_status": record["sourceMetadata"]["copyrightStatus"],
                    "source_url": record["sourceMetadata"]["sourceUrl"],
                    "notes": ""
                }
            }
            approved_list.append(prod_record)
        else:
            skipped.append(reasons[0] if reasons else f"{record.get('documentId')}: not app-eligible")

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(approved_list, f, indent=2, ensure_ascii=False)

    for reason in skipped:
        print(f"Skipped (not approved for app): {reason}")
    print(f"Exported {len(approved_list)} app-approved chapters to '{output_file}' ({len(skipped)} withheld).")

def main():
    parser = argparse.ArgumentParser(description="Export approved Sargas to Flutter app assets.")
    parser.add_argument("--output", type=str, default="../../assets/content/ramayana_chapters.json", help="Destination path.")
    args = parser.parse_args()
    
    # Resolve relative path
    output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.output))
    export_approved(output_path)

if __name__ == "__main__":
    main()
