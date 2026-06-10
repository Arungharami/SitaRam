#!/usr/bin/env python3
import os
import sys
import json
import argparse

# Expanded 6 chapters across Kandas
SAMPLE_PAGES = [
    {
        "page_number": 1,
        "raw_text": "[PAGE 1]\nVALMIKI RAMAYANA\nBALA KANDA\nCHAPTER 1: Valmiki and Narada\n\n1. The ascetic Valmiki asked Narada, the chief of sages, pre-eminent in virtuous learning: 'Who is there in the world today who is righteous, heroic, and truthful?'\n2. Narada, who knows the events of all three worlds, heard Valmiki's words and replied with joy: 'Listen, I will tell you of a man who possesses all these rare qualities, born in the Ikshvaku line, named Rama.'",
        "notes": "Bala Kanda Chapter 1 Page 1"
    },
    {
        "page_number": 2,
        "raw_text": "[PAGE 2]\nVALMIKI RAMAYANA\nBALA KANDA\nCHAPTER 2: The Birth of Verse\n\n1. Valmiki went to the banks of the river Tamasa. He beheld a pair of Krauncha birds singing sweetly.\n2. Suddenly, a wicked hunter killed the male bird. Seeing the female bird wail in grief, Valmiki was moved to deep compassion and uttered: 'Ma Nishada...' - which became the first verse (shloka) of literature.",
        "notes": "Bala Kanda Chapter 2 Page 2"
    },
    {
        "page_number": 3,
        "raw_text": "[PAGE 3]\nVALMIKI RAMAYANA\nBALA KANDA\nCHAPTER 3: The Great Theme\n\n1. Brahma commanded Valmiki to write the complete history of Rama. Valmiki sat in meditation and saw the entire story of Rama, Lakshmana, and Sita as clearly as a fruit in his hand.\n2. He began to compose the sacred poem, detailing Rama's birth, education, and his protection of Vishwamitra's sacrifice.",
        "notes": "Bala Kanda Chapter 3 Page 3"
    },
    {
        "page_number": 4,
        "raw_text": "[PAGE 4]\nVALMIKI RAMAYANA\nAYODHYA KANDA\nCHAPTER 1: Rama's Exile\n\n1. King Dasaratha, wishing to retire, announced the coronation of Rama. Ayodhya rejoiced. However, Queen Kaikeyi, poisoned by her maid Manthara, demanded two boons.\n2. She demanded that her son Bharata be crowned, and Rama be exiled to the Dandaka forest for fourteen years. To keep his father's word truthful, Rama cheerfully accepted the exile.",
        "notes": "Ayodhya Kanda Chapter 1 Page 4"
    },
    {
        "page_number": 5,
        "raw_text": "[PAGE 5]\nVALMIKI RAMAYANA\nARANYA KANDA\nCHAPTER 1: Sita's Abduction\n\n1. In the Panchavati forest, the demon king Ravana plotted to kidnap Sita. He sent Maricha in the guise of a golden deer. Rama went to hunt the deer, and Lakshmana went to help Rama.\n2. Left alone, Sita was approached by Ravana disguised as an ascetic. He forcibly seized her and carried her away in his aerial chariot Pushpaka towards Lanka.",
        "notes": "Aranya Kanda Chapter 1 Page 5"
    },
    {
        "page_number": 6,
        "raw_text": "[PAGE 6]\nVALMIKI RAMAYANA\nSUNDARA KANDA\nCHAPTER 1: Hanuman's Devotion\n\n1. Hanuman resolved to cross the ocean to Lanka in search of Sita. He expanded his body, invoked Rama's name, and leapt from Mount Mahendra into the sky.\n2. Facing many obstacles, Hanuman flew with unyielding devotion, successfully landing on the shores of Lanka to bring hope to Sita.",
        "notes": "Sundara Kanda Chapter 1 Page 6"
    }
]

def main():
    parser = argparse.ArgumentParser(description="Step 1: Import Valmiki Ramayana PDF or bootstrap sample pages.")
    parser.add_argument("--pdf", type=str, help="Path to Valmiki Ramayana PDF file.")
    parser.add_argument("--output-dir", type=str, default="data/pages", help="Output folder to store extracted pages.")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    print("[Step 1] Initializing PDF Import Pipeline (Professional Upgrade)...")
    
    if args.pdf:
        if not os.path.exists(args.pdf):
            print(f"Error: PDF file '{args.pdf}' not found. Falling back to bootstrap sample data.")
            bootstrap_samples(args.output_dir)
        else:
            try:
                import pypdf
                print(f"Extracting text from PDF: {args.pdf}")
                extract_pdf_pages(args.pdf, args.output_dir)
            except ImportError:
                print("Warning: 'pypdf' package not installed. Cannot extract text directly.")
                print("Falling back to bootstrap sample data to demonstrate the pipeline.")
                bootstrap_samples(args.output_dir)
    else:
        print("No PDF specified. Bootstrapping with Valmiki Ramayana sample pages...")
        bootstrap_samples(args.output_dir)

    print(f"[Step 1] PDF Import complete. Pages are in '{args.output_dir}'.")

def bootstrap_samples(output_dir):
    for sp in SAMPLE_PAGES:
        page_file = os.path.join(output_dir, f"page_{sp['page_number']:03d}.json")
        page_data = {
            "page_number": sp["page_number"],
            "status": "raw_ocr",
            "raw_text": sp["raw_text"],
            "cleaned_text": "",
            "source_metadata": {
                "source_title": "Valmiki Ramayana (Ingestion Standard)",
                "author_translator": "M. N. Dutt (Public Domain)",
                "publication_year": 1891,
                "copyright_status": "public_domain_or_user_verified",
                "source_url": "https://archive.org/details/valmikiramayana",
                "notes": sp["notes"],
                "reviewer_name": None,
                "approval_date": None
            }
        }
        with open(page_file, 'w', encoding='utf-8') as f:
            json.dump(page_data, f, indent=2, ensure_ascii=False)
        print(f"Created bootstrap page: {page_file}")

def extract_pdf_pages(pdf_path, output_dir):
    import pypdf
    reader = pypdf.PdfReader(pdf_path)
    total_pages = len(reader.pages)
    print(f"Processing PDF '{pdf_path}' with {total_pages} pages...")
    
    for idx, page in enumerate(reader.pages):
        page_num = idx + 1
        text = page.extract_text() or ""
        page_file = os.path.join(output_dir, f"page_{page_num:03d}.json")
        
        page_data = {
            "page_number": page_num,
            "status": "raw_ocr",
            "raw_text": text,
            "cleaned_text": "",
            "source_metadata": {
                "source_title": "Valmiki Ramayana PDF",
                "author_translator": "Unknown Translator",
                "publication_year": None,
                "copyright_status": "public_domain_or_user_verified",
                "source_url": f"local://{os.path.basename(pdf_path)}",
                "notes": f"Extracted text from page {page_num}",
                "reviewer_name": None,
                "approval_date": None
            }
        }
        with open(page_file, 'w', encoding='utf-8') as f:
            json.dump(page_data, f, indent=2, ensure_ascii=False)
        print(f"Extracted page {page_num}/{total_pages} -> {page_file}")

if __name__ == "__main__":
    main()
