#!/usr/bin/env python3
import os
import sys
import json
import argparse

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "validation"))
import corpus_rules

def validate_chapter(chapter, idx):
    required_keys = [
        "id", "kandaId", "kanda", "chapterNumber", "chapterTitleEnglish",
        "chapterTitleBangla", "englishText", "banglaText", "shortSummaryEnglish",
        "shortSummaryBangla", "moralLessonEnglish", "moralLessonBangla",
        "characters", "themes", "sourceTitle", "sourceStatus", "reviewStatus",
        "verified", "audioEnglish", "audioBangla"
    ]

    missing = [key for key in required_keys if key not in chapter]
    if missing:
        print(f"Error: Chapter at index {idx} (ID: {chapter.get('id', 'unknown')}) is missing keys: {missing}")
        return False

    # Check audio structures
    for aud_key in ["audioEnglish", "audioBangla"]:
        aud = chapter[aud_key]
        required_audio = ["chapter_id", "language", "voice_type", "audio_file", "duration", "status"]
        missing_audio = [key for key in required_audio if key not in aud]
        if missing_audio:
            print(f"Error: Chapter {chapter['id']} in {aud_key} is missing keys: {missing_audio}")
            return False

    review_status = chapter.get("reviewStatus")
    if review_status not in corpus_rules.VALID_REVIEW_STATUSES:
        print(f"Error: Chapter {chapter['id']} has unrecognized reviewStatus '{review_status}'.")
        return False

    # The verified flag must never claim more than the review status supports.
    verified = chapter.get("verified")
    if not isinstance(verified, bool):
        print(f"Error: Chapter {chapter['id']} 'verified' must be a boolean, got {verified!r}.")
        return False
    if verified and review_status != "approved_for_app":
        print(
            f"Error: Chapter {chapter['id']} is marked verified but reviewStatus is "
            f"'{review_status}', not 'approved_for_app'."
        )
        return False

    return True

def main():
    parser = argparse.ArgumentParser(description="Validate production Ramayana JSON schema.")
    parser.add_argument("--file", type=str, default="../../assets/content/ramayana_chapters.json", help="Path to JSON file.")
    args = parser.parse_args()
    file_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.file))
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' does not exist.")
        sys.exit(1)

    print(f"Validating production JSON: {file_path}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: Not valid JSON. {e}")
        sys.exit(1)

    if not isinstance(data, list):
        print("Error: Root must be a list of chapters.")
        sys.exit(1)

    all_valid = True
    for idx, chapter in enumerate(data):
        if not validate_chapter(chapter, idx):
            all_valid = False

    if all_valid:
        print(f"Success! All {len(data)} chapters conform to the production schema.")
        sys.exit(0)
    else:
        print("Validation failed.")
        sys.exit(1)

if __name__ == "__main__":
    main()
