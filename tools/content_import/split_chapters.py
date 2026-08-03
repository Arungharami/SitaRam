#!/usr/bin/env python3
"""
Step 4: Emit per-chapter English and Bangla JSON files from data/chapters_source.json.

The chapter narrative content lives in data/chapters_source.json, not inline in
this script. That text is an editorial retelling; it is NOT verbatim Manmatha
Nath Dutt public-domain prose and has not been checked against any source
edition. This script therefore emits `needs_review` / `needs_native_review` with
no reviewer attribution. Only a human may promote a chapter to
`approved_for_app` after verifying it against the registered source edition.
"""
import os
import glob
import json
import argparse

# Provenance for editorially retold chapter text. Attribution is deliberately
# left empty rather than credited to M. N. Dutt: this text has not been verified
# as that translation, and claiming so would be a false provenance claim.
UNVERIFIED_SOURCE_META = {
    "source_title": "SitaRam editorial retelling (provenance unverified)",
    "author_translator": "",
    "publication_year": None,
    "copyright_status": "unverified",
    "source_url": "",
    "notes": (
        "Editorial narrative retelling, not verbatim source-edition text. Requires human "
        "verification against the registered public-domain edition before approval."
    ),
    "reviewer_name": None,
    "approval_date": None,
}


def main():
    parser = argparse.ArgumentParser(description="Step 4: Generate English & Bangla JSON chapters from the chapter source file.")
    parser.add_argument("--pages-dir", type=str, default="data/pages", help="Folder containing page JSON files.")
    parser.add_argument("--chapters-dir", type=str, default="data/chapters", help="Folder to save chapter splits.")
    parser.add_argument("--source-file", type=str, default="data/chapters_source.json", help="Chapter content source file.")
    args = parser.parse_args()

    print("[Step 4] Splitting text and mapping to professional schema...")

    base_dir = os.path.dirname(os.path.abspath(__file__))
    pages_dir = os.path.abspath(os.path.join(base_dir, args.pages_dir))
    chapters_dir = os.path.abspath(os.path.join(base_dir, args.chapters_dir))
    source_file = os.path.abspath(os.path.join(base_dir, args.source_file))

    if not os.path.exists(source_file):
        print(f"Chapter source file '{source_file}' not found.")
        return

    with open(source_file, 'r', encoding='utf-8') as f:
        chapters_db = json.load(f)

    os.makedirs(chapters_dir, exist_ok=True)

    files = sorted(glob.glob(os.path.join(pages_dir, "page_*.json")))
    if not files:
        print("No page JSON files found. Run previous steps first.")
        return

    # Pages have been segmented into chapters, but segmentation is not review.
    for page_file in files:
        with open(page_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        data["status"] = "segmented"
        with open(page_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    for seq, ch_data in sorted(chapters_db.items(), key=lambda kv: int(kv[0])):
        chapter_id = f"{ch_data['kandaId']}_{int(seq):03d}"

        en_file = os.path.join(chapters_dir, f"en_{chapter_id}.json")
        en_json = {
            "source_id": "sitaram_editorial_retelling_en",
            "language": "en",
            "kanda": ch_data["kanda"],
            "kandaId": ch_data["kandaId"],
            "chapter_number": ch_data["chapterNumber"],
            "chapter_title_english": ch_data["chapterTitleEnglish"],
            "chapter_title_bangla": ch_data["chapterTitleBangla"],
            "english_text": ch_data["englishText"],
            "short_summary_english": ch_data["shortSummaryEnglish"],
            "moral_lesson_english": ch_data["moralLessonEnglish"],
            "characters": ch_data["characters"],
            "themes": ch_data["themes"],
            "source_title": UNVERIFIED_SOURCE_META["source_title"],
            "source_status": UNVERIFIED_SOURCE_META["copyright_status"],
            "review_status": "needs_review",
            "source_metadata": UNVERIFIED_SOURCE_META,
        }
        with open(en_file, 'w', encoding='utf-8') as f:
            json.dump(en_json, f, indent=2, ensure_ascii=False)

        bn_file = os.path.join(chapters_dir, f"bn_{chapter_id}.json")
        bn_json = {
            "language": "bn",
            "kandaId": ch_data["kandaId"],
            "chapter_number": ch_data["chapterNumber"],
            "chapter_title_bangla": ch_data["chapterTitleBangla"],
            "bangla_text": ch_data["banglaText"],
            "short_summary_bangla": ch_data["shortSummaryBangla"],
            "moral_lesson_bangla": ch_data["moralLessonBangla"],
            "review_status": "needs_native_review",
        }
        with open(bn_file, 'w', encoding='utf-8') as f:
            json.dump(bn_json, f, indent=2, ensure_ascii=False)

        print(f"Split completed for: {chapter_id}")

    print(f"[Step 4] Wrote {len(chapters_db)} chapters as needs_review (no reviewer attribution).")

if __name__ == "__main__":
    main()
