---
title: SitaRam Ramayana AI
emoji: 🪷
colorFrom: orange
colorTo: red
sdk: docker
app_port: 7860
pinned: false
license: apache-2.0
---

# SitaRam Ramayana AI

A source-grounded multilingual AI backend for the SitaRam Flutter app.

## Architecture

The Flutter app sends only the currently approved chapter context and the user's question. The Space calls a Hugging Face text-generation model and returns an educational answer in English, Bengali, or Spanish.

The backend rejects chapters whose `review_status` is not `approved_for_app`. The prompt also instructs the model not to invent verses, verse numbers, quotations, genealogies, locations, or unsupported events.

## Recommended Space secrets and variables

Add these in **Space Settings → Variables and secrets**:

- Secret `HF_TOKEN`: Hugging Face access token used only by the Space.
- Secret `SITARAM_APP_KEY`: optional shared key expected in `X-SitaRam-Key`.
- Variable `MODEL_ID`: defaults to `Qwen/Qwen2.5-1.5B-Instruct`.

For better answers, use a larger compatible instruct model through an Inference Endpoint and update `MODEL_ID`. Test Bengali and Spanish quality before production release.

## Local test

```bash
cd huggingface_space
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 7860
```

Health check:

```bash
curl http://localhost:7860/health
```

## Flutter release configuration

Build the app with the deployed Space endpoint:

```bash
flutter build appbundle --release \
  --dart-define=SITARAM_HF_ENDPOINT=https://YOUR-SPACE.hf.space \
  --dart-define=SITARAM_HF_APP_KEY=YOUR_SHARED_APP_KEY
```

Do not put `HF_TOKEN` in Flutter, GitHub, source code, or the Play Store bundle.

## Important limitation

This backend improves explanation and navigation; it does not make incomplete source content complete. The verified Ramayana corpus must be expanded separately through the repository's content import and human-review workflow.
