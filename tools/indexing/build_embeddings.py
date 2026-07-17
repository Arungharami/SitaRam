#!/usr/bin/env python3
import os
import json
import argparse
import glob

def build_embeddings(records_dir, output_file, model_name):
    # In production, this would import sentence_transformers and build embeddings.
    # To keep dependencies light and runnable anywhere, we provide the mock structure
    # that can be easily executed or updated on Hugging Face Space.
    pattern = os.path.join(records_dir, "*.json")
    files = glob.glob(pattern)
    
    embeddings_data = []
    
    print(f"Loading embedding model: {model_name}...")
    try:
        from sentence_transformers import SentenceTransformer
        model = SentenceTransformer(model_name)
        use_real = True
    except ImportError:
        print("sentence-transformers not installed. Generating mock embeddings placeholders.")
        use_real = False
        
    for file_path in files:
        with open(file_path, 'r', encoding='utf-8') as f:
            try:
                record = json.load(f)
            except Exception:
                continue
            doc_id = record.get("documentId")
            source_text = record.get("sourceText", "")
            
            if use_real:
                vector = model.encode(source_text).tolist()
            else:
                vector = [0.0] * 384 # mock 384-dimensional vector
                
            embeddings_data.append({
                "documentId": doc_id,
                "text": source_text,
                "vector": vector,
                "kandaId": record.get("kandaId"),
                "sargaNumber": record.get("sargaNumber")
            })
            
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(embeddings_data, f, indent=2, ensure_ascii=False)
        
    print(f"Generated embeddings for {len(embeddings_data)} Sargas at '{output_file}'.")

def main():
    parser = argparse.ArgumentParser(description="Generate embeddings vectors for hybrid RAG search.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing Sarga records.")
    parser.add_argument("--output", type=str, default="../../assets/indexes/embeddings.json", help="Path to save embeddings index.")
    parser.add_argument("--model", type=str, default="all-MiniLM-L6-v2", help="Hugging Face embedding model name.")
    args = parser.parse_args()
    
    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.output))
    build_embeddings(records_path, output_path, args.model)

if __name__ == "__main__":
    main()
