import os
from typing import Any

from fastapi import FastAPI, Header, HTTPException
from huggingface_hub import InferenceClient
from pydantic import BaseModel, Field

APP_KEY = os.getenv("SITARAM_APP_KEY", "").strip()
HF_TOKEN = os.getenv("HF_TOKEN", "").strip() or None
MODEL_ID = os.getenv("MODEL_ID", "Qwen/Qwen2.5-1.5B-Instruct").strip()

app = FastAPI(
    title="SitaRam Ramayana AI",
    version="1.0.0",
    description="Source-grounded multilingual learning API for the SitaRam app.",
)

client = InferenceClient(model=MODEL_ID, token=HF_TOKEN)


class ChapterContext(BaseModel):
    id: str = ""
    kanda: str = ""
    chapter_number: int = 0
    title_en: str = ""
    title_bn: str = ""
    title_es: str = ""
    text_en: str = ""
    text_bn: str = ""
    text_es: str = ""
    summary_en: str = ""
    summary_bn: str = ""
    summary_es: str = ""
    lesson_en: str = ""
    lesson_bn: str = ""
    lesson_es: str = ""
    characters: list[str] = Field(default_factory=list)
    themes: list[str] = Field(default_factory=list)
    source_title: str = ""
    source_status: str = ""
    review_status: str = ""


class AskRequest(BaseModel):
    question: str = Field(min_length=1, max_length=1500)
    language_code: str = Field(default="en", pattern="^(en|bn|es)$")
    selected_passage: str | None = Field(default=None, max_length=6000)
    chapter: ChapterContext


def _language_instruction(code: str) -> str:
    return {
        "bn": "Answer entirely in Bengali using বাংলা script.",
        "es": "Answer entirely in Spanish.",
        "en": "Answer in clear English.",
    }[code]


def _build_messages(payload: AskRequest) -> list[dict[str, str]]:
    chapter = payload.chapter
    system = f"""
You are SitaRam AI, a respectful educational guide to the Valmiki Ramayana.

Rules:
1. Use the supplied approved chapter context as the primary evidence.
2. Never invent Sanskrit verses, verse numbers, quotations, genealogies, places, or events.
3. When the context is insufficient, clearly say so.
4. Separate source-grounded explanation from any general background knowledge.
5. Cite the Kanda, chapter number, chapter title, and source title in the answer.
6. Keep the response suitable for learning and reflection, not as a religious ruling.
7. {_language_instruction(payload.language_code)}
""".strip()

    context: dict[str, Any] = chapter.model_dump()
    user = f"""
APPROVED CHAPTER CONTEXT
{context}

SELECTED PASSAGE
{payload.selected_passage or '[No passage selected]'}

QUESTION
{payload.question}
""".strip()

    return [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]


@app.get("/")
def root() -> dict[str, str]:
    return {
        "service": "SitaRam Ramayana AI",
        "status": "ready",
        "model": MODEL_ID,
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "model": MODEL_ID}


@app.post("/ask")
def ask(
    payload: AskRequest,
    x_sitaram_key: str | None = Header(default=None),
) -> dict[str, str]:
    if APP_KEY and x_sitaram_key != APP_KEY:
        raise HTTPException(status_code=401, detail="Invalid app key")

    if payload.chapter.review_status != "approved_for_app":
        raise HTTPException(
            status_code=422,
            detail="Only approved chapter content may be used for live AI.",
        )

    try:
        output = client.chat_completion(
            messages=_build_messages(payload),
            max_tokens=700,
            temperature=0.2,
        )
        answer = output.choices[0].message.content.strip()
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Model inference unavailable: {type(exc).__name__}",
        ) from exc

    if not answer:
        raise HTTPException(status_code=503, detail="The model returned an empty answer.")

    return {
        "answer": answer,
        "model": MODEL_ID,
        "source_mode": "approved_chapter_context",
    }
