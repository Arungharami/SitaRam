#!/usr/bin/env python3
import os
import re
import argparse
import glob

def clean_ocr_text(text):
    # Remove running headers
    text = re.sub(r'(?i)VALMIKI\s+RAMAYANA', '', text)
    text = re.sub(r'(?i)(Bala|Ayodhya|Aranya|Kishkindha|Sundara|Yuddha|Uttara)\s+Kanda', '', text)
    
    # Remove page numbers and brackets
    text = re.sub(r'\[PAGE\s+\d+\]', '', text)
    text = re.sub(r'^\s*\d+\s*$', '', text, flags=re.MULTILINE)
    
    # Standardize whitespace and line endings
    text = re.sub(r'\r\n', '\n', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r' {2,}', ' ', text)
    
    return text.strip()

def main():
    parser = argparse.ArgumentParser(description="Normalize Sarga text files by cleaning OCR noise.")
    parser.add_argument("--sargas-dir", type=str, default="data/sargas", help="Folder containing raw sarga text files.")
    args = parser.parse_args()
    
    sargas_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.sargas_dir))
    pattern = os.path.join(sargas_path, "*.txt")
    files = glob.glob(pattern)
    
    if not files:
        print("No sarga text files found to normalize.")
        return
        
    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            raw = f.read()
        cleaned = clean_ocr_text(raw)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(cleaned)
        print(f"Normalized Sarga file: {os.path.basename(file_path)}")

if __name__ == "__main__":
    main()
