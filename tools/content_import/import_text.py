#!/usr/bin/env python3
import os
import argparse

def import_raw_text(file_path, edition_id):
    raw_dir = os.path.join(os.path.dirname(__file__), "data", "raw")
    os.makedirs(raw_dir, exist_ok=True)
    
    if not os.path.exists(file_path):
        print(f"Error: Source file '{file_path}' does not exist.")
        return
        
    filename = os.path.basename(file_path)
    dest_path = os.path.join(raw_dir, f"{edition_id}_{filename}")
    
    with open(file_path, 'r', encoding='utf-8') as src:
        content = src.read()
        
    with open(dest_path, 'w', encoding='utf-8') as dest:
        dest.write(content)
        
    print(f"Successfully imported {filename} into raw folder for edition '{edition_id}'.")

def main():
    parser = argparse.ArgumentParser(description="Import raw public-domain text.")
    parser.add_argument("--file", type=str, required=True, help="Path to raw source text file.")
    parser.add_argument("--edition-id", type=str, default="m_n_dutt_public_domain", help="Registered edition ID.")
    args = parser.parse_args()
    
    import_raw_text(args.file, args.edition_id)

if __name__ == "__main__":
    main()
