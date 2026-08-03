#!/usr/bin/env python3
"""
Builds the vector index for hybrid RAG search.

Only retrieval-approved content is embedded. Both record shapes are gated
through tools/validation/corpus_loader.py, so unreviewed passages never enter
the vector store, and revoking approval removes them on the next rebuild.
"""
import os
import sys
import json
import argparse

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "validation"))
import corpus_loader


def build_embeddings(output_file, model_name, records_dir=None, passages_dir=None, registry_path=None):
    eligible, withheld = corpus_loader.retrieval_eligible(records_dir, passages_dir, registry_path)

    print("Loading embedding model: %s..." % model_name)
    try:
        from sentence_transformers import SentenceTransformer
        model = SentenceTransformer(model_name)
        use_real = True
    except ImportError:
        print("sentence-transformers not installed. Generating mock embedding placeholders.")
        use_real = False

    embeddings_data = []
    for item in eligible:
        text = item["text"] or ""
        vector = model.encode(text).tolist() if use_real else [0.0] * 384
        embeddings_data.append({
            "documentId": item["id"],
            "text": text,
            "vector": vector,
            "kandaId": item.get("kandaId"),
            "sargaNumber": item.get("sargaNumber"),
            "schema": item.get("schema"),
        })

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(embeddings_data, f, indent=2, ensure_ascii=False)

    print(
        "Generated embeddings for %d retrieval-approved item(s) at '%s' "
        "(%d unapproved item(s) withheld)."
        % (len(embeddings_data), output_file, withheld)
    )
    return embeddings_data


def main():
    parser = argparse.ArgumentParser(description="Generate embeddings vectors for hybrid RAG search.")
    parser.add_argument("--records-dir", type=str, default=None, help="Directory containing legacy v1 Sarga records.")
    parser.add_argument("--passages-dir", type=str, default=None, help="Directory containing v2 passage records.")
    parser.add_argument("--registry", type=str, default=None, help="Source registry path.")
    parser.add_argument("--output", type=str, default="../../assets/indexes/embeddings.json", help="Path to save embeddings index.")
    parser.add_argument("--model", type=str, default="all-MiniLM-L6-v2", help="Hugging Face embedding model name.")
    args = parser.parse_args()

    output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.output))
    build_embeddings(output_path, args.model, args.records_dir, args.passages_dir, args.registry)


if __name__ == "__main__":
    main()
