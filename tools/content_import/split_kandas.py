#!/usr/bin/env python3
import os
import re
import argparse

KANDAS_MAP = {
    "bala": "Bala Kanda",
    "ayodhya": "Ayodhya Kanda",
    "aranya": "Aranya Kanda",
    "kishkindha": "Kishkindha Kanda",
    "sundara": "Sundara Kanda",
    "yuddha": "Yuddha Kanda",
    "uttara": "Uttara Kanda"
}

def split_kandas(file_path):
    kanda_dir = os.path.join(os.path.dirname(__file__), "data", "kandas")
    os.makedirs(kanda_dir, exist_ok=True)
    
    if not os.path.exists(file_path):
        print(f"Error: Raw file '{file_path}' does not exist.")
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Look for markers like "BALA KANDA", "AYODHYA KANDA", etc.
    # In practice, this regex splits by section headers.
    parts = re.split(r'(?i)(Bala\s+Kanda|Ayodhya\s+Kanda|Aranya\s+Kanda|Kishkindha\s+Kanda|Sundara\s+Kanda|Yuddha\s+Kanda|Uttara\s+Kanda)', content)
    
    current_kanda = None
    for part in parts:
        normalized = part.strip().lower().replace(" ", "")
        found_key = None
        for key in KANDAS_MAP.keys():
            if key in normalized:
                found_key = key
                break
                
        if found_key:
            current_kanda = found_key
            continue
            
        if current_kanda and part.strip():
            kanda_name = KANDAS_MAP[current_kanda]
            out_file = os.path.join(kanda_dir, f"{current_kanda}_kanda.txt")
            with open(out_file, 'w', encoding='utf-8') as out:
                out.write(part.strip())
            print(f"Extracted {kanda_name} to {out_file}")

def main():
    parser = argparse.ArgumentParser(description="Split raw corpus into canonical Kandas.")
    parser.add_argument("--file", type=str, required=True, help="Path to raw merged text file.")
    args = parser.parse_args()
    
    split_kandas(args.file)

if __name__ == "__main__":
    main()
