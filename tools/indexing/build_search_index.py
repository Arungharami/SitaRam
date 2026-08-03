#!/usr/bin/env python3
"""
Builds the offline keyword index.

Only retrieval-approved content is indexed. Both record shapes are gated through
tools/validation/corpus_loader.py, so an imported-but-unreviewed passage can
never become searchable, and revoking approval removes it on the next rebuild.
"""
import os
import sys
import json
import re
import argparse

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "validation"))
import corpus_loader


def clean_word(word):
    return re.sub(r'[^\w\s]', '', word).lower()


def build_search_index(output_file, records_dir=None, passages_dir=None, registry_path=None):
    eligible, withheld = corpus_loader.retrieval_eligible(records_dir, passages_dir, registry_path)

    index = {}
    for item in eligible:
        doc_id = item["id"]
        seen_words = set()
        for w in (item["text"] or "").split():
            cleaned = clean_word(w)
            if cleaned and len(cleaned) > 2:
                seen_words.add(cleaned)
        for word in seen_words:
            index.setdefault(word, []).append(doc_id)

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(index, f, indent=2, ensure_ascii=False)

    print(
        "Generated search index containing %d terms from %d retrieval-approved item(s) "
        "at '%s' (%d unapproved item(s) withheld)."
        % (len(index), len(eligible), output_file, withheld)
    )
    return index


def main():
    parser = argparse.ArgumentParser(description="Build inverted keyword search index for local offline search.")
    parser.add_argument("--records-dir", type=str, default=None, help="Directory containing legacy v1 Sarga records.")
    parser.add_argument("--passages-dir", type=str, default=None, help="Directory containing v2 passage records.")
    parser.add_argument("--registry", type=str, default=None, help="Source registry path.")
    parser.add_argument("--output", type=str, default="../../assets/indexes/search_index.json", help="Path to save inverted index.")
    args = parser.parse_args()

    output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.output))
    build_search_index(output_path, args.records_dir, args.passages_dir, args.registry)


if __name__ == "__main__":
    main()
