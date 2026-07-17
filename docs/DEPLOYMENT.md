# SitaRam — Deployment Guide

Instructions for building and deploying the Hugging Face Space FastAPI backend.

## Deployment Steps

1. **Hugging Face Space Creation**:
   - Create a new Hugging Face Space at `arun-gharami/SitaRam-ramayana-ai-space`.
   - Set the SDK type to **Docker**.

2. **Configure Secrets**:
   - Add variables under Space settings:
     - `SITARAM_APP_KEY`: secret authorization token matching the Flutter compilation key.
     - `MODEL_ID`: `Qwen/Qwen2.5-1.5B-Instruct`
     - `HF_TOKEN`: your Hugging Face API write token.

3. **Deploy Files**:
   - Commit and push files in the `huggingface_space/` directory:
     - `app.py`
     - `requirements.txt`
     - `Dockerfile`
     - `README.md`
