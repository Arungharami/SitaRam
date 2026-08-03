#!/usr/bin/env python3
import os
import sys
import json
import re
import argparse
import glob

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "validation"))
import corpus_rules

def clean_word(word):
    return re.sub(r'[^\w\s]', '', word).lower()

def build_search_index(records_dir, output_file):
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)

    # Simple inverted index: word -> list of sarga IDs
    index = {}
    indexed = 0
    withheld = 0

    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception:
                continue

            # Unverified or placeholder content must never become retrievable
            # by the AI backend.
            if not corpus_rules.is_retrieval_eligible(record):
                withheld += 1
                continue
            indexed += 1

            doc_id = record.get("documentId")
            source_text = record.get("sourceText", "")

            words = source_text.split()
            seen_words = set()
            for w in words:
                cleaned = clean_word(w)
                if cleaned and len(cleaned) > 2:
                    seen_words.add(cleaned)
                    
            for word in seen_words:
                if word not in index:
                    index[word] = []
                index[word].append(doc_id)
                
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(index, f, indent=2, ensure_ascii=False)
        
    print(
        f"Generated search index containing {len(index)} terms from {indexed} retrieval-approved "
        f"record(s) at '{output_file}' ({withheld} unverified record(s) withheld)."
    )

def main():
    parser = argparse.ArgumentParser(description="Build inverted keyword search index for local offline search.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing Sarga records.")
    parser.add_argument("--output", type=str, default="../../assets/indexes/search_index.json", help="Path to save inverted index.")
    args = parser.parse_args()
    
    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.output))
    build_search_index(records_path, output_path)

if __name__ == "__main__":
    main()
