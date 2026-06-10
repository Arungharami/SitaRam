#!/usr/bin/env python3
import os
import glob
import json
import re
import argparse

def clean_ocr_text(text):
    """
    Standard clean-up rules for raw OCR text of Valmiki Ramayana.
    """
    # 1. Remove running headers like "VALMIKI RAMAYANA" or "BALA KANDA"
    text = re.sub(r'(?i)VALMIKI\s+RAMAYANA', '', text)
    text = re.sub(r'(?i)BALA\s+KANDA', '', text)
    
    # 2. Remove page labels like [PAGE 1], [PAGE 2], or standalone page numbers
    text = re.sub(r'\[PAGE\s+\d+\]', '', text)
    text = re.sub(r'^\s*\d+\s*$', '', text, flags=re.MULTILINE)
    
    # 3. Clean up multiple empty lines and excessive spaces
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r' {2,}', ' ', text)
    
    return text.strip()

def main():
    parser = argparse.ArgumentParser(description="Step 3: Clean text by removing running headers, page numbers, and formatting issues.")
    parser.add_argument("--pages-dir", type=str, default="data/pages", help="Folder containing page JSON files.")
    args = parser.parse_args()

    print("[Step 3] Cleaning OCR text and headers...")
    
    pattern = os.path.join(args.pages_dir, "page_*.json")
    files = sorted(glob.glob(pattern))

    if not files:
        print("No page JSON files found. Run import_pdf.py first.")
        return

    cleaned_count = 0
    for page_file in files:
        with open(page_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if data.get("status") == "raw_ocr":
            raw = data.get("raw_text", "")
            cleaned = clean_ocr_text(raw)
            
            data["cleaned_text"] = cleaned
            data["status"] = "cleaned"
            cleaned_count += 1
            print(f"Cleaned page {data['page_number']} -> Status: cleaned.")
            
            with open(page_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
        else:
            print(f"Skipping page {data['page_number']} (already in state: {data.get('status')})")

    print(f"[Step 3] Cleaned {cleaned_count} pages.")

if __name__ == "__main__":
    main()
