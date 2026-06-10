#!/usr/bin/env python3
import os
import json
import sys
import argparse

def validate_chapter(chapter, idx):
    required_keys = [
        "id", "kandaId", "kanda", "chapterNumber", "chapterTitleEnglish", 
        "chapterTitleBangla", "englishText", "banglaText", "shortSummaryEnglish", 
        "shortSummaryBangla", "moralLessonEnglish", "moralLessonBangla", 
        "characters", "themes", "sourceTitle", "sourceStatus", "reviewStatus", 
        "audioEnglish", "audioBangla"
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
            
    return True

def main():
    parser = argparse.ArgumentParser(description="Validate production Ramayana JSON schema.")
    parser.add_argument("--file", type=str, default="../../assets/content/ramayana_chapters.json", help="Path to JSON file.")
    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"Error: File '{args.file}' does not exist.")
        sys.exit(1)

    print(f"Validating production JSON: {args.file}")
    
    try:
        with open(args.file, 'r', encoding='utf-8') as f:
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
