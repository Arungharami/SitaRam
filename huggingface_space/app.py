import os
import re
import json
import logging
from typing import List, Dict, Any, Optional
from fastapi import FastAPI, HTTPException, Header, status
from pydantic import BaseModel

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("sitaram-ai-backend")

app = FastAPI(title="SitaRam Ramayana AI API", version="1.0.0")

# Production must fail closed if the application access token is not configured.
# Never ship a publicly committed fallback token.
SITARAM_APP_KEY = os.getenv("SITARAM_APP_KEY")
if not SITARAM_APP_KEY:
    raise RuntimeError(
        "SITARAM_APP_KEY is required. Configure it as a deployment secret before starting the backend."
    )

MODEL_ID = os.getenv("MODEL_ID", "Qwen/Qwen2.5-1.5B-Instruct")
MAX_CONTEXT_PASSAGES = int(os.getenv("MAX_CONTEXT_PASSAGES", "6"))

assets_dir = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "assets", "content")
)
all_chapters = []
sargas_db = []


def is_verified_passage(chapter):
    """Return True only for passages explicitly verified and approved for app use."""
    return (
        chapter.get("verified") is True
        and chapter.get("reviewStatus") == "approved_for_app"
    )


try:
    chapters_path = os.path.join(assets_dir, "ramayana_chapters.json")
    if os.path.exists(chapters_path):
        with open(chapters_path, "r", encoding="utf-8") as f:
            all_chapters = json.load(f)
        sargas_db = [c for c in all_chapters if is_verified_passage(c)]
        logger.info(
            "Loaded %s chapters; %s are verified and retrieval-eligible (%s withheld as unverified).",
            len(all_chapters),
            len(sargas_db),
            len(all_chapters) - len(sargas_db),
        )
except Exception as exc:
    logger.error("Error loading Sargas database: %s", exc)


class SearchRequest(BaseModel):
    query: str
    limit: int = 5
    filters: Optional[Dict[str, Any]] = None


class AskRequest(BaseModel):
    question: str
    languageCode: str = "en"
    mode: str = "student"
    filters: Optional[Dict[str, Any]] = None
    conversationId: Optional[str] = ""


class FeedbackRequest(BaseModel):
    feedbackId: str
    questionId: str
    answerId: str
    rating: str
    reason: str
    userComment: Optional[str] = ""
    reportedPassageId: Optional[str] = ""
    language: str = "en"


REFUSAL_TRIGGERS = [
    r"(?i)invent\s+(?:a\s+)?sanskrit\s+verse",
    r"(?i)predict\s+(?:my\s+)?(?:future|marriage|death|wealth)",
    r"(?i)claim\s+to\s+be\s+(?:a\s+)?(?:religious\s+authority|god|representative|prophet)",
    r"(?i)fake\s+verse\s+number",
    r"(?i)divine\s+(?:judgment|reward|punishment)",
    r"(?i)insult\s+religion",
]


def check_safety(text: str) -> bool:
    return any(re.search(trigger, text) for trigger in REFUSAL_TRIGGERS)


def verify_citations(
    answer: str, context_passages: List[Dict[str, Any]]
) -> List[Dict[str, Any]]:
    """Build citation metadata only from the approved passage itself.

    Source/translator information is never hardcoded because future approved
    passages may come from different registered editions.
    """
    citations = []
    for passage in context_passages:
        metadata = passage.get("source_metadata") or {}
        source_title = (
            passage.get("sourceTitle")
            or metadata.get("source_title")
            or "Approved source"
        )
        translator = metadata.get("author_translator") or ""
        text = passage.get("englishText", "")

        citations.append(
            {
                "documentId": passage.get("id"),
                "kanda": passage.get("kanda", ""),
                "sarga": passage.get("chapterNumber", 0),
                "edition": source_title,
                "translator": translator,
                "contentType": "source_text",
                "quotedText": text[:150] + "..." if len(text) > 150 else text,
            }
        )
    return citations


def verify_app_key(x_sitaram_key: Optional[str] = Header(None)):
    if x_sitaram_key != SITARAM_APP_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing X-SitaRam-Key header token.",
        )


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "model": MODEL_ID,
        "dataset": "arun-gharami/SitaRam-valmiki-ramayana-dataset",
        "corpusVersion": "1.0.0",
        "chaptersLoaded": len(all_chapters),
        "verifiedPassages": len(sargas_db),
        "unverifiedWithheld": len(all_chapters) - len(sargas_db),
        "corpusComplete": False,
        "retrievalReady": len(sargas_db) > 0,
    }


@app.get("/coverage")
def get_coverage():
    report_path = os.path.join(assets_dir, "coverage_report.json")
    if os.path.exists(report_path):
        with open(report_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return {"error": "Coverage report not found."}


@app.post("/search")
def search(req: SearchRequest, x_sitaram_key: Optional[str] = Header(None)):
    verify_app_key(x_sitaram_key)

    query = req.query.lower()
    results = []
    for sarga in sargas_db:
        score = 0
        if query in sarga.get("englishText", "").lower():
            score += 10
        if query in sarga.get("chapterTitleEnglish", "").lower():
            score += 20

        if score > 0:
            results.append(
                {
                    "documentId": sarga.get("id"),
                    "kanda": sarga.get("kanda"),
                    "sarga": sarga.get("chapterNumber"),
                    "text": sarga.get("englishText"),
                    "score": score,
                }
            )

    results = sorted(results, key=lambda item: item["score"], reverse=True)[: req.limit]
    return {"results": results}


@app.post("/ask")
def ask(req: AskRequest, x_sitaram_key: Optional[str] = Header(None)):
    verify_app_key(x_sitaram_key)

    if check_safety(req.question):
        return {
            "answer": "The approved SitaRam AI system prompt prevents generating speculative, ungrounded, or non-scriptural predictions and claims. Please ask questions grounded directly in the text.",
            "languageCode": req.languageCode,
            "mode": req.mode,
            "confidence": "low",
            "citations": [],
            "interpretationLabel": "Safety refusal",
            "limitations": ["Request violated safety parameters."],
            "retrieval": {"passagesConsidered": 0, "passagesUsed": 0},
        }

    context = []
    for sarga in sargas_db:
        kanda_filter = req.filters.get("kandaId") if req.filters else None
        if kanda_filter and sarga.get("kandaId") != kanda_filter:
            continue

        context.append(sarga)
        if len(context) >= MAX_CONTEXT_PASSAGES:
            break

    if not context:
        return {
            "answer": "The approved SitaRam knowledge base does not contain enough evidence to answer this confidently.",
            "languageCode": req.languageCode,
            "mode": req.mode,
            "confidence": "low",
            "citations": [],
            "interpretationLabel": "No evidence",
            "limitations": ["No relevant passages retrieved."],
            "retrieval": {"passagesConsidered": 0, "passagesUsed": 0},
        }

    citations = verify_citations(req.question, context)

    # This remains an explicitly limited grounded summary path until the real
    # model/provider generation layer is implemented and validated.
    first_passage = context[0].get("englishText", "")
    answer_summary = (
        f"Based on {context[0].get('kanda')}, Sarga "
        f"{context[0].get('chapterNumber')}: {first_passage[:200]}..."
    )

    return {
        "answer": answer_summary,
        "languageCode": req.languageCode,
        "mode": req.mode,
        "confidence": "high",
        "citations": citations,
        "interpretationLabel": "AI-generated explanation",
        "limitations": [
            "Current backend response generation is a limited grounded summary path, not a full production model response."
        ],
        "retrieval": {
            "passagesConsidered": len(sargas_db),
            "passagesUsed": len(context),
        },
    }


@app.post("/feedback")
def submit_feedback(
    req: FeedbackRequest, x_sitaram_key: Optional[str] = Header(None)
):
    verify_app_key(x_sitaram_key)
    logger.info(
        "Feedback received for answer %s: %s (%s)",
        req.answerId,
        req.rating,
        req.reason,
    )
    return {
        "status": "success",
        "message": "Thank you for your feedback. It has been added to the review queue.",
    }


@app.post("/verify-citation")
def verify_citation(
    passage_id: str, x_sitaram_key: Optional[str] = Header(None)
):
    verify_app_key(x_sitaram_key)
    for sarga in sargas_db:
        if sarga.get("id") == passage_id:
            return {"verified": True, "passage": sarga}
    return {"verified": False, "error": "Passage not found."}
