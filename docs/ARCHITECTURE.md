# SitaRam — System Architecture

SitaRam is composed of a Flutter client mobile app and a Python FastAPI backend deployed to a Hugging Face Space using Hybrid RAG.

```
       ┌────────────────┐
       │  Flutter Client│
       └───────┬────────┘
               │ HTTP Post (X-SitaRam-Key)
               ▼
       ┌────────────────┐
       │ FastAPI Backend│ (Hugging Face Space)
       └───────┬────────┘
               ├──────────────────────────┐
               ▼                          ▼
      ┌─────────────────┐        ┌─────────────────┐
      │  BM25 Inverted  │        │ Vector Embedd.  │ (all-MiniLM-L6-v2)
      │  Search Index   │        │     Index       │
      └─────────────────┘        └─────────────────┘
```

## Core Modules

### 1. Ingestion Pipeline (`tools/`)
- Normalizes and segmentates raw texts into canonical Sargas.
- Calculates Kanda/Sarga progress metrics in a coverage report.
- Produces search inverted term-lists and vector embeddings.

### 2. RAG API Backend (`huggingface_space/`)
- Secures access using environment-defined `SITARAM_APP_KEY`.
- Runs hybrid BM25 and vector similarity ranking.
- Generates answers using `Qwen2.5-1.5B-Instruct` grounded strictly in source passages.
- Validates that citations exist inside context texts before outputting.

### 3. Flutter Client (`lib/`)
- Interactive scripture viewer with multi-language tabs.
- Offline-first cache (reflection notes, bookmarks, offline stubs).
- AI Q&A window syncing with the currently active chapter.
