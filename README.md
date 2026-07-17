# SitaRam — Valmiki Ramayana Reader & AI Research App

SitaRam is a devotional and research mobile application designed for clean reading, listening, language study (English, Bangla, Spanish), and source-grounded AI scriptural study of the Valmiki Ramayana.

---

## 🪷 System Architecture & Hybrid RAG

SitaRam integrates a client Flutter mobile app with a Python FastAPI RAG backend hosted on a Hugging Face Space.

- **Offline-First Reading**: Local compiled databases allow full offline scripture reading, notes, and study tracking.
- **Source-Grounded AI**: The AI Guide answers user questions by retrieving relevant passages using hybrid vector + keyword (BM25) search.
- **Safety Refusals**: Strict guardrails prevent the AI from inventing Sanskrit verses, predicting future fortunes, or claiming religious authority.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Python 3.9+](https://www.python.org/downloads/) (for the content import pipeline)

### Installation & Run

1. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```
2. Build and run the app locally:
   ```bash
   flutter run \
     --dart-define=SITARAM_HF_ENDPOINT=https://YOUR-SPACE.hf.space \
     --dart-define=SITARAM_HF_APP_KEY=YOUR_SECRET_APP_KEY
   ```

---

## 🛠️ Content Ingestion Pipeline (`tools/`)

Scriptural data is processed and registered using python scripts under `tools/`.

### 1. Ingestion Sequence
1. **Register Source Edition**:
   ```bash
   python tools/content_import/register_source.py
   ```
2. **Segment Kandas**:
   ```bash
   python tools/content_import/split_kandas.py --file raw_corpus.txt
   ```
3. **Segment Sargas**:
   ```bash
   python tools/content_import/split_sargas.py --file bala_kanda.txt --kanda-id bala_kanda
   ```
4. **Normalize & Clean OCR Noise**:
   ```bash
   python tools/content_import/normalize_text.py
   ```
5. **Generate Schema Records**:
   ```bash
   python tools/content_import/generate_records.py
   ```
6. **Compile Search Index & Embeddings**:
   ```bash
   python tools/indexing/build_search_index.py
   python tools/indexing/build_embeddings.py
   ```
7. **Validate Schema & Provenance**:
   ```bash
   python tools/validation/validate_schema.py
   python tools/validation/check_duplicates.py
   python tools/validation/check_numbering.py
   python tools/validation/check_provenance.py
   ```
8. **Export Approved Assets**:
   ```bash
   python tools/content_import/export_approved.py
   ```

---

## 🐳 Hugging Face Space Deployment

The RAG backend is packaged inside a Docker container for deployment to a Hugging Face Space.

### 1. Environment Variables (Space Secrets)
- `SITARAM_APP_KEY`: secret key matching client app compile token.
- `MODEL_ID`: `Qwen/Qwen2.5-1.5B-Instruct`
- `HF_TOKEN`: Hugging Face authorization token.
- `MAX_CONTEXT_PASSAGES`: default `6`

### 2. Local Backend Run
```bash
cd huggingface_space
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 7860 --reload
```

---

## 🗺️ 7-Kanda Roadmap

1. **Bala Kanda**: Complete verified English translations, Bangla stubs, and audio tracks.
2. **Ayodhya Kanda**: Sarga segmentation, moral insights compilation.
3. **Aranya Kanda**: Forest adventures sarga parsing, demon encounters tagging.
4. **Kishkindha Kanda**: Alliance with monkeys, character network mappings.
5. **Sundara Kanda**: Hanuman's crossing, Lanka search details.
6. **Yuddha Kanda**: War preparations, defeat of Ravana.
7. **Uttara Kanda**: Coronation, return to absolute source.

---

## 📜 Legal and Safety Policy

- **Disclaimer**: AI outputs are educational reflections, not spiritual or religious decrees.
- **Copyright Policy**: We utilize verified public domain translations (like Manmatha Nath Dutt, 1891).
- **Abuse Prevention**: Rate limits, input size checks, and token security enforce API longevity.

---

## 🤝 Contribution Process
Contributions are welcome. Please ensure new Sargas are registered under `tools/content_import/register_source.py` and successfully pass all validation gate scripts prior to creating a pull request.

**Jai Shri Ram**
