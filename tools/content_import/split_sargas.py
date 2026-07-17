#!/usr/bin/env python3
import os
import re
import argparse

def split_sargas(kanda_file, kanda_id):
    sarga_dir = os.path.join(os.path.dirname(__file__), "data", "sargas")
    os.makedirs(sarga_dir, exist_ok=True)
    
    if not os.path.exists(kanda_file):
        print(f"Error: Kanda file '{kanda_file}' does not exist.")
        return

    with open(kanda_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Match common Sarga/Chapter/Section markers: e.g. "SECTION I", "SARGA 1", "CHAPTER 1"
    pattern = r'(?i)(?:sarga|section|chapter)\s+([IVXLCDM\d]+)'
    parts = re.split(pattern, content)
    
    # parts[0] is intro text
    # then pairs of (sarga_num, sarga_text)
    sarga_count = 0
    for i in range(1, len(parts), 2):
        sarga_num_str = parts[i].strip()
        sarga_text = parts[i+1].strip() if i+1 < len(parts) else ""
        
        # Convert Roman numeral to integer if needed or keep as standard
        sarga_id_str = sarga_num_str.zfill(3)
        out_file = os.path.join(sarga_dir, f"{kanda_id}_sarga_{sarga_id_str}.txt")
        with open(out_file, 'w', encoding='utf-8') as out:
            out.write(sarga_text)
        sarga_count += 1
        
    print(f"Split {sarga_count} Sargas for Kanda '{kanda_id}'.")

def main():
    parser = argparse.ArgumentParser(description="Split Kanda text into individual Sargas.")
    parser.add_argument("--file", type=str, required=True, help="Path to Kanda text file.")
    parser.add_argument("--kanda-id", type=str, required=True, help="Kanda ID (e.g. bala_kanda).")
    args = parser.parse_args()
    
    split_sargas(args.file, args.kanda_id)

if __name__ == "__main__":
    main()
