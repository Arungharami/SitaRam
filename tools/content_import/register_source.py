#!/usr/bin/env python3
import os
import json
import argparse

def register_source(edition_id, title, translator, publication_year, copyright_status, source_url, notes):
    sources_file = os.path.join(os.path.dirname(__file__), "data", "sources.json")
    os.makedirs(os.path.dirname(sources_file), exist_ok=True)
    
    sources = {}
    if os.path.exists(sources_file):
        try:
            with open(sources_file, 'r', encoding='utf-8') as f:
                sources = json.load(f)
        except json.JSONDecodeError:
            pass

    sources[edition_id] = {
        "editionId": edition_id,
        "title": title,
        "translator": translator,
        "publicationYear": publication_year,
        "copyrightStatus": copyright_status,
        "sourceUrl": source_url,
        "notes": notes
    }

    with open(sources_file, 'w', encoding='utf-8') as f:
        json.dump(sources, f, indent=2, ensure_ascii=False)
    print(f"Source edition '{edition_id}' registered successfully.")

def main():
    parser = argparse.ArgumentParser(description="Register a source edition for SitaRam app ingestion.")
    parser.add_argument("--id", type=str, default="m_n_dutt_public_domain", help="Unique identifier of the edition.")
    parser.add_argument("--title", type=str, default="Valmiki Ramayana", help="Title of the source work.")
    parser.add_argument("--translator", type=str, default="Manmatha Nath Dutt", help="Translator name.")
    parser.add_argument("--year", type=int, default=1891, help="Year of publication.")
    parser.add_argument("--copyright", type=str, default="public_domain", help="Copyright status.")
    parser.add_argument("--url", type=str, default="https://archive.org/details/valmikiramayana", help="Source URL.")
    parser.add_argument("--notes", type=str, default="Manmatha Nath Dutt prose translation of Valmiki Ramayana.", help="Additional notes.")
    args = parser.parse_args()

    register_source(args.id, args.title, args.translator, args.year, args.copyright, args.url, args.notes)

if __name__ == "__main__":
    main()
