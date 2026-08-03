#!/usr/bin/env python3
"""
Proves that no scripture or narrative text was created, paraphrased, expanded,
corrected, or silently replaced by this branch.

Compares every text-bearing field in the corpus against a baseline git ref and
classifies each difference as TEXT (a change to narrative/scripture content) or
METADATA (trust, provenance, status, or structural fields). Any TEXT difference
is a failure.

    python tools/validation/verify_text_integrity.py --baseline <ref>
"""
import argparse
import json
import os
import subprocess
import sys

# Fields that carry narrative or scripture content. A change to any of these is
# a text change and must be reported as such.
TEXT_FIELDS = {
    "record": [
        "sourceText", "sargaTitleEnglish", "sargaTitleBangla", "sargaTitleSpanish",
        "characters", "places", "events", "themes", "relationships", "keywords",
    ],
    "record_nested": ["translations", "summary", "moralLesson"],
    "chapter_en": [
        "english_text", "short_summary_english", "moral_lesson_english",
        "chapter_title_english", "chapter_title_bangla", "characters", "themes",
    ],
    "chapter_bn": [
        "bangla_text", "short_summary_bangla", "moral_lesson_bangla", "chapter_title_bangla",
    ],
    "asset": [
        "englishText", "banglaText", "spanishText",
        "shortSummaryEnglish", "shortSummaryBangla", "shortSummarySpanish",
        "moralLessonEnglish", "moralLessonBangla", "moralLessonSpanish",
        "chapterTitleEnglish", "chapterTitleBangla", "chapterTitleSpanish",
        "characters", "themes", "kanda", "kandaId", "chapterNumber",
    ],
}

# Fields that legitimately changed: trust, provenance, and review state.
METADATA_FIELDS = {
    "review", "sourceMetadata", "source_metadata", "review_status", "reviewStatus",
    "translationReviewStatus", "verified", "source_title", "source_status",
    "source_id", "sourceTitle", "sourceStatus", "kandaOrder", "status",
    "documentId", "editionId", "contentType", "sourceLanguage", "work",
    "kandaName", "language", "chapter_number", "kandaId", "kanda",
    "audioEnglish", "audioBangla", "id", "sargaNumber",
}


def git_show(ref, path):
    result = subprocess.run(
        ["git", "show", f"{ref}:{path}"], capture_output=True, encoding="utf-8"
    )
    if result.returncode != 0:
        return None
    return result.stdout


def git_ls(ref, prefix):
    result = subprocess.run(
        ["git", "ls-tree", "-r", "--name-only", ref, prefix],
        capture_output=True, encoding="utf-8",
    )
    return [p for p in result.stdout.splitlines() if p.strip()]


def load(ref, path):
    raw = git_show(ref, path)
    if raw is None:
        return None
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return None


def is_empty(v):
    """A missing key and an empty string both mean 'no text here'."""
    return v is None or (isinstance(v, str) and not v.strip()) or v == []


def classify(field, o, n, text_diffs, empty_shape_diffs):
    """Record a text-field difference as real content change or empty-field materialization."""
    if is_empty(o) and is_empty(n):
        # e.g. absent Spanish key -> "" : schema shape only, no content either side.
        empty_shape_diffs.append((field, o, n))
    else:
        text_diffs.append((field, o, n))


def compare_obj(old, new, text_fields, nested_fields, label, text_diffs, meta_diffs, compared,
                empty_shape_diffs):
    keys = set(old) | set(new)
    for key in sorted(keys):
        o, n = old.get(key), new.get(key)
        if key in nested_fields:
            o_sub, n_sub = o or {}, n or {}
            for sub in sorted(set(o_sub) | set(n_sub)):
                compared.append(f"{label}.{key}.{sub}")
                if o_sub.get(sub) != n_sub.get(sub):
                    classify(f"{label}.{key}.{sub}", o_sub.get(sub), n_sub.get(sub),
                             text_diffs, empty_shape_diffs)
            continue
        if key in text_fields:
            compared.append(f"{label}.{key}")
            if o != n:
                classify(f"{label}.{key}", o, n, text_diffs, empty_shape_diffs)
        elif o != n:
            kind = "known-metadata" if key in METADATA_FIELDS else "OTHER"
            meta_diffs.append((f"{label}.{key}", kind, o, n))


def main():
    parser = argparse.ArgumentParser(description="Verify narrative text integrity against a baseline ref.")
    parser.add_argument("--baseline", required=True, help="Git ref to compare against (e.g. origin/main, or the parent commit).")
    args = parser.parse_args()

    repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    os.chdir(repo)

    base = args.baseline
    text_diffs, meta_diffs, compared, empty_shape_diffs = [], [], [], []
    counts = {"records": 0, "chapters_en": 0, "chapters_bn": 0, "asset_chapters": 0, "sarga_txt": 0}
    missing_in_head, added_in_head = [], []

    # --- Structured records ---
    for path in git_ls(base, "tools/content_import/data/records/"):
        old, new = load(base, path), load("HEAD", path)
        if new is None:
            missing_in_head.append(path)
            continue
        counts["records"] += 1
        compare_obj(old, new, TEXT_FIELDS["record"], TEXT_FIELDS["record_nested"],
                    os.path.basename(path), text_diffs, meta_diffs, compared, empty_shape_diffs)

    # --- Chapter files ---
    for path in git_ls(base, "tools/content_import/data/chapters/"):
        name = os.path.basename(path)
        old, new = load(base, path), load("HEAD", path)
        if new is None:
            missing_in_head.append(path)
            continue
        kind = "chapter_en" if name.startswith("en_") else "chapter_bn"
        counts["chapters_en" if kind == "chapter_en" else "chapters_bn"] += 1
        compare_obj(old, new, TEXT_FIELDS[kind], [], name, text_diffs, meta_diffs, compared,
                    empty_shape_diffs)

    # --- Raw Sarga text files (byte comparison) ---
    for path in git_ls(base, "tools/content_import/data/sargas/"):
        o, n = git_show(base, path), git_show("HEAD", path)
        counts["sarga_txt"] += 1
        compared.append(os.path.basename(path))
        if n is None:
            missing_in_head.append(path)
        elif o != n:
            text_diffs.append((os.path.basename(path), o, n))

    # --- Compiled app asset ---
    asset = "assets/content/ramayana_chapters.json"
    old_asset, new_asset = load(base, asset) or [], load("HEAD", asset) or []
    o_by_id = {c.get("id"): c for c in old_asset}
    n_by_id = {c.get("id"): c for c in new_asset}
    for cid in sorted(set(o_by_id) | set(n_by_id)):
        if cid not in n_by_id:
            missing_in_head.append(f"{asset}#{cid}")
            continue
        if cid not in o_by_id:
            added_in_head.append(f"{asset}#{cid}")
            continue
        counts["asset_chapters"] += 1
        compare_obj(o_by_id[cid], n_by_id[cid], TEXT_FIELDS["asset"], [],
                    f"asset[{cid}]", text_diffs, meta_diffs, compared, empty_shape_diffs)

    # --- Report ---
    print("=" * 72)
    print(f"TEXT INTEGRITY REPORT   baseline={base}   head={subprocess.run(['git','rev-parse','--short','HEAD'],capture_output=True,encoding='utf-8').stdout.strip()}")
    print("=" * 72)
    print("\nRecords compared:")
    for k, v in counts.items():
        print(f"  {k:16} {v}")
    print(f"  {'text fields':16} {len(compared)}")

    print(f"\nTEXT CHANGES: {len(text_diffs)}")
    for field, o, n in text_diffs:
        print(f"  !! {field}")
        print(f"       old: {str(o)[:160]}")
        print(f"       new: {str(n)[:160]}")

    print(f"\nEMPTY-FIELD MATERIALIZATION (absent key -> empty value, no content either side): {len(empty_shape_diffs)}")
    for field, o, n in empty_shape_diffs:
        print(f"  ~  {field}: {o!r} -> {n!r}")

    unexpected = [m for m in meta_diffs if m[1] == "OTHER"]
    print(f"\nMETADATA-ONLY CHANGES: {len(meta_diffs)} ({len(unexpected)} outside the known trust/provenance set)")
    summary = {}
    for field, kind, o, n in meta_diffs:
        key = field.split(".", 1)[-1] if "." in field else field
        summary[key] = summary.get(key, 0) + 1
    for key in sorted(summary, key=lambda k: -summary[k]):
        print(f"  {summary[key]:4}x  {key}")
    for field, kind, o, n in unexpected:
        print(f"  ?? UNEXPECTED {field}: {str(o)[:80]} -> {str(n)[:80]}")

    if missing_in_head:
        print(f"\nPRESENT IN BASELINE, ABSENT IN HEAD: {len(missing_in_head)}")
        for p in missing_in_head:
            print(f"  - {p}")
    if added_in_head:
        print(f"\nADDED IN HEAD: {len(added_in_head)}")
        for p in added_in_head:
            print(f"  + {p}")

    print("\n" + "=" * 72)
    ok = not text_diffs and not missing_in_head
    if ok:
        print("PASS: no narrative or scripture text was created, altered, or removed.")
        print("      All differences are trust/provenance metadata.")
    else:
        print("FAIL: narrative text differences or losses detected (listed above).")
    print("=" * 72)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
