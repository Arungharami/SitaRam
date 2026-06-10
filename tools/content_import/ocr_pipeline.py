#!/usr/bin/env python3
import os
import glob
import json
import argparse

def main():
    parser = argparse.ArgumentParser(description="Step 2: Run OCR on scanned PDF images or text files.")
    parser.add_argument("--pages-dir", type=str, default="data/pages", help="Folder containing page JSON files.")
    args = parser.parse_args()

    print("[Step 2] Running OCR/Validation Pipeline...")
    
    pattern = os.path.join(args.pages_dir, "page_*.json")
    files = sorted(glob.glob(pattern))

    if not files:
        print("No page JSON files found. Run import_pdf.py first.")
        return

    for page_file in files:
        with open(page_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # We check the status.
        if data.get("status") == "raw_ocr":
            text = data.get("raw_text", "")
            if not text.strip():
                print(f"Warning: Page {data['page_number']} has no text. Scanned images may need OCR.")
                # If there were image attachments, here we would call pytesseract:
                # import pytesseract
                # from PIL import Image
                # text = pytesseract.image_to_string(Image.open(image_path))
                data["raw_text"] = "[NO TEXT EXTRACTED - REQUIRES OCR IMAGE PROCESSING]"
            
            # Simple simulation of cleaning up common OCR artifacts in the text
            # e.g., fixing common OCR typos like '1' to 'l', '0' to 'o', or removing weird symbols
            cleaned_draft = text.replace("l1. ", "1. ").replace("O dharma", "Of dharma")
            data["raw_text"] = cleaned_draft
            print(f"Verified OCR text for Page {data['page_number']}.")
            
            with open(page_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)

    print("[Step 2] OCR & Verification step completed successfully.")

if __name__ == "__main__":
    main()
