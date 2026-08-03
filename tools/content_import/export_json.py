#!/usr/bin/env python3
import os
import glob
import json
import argparse

def main():
    parser = argparse.ArgumentParser(description="Step 5: Merge and compile chapters for production release.")
    parser.add_argument("--chapters-dir", type=str, default="data/chapters", help="Folder containing chapter files.")
    parser.add_argument("--output-file", type=str, default="../../assets/content/ramayana_chapters.json", help="App asset destination.")
    parser.add_argument("--release", action="store_true", help="If set, only export approved chapters.")
    args = parser.parse_args()

    print("[Step 5] Compiling and merging Ramayana chapters...")
    
    chapters_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), args.chapters_dir))
    output_file = os.path.abspath(os.path.join(os.path.dirname(__file__), args.output_file))
    
    en_pattern = os.path.join(chapters_dir, "en_*.json")
    en_files = sorted(glob.glob(en_pattern))
    
    if not en_files:
        print("No English chapter files found. Run split_chapters.py first.")
        return

    compiled_chapters = []

    for en_file in en_files:
        base_name = os.path.basename(en_file)
        chapter_id = base_name.replace("en_", "").replace(".json", "")
        bn_file = os.path.join(chapters_dir, f"bn_{chapter_id}.json")
        
        with open(en_file, 'r', encoding='utf-8') as f:
            en_data = json.load(f)
            
        bn_data = {}
        if os.path.exists(bn_file):
            with open(bn_file, 'r', encoding='utf-8') as f:
                bn_data = json.load(f)
        
        en_status = en_data.get("review_status", "needs_review")
        bn_status = bn_data.get("review_status", "needs_native_review")

        # A chapter is only "verified" when a human has approved both the
        # English text and the Bangla translation. Everything else ships (if at
        # all) explicitly flagged as unverified so no UI or AI surface can
        # present it as confirmed scripture.
        verified = en_status == "approved_for_app" and bn_status == "approved_for_app"

        if args.release and not verified:
            print(f"Skipping {chapter_id} (not approved: en={en_status}, bn={bn_status})")
            continue

        # Formulate Audio Detail structures
        audio_en = {
            "chapter_id": chapter_id,
            "language": "en",
            "voice_type": "narration",
            "audio_file": f"assets/audio/en/{chapter_id}.mp3",
            "duration": None,
            "status": "placeholder"
        }
        audio_bn = {
            "chapter_id": chapter_id,
            "language": "bn",
            "voice_type": "bangla_explanation",
            "audio_file": f"assets/audio/bn/{chapter_id}.mp3",
            "duration": None,
            "status": "placeholder"
        }

        # Merge matching the exact requested production model
        merged = {
            "id": chapter_id,
            "kandaId": en_data.get("kandaId"),
            "kanda": en_data.get("kanda"),
            "chapterNumber": en_data.get("chapter_number"),
            "chapterTitleEnglish": en_data.get("chapter_title_english"),
            "chapterTitleBangla": en_data.get("chapter_title_bangla"),
            "chapterTitleSpanish": en_data.get("chapter_title_spanish", ""),
            "englishText": en_data.get("english_text"),
            "banglaText": bn_data.get("bangla_text", ""),
            "spanishText": en_data.get("spanish_text", ""),
            "shortSummaryEnglish": en_data.get("short_summary_english"),
            "shortSummaryBangla": bn_data.get("short_summary_bangla", ""),
            "shortSummarySpanish": en_data.get("short_summary_spanish", ""),
            "moralLessonEnglish": en_data.get("moral_lesson_english"),
            "moralLessonBangla": bn_data.get("moral_lesson_bangla", ""),
            "moralLessonSpanish": en_data.get("moral_lesson_spanish", ""),
            "characters": en_data.get("characters", []),
            "themes": en_data.get("themes", []),
            
            # Metadata
            "sourceTitle": en_data.get("source_title", ""),
            "sourceStatus": en_data.get("source_status", ""),
            "reviewStatus": en_status,
            "translationReviewStatus": bn_status,
            "verified": verified,

            # Audio pipelines
            "audioEnglish": audio_en,
            "audioBangla": audio_bn,
            
            # Source detail nested block for review
            "source_metadata": en_data.get("source_metadata", {})
        }
        compiled_chapters.append(merged)
        print(f"Merged & Compiled: {chapter_id} (verified={verified})")

    # Ensure output folder
    output_dir = os.path.dirname(output_file)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(compiled_chapters, f, indent=2, ensure_ascii=False)

    verified_count = sum(1 for c in compiled_chapters if c["verified"])
    print(
        f"[Step 5] Finished. Exported {len(compiled_chapters)} chapters to '{output_file}' "
        f"({verified_count} verified, {len(compiled_chapters) - verified_count} flagged unverified)."
    )

if __name__ == "__main__":
    main()
