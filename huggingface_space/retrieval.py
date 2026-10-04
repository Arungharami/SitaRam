"""Deterministic lexical retrieval; no model or provider dependency."""
import re

STOP_WORDS = frozenset({
    "a", "an", "and", "are", "as", "at", "be", "by", "did", "do", "does",
    "for", "from", "how", "in", "is", "it", "of", "on", "or", "please",
    "the", "this", "to", "was", "were", "what", "when", "where", "who", "why",
})


def _tokens(text):
    return {token for token in re.findall(r"\w+", text.casefold()) if token not in STOP_WORDS}


def rank_passages(query, passages, *, filters=None, limit=5):
    """Return only matching passages, strongest first, with stable ID tie breaks.

    The caller supplies the approved corpus. A positive lexical score indicates
    word overlap, not that the passage answers the question.
    """
    if not isinstance(limit, int) or isinstance(limit, bool) or not 1 <= limit <= 50:
        raise ValueError("limit must be an integer in [1, 50]")
    terms = _tokens(query)
    if not terms:
        return []
    matches = []
    for passage in passages:
        if filters and filters.get("kandaId") and passage.get("kandaId") != filters["kandaId"]:
            continue
        body = _tokens(passage.get("englishText", ""))
        title = _tokens(passage.get("chapterTitleEnglish", ""))
        score = len(terms & body) + 2 * len(terms & title)
        if score:
            matches.append((passage, score))
    return sorted(matches, key=lambda item: (-item[1], str(item[0].get("id", ""))))[:limit]
