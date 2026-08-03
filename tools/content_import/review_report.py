#!/usr/bin/env python3
"""
Generates the evidence a human reviewer needs to decide whether an imported
passage faithfully reproduces the printed source.

This tool only *presents* evidence. It never changes trust state. Claude (or any
automation) may run it; only a person can act on what it shows.

Usage:
    python tools/content_import/review_report.py --passage <id>
    python tools/content_import/review_report.py --passage <id> --out review.md
"""
import argparse
import difflib
import json
import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(BASE_DIR, "..", ".."))
PASSAGE_DIR = os.path.join(BASE_DIR, "data", "passages")
REGISTRY_PATH = os.path.join(BASE_DIR, "data", "source_registry.json")

sys.path.insert(0, os.path.join(BASE_DIR, "..", "validation"))
import passage_rules  # noqa: E402


def load_passage(passage_id):
    path = os.path.join(PASSAGE_DIR, passage_id + ".json")
    if not os.path.exists(path):
        print("ERROR: no such passage: %s" % passage_id)
        sys.exit(1)
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def detect_warnings(passage, all_passages):
    warns = []
    normalized = passage_rules.normalized_text(passage)

    if passage_rules.is_placeholder_text(normalized):
        warns.append("PLACEHOLDER: normalized text is empty or under %d words."
                     % passage_rules.MIN_PASSAGE_WORD_COUNT)

    for other in all_passages:
        if other["passageId"] == passage["passageId"]:
            continue
        if passage_rules.normalized_text(other).strip() == normalized.strip() and normalized.strip():
            warns.append("DUPLICATE: identical normalized text to %s." % other["passageId"])
        if (other.get("kandaId") == passage.get("kandaId")
                and other.get("sargaNumber") == passage.get("sargaNumber")
                and other.get("passageSequence") == passage.get("passageSequence")):
            warns.append("DUPLICATE: same Kanda/Sarga/sequence as %s." % other["passageId"])

    src = passage.get("source", {})
    if not passage_rules.has_valid_page_range(passage):
        warns.append("PAGE RANGE: pageStart/pageEnd are missing or inconsistent.")
    if not passage_rules.has_source_checksum(passage):
        warns.append("CHECKSUM: source.sha256 missing or malformed.")

    raw_ref = src.get("rawTextRef")
    if raw_ref:
        raw_path = os.path.join(REPO_ROOT, raw_ref)
        if not os.path.exists(raw_path):
            warns.append("RAW TEXT: referenced raw extraction is missing: %s" % raw_ref)

    prov_reasons = []
    if not passage_rules.has_complete_provenance(passage, prov_reasons):
        warns.extend("PROVENANCE: " + r for r in prov_reasons)

    # Transliteration OCR noise is expected for this scan; surface it so the
    # reviewer knows corrections are likely needed, without correcting anything.
    suspicious = sum(1 for tok in normalized.split() if any(c in tok for c in "^\\*~"))
    if suspicious:
        warns.append("OCR NOISE: %d token(s) contain stray symbols (^ \\ * ~). "
                     "These need reviewer judgement; no automated correction is permitted."
                     % suspicious)
    return warns


def build_report(passage, all_passages):
    src = passage["source"]
    prov = passage["provenance"]
    normalized = passage_rules.normalized_text(passage)

    raw_path = os.path.join(REPO_ROOT, src.get("rawTextRef", ""))
    raw_text = ""
    if os.path.exists(raw_path):
        with open(raw_path, encoding="utf-8") as f:
            raw_text = f.read()

    L = []
    a = L.append
    a("# Reviewer evidence: %s" % passage["passageId"])
    a("")
    a("**You are being asked to confirm that the normalized text below faithfully")
    a("reproduces the printed page images. Do not approve unless you have compared")
    a("it against the scan yourself.**")
    a("")
    a("## 1. Source metadata")
    a("")
    a("| Field | Value |")
    a("| --- | --- |")
    for k in ["sourceTitle", "originalAuthor", "translator", "editor", "publisher",
              "publicationCity", "publicationYear", "volume", "edition",
              "copyrightStatus", "dateAccessed"]:
        a("| %s | %s |" % (k, prov.get(k, "")))
    a("| sourceUrl | %s |" % prov.get("sourceUrl", ""))
    a("")
    a("**Public-domain basis:** %s" % prov.get("publicDomainBasis", ""))
    a("")
    a("## 2. Page mapping")
    a("")
    a("| Field | Value |")
    a("| --- | --- |")
    a("| archive identifier | %s |" % src.get("archiveIdentifier"))
    a("| source file | %s |" % src.get("sourceFilename"))
    a("| source SHA-256 | `%s` |" % src.get("sha256"))
    a("| printed pages | %s to %s |" % (src.get("pageStart"), src.get("pageEnd")))
    a("| scan indices (0-based) | %s to %s |" % (src.get("scanIndexStart"), src.get("scanIndexEnd")))
    a("| raw extraction | `%s` |" % src.get("rawTextRef"))
    a("| raw extraction SHA-256 | `%s` |" % src.get("rawTextSha256"))
    a("| import date | %s |" % src.get("importDate"))
    a("")
    a("Compare against the page images at:")
    a("")
    a("    %s" % prov.get("sourceUrl", ""))
    a("")
    a("Scan index N (0-based) is image N+1 in the archive.org viewer.")
    a("So this passage is images %s to %s."
      % (src.get("scanIndexStart", 0) + 1, src.get("scanIndexEnd", 0) + 1))
    a("")
    a("## 3. Trust state (current)")
    a("")
    a("| Field | Value |")
    a("| --- | --- |")
    for k, v in passage["trust"].items():
        a("| %s | %s |" % (k, v))
    a("| approvalHistory entries | %d |" % len(passage.get("approvalHistory", [])))
    a("| corrections recorded | %d |" % len(passage.get("corrections", [])))
    a("")
    a("## 4. Warnings")
    a("")
    warns = detect_warnings(passage, all_passages)
    if warns:
        for w in warns:
            a("- %s" % w)
    else:
        a("- none")
    a("")
    a("## 5. Normalization applied")
    a("")
    ops = passage["text"].get("normalizationOperations", [])
    if ops:
        for op in ops:
            a("- %s" % op)
    else:
        a("- none")
    a("")
    a("Only mechanical layout changes are permitted. If any line below alters a")
    a("word, spelling, or transliteration, reject the passage.")
    a("")
    a("## 6. Raw vs normalized (unified diff)")
    a("")
    a("```diff")
    diff = difflib.unified_diff(
        raw_text.split("\n"), normalized.split("\n"),
        fromfile="raw extraction", tofile="normalized", lineterm="", n=1,
    )
    shown = list(diff)[:400]
    L.extend(shown)
    if len(shown) == 400:
        a("... diff truncated at 400 lines; inspect the files directly ...")
    a("```")
    a("")
    a("## 7. Proposed passage text")
    a("")
    a("Word count: %d" % passage_rules.word_count(normalized))
    a("")
    a("```")
    a(normalized)
    a("```")
    a("")
    a("## 8. Decision")
    a("")
    a("If, and only if, you have compared this against the page images:")
    a("")
    a("```bash")
    a("# 1. move it into review")
    a('python tools/content_import/review_record.py --passage %s \\' % passage["passageId"])
    a('    --reviewer "<your full name>" --decision start-review')
    a("")
    a("# 2. record that the text matches the printed source")
    a('python tools/content_import/review_record.py --passage %s \\' % passage["passageId"])
    a('    --reviewer "<your full name>" --decision verify --note "compared against images %s-%s"'
      % (src.get("scanIndexStart", 0) + 1, src.get("scanIndexEnd", 0) + 1))
    a("")
    a("# 3. only then allow the AI to retrieve it")
    a('python tools/content_import/review_record.py --passage %s \\' % passage["passageId"])
    a('    --reviewer "<your full name>" --decision approve-retrieval')
    a("```")
    a("")
    a("To refuse it:")
    a("")
    a("```bash")
    a('python tools/content_import/review_record.py --passage %s \\' % passage["passageId"])
    a('    --reviewer "<your full name>" --decision reject --note "<why>"')
    a("```")
    return "\n".join(L)


def main():
    ap = argparse.ArgumentParser(description="Generate reviewer evidence for an imported passage.")
    ap.add_argument("--passage", required=True)
    ap.add_argument("--out", help="Write the report to this path instead of stdout.")
    args = ap.parse_args()

    passage = load_passage(args.passage)
    all_passages = []
    if os.path.isdir(PASSAGE_DIR):
        for name in sorted(os.listdir(PASSAGE_DIR)):
            if name.endswith(".json"):
                with open(os.path.join(PASSAGE_DIR, name), encoding="utf-8") as f:
                    all_passages.append(json.load(f))

    report = build_report(passage, all_passages)
    if args.out:
        out_path = args.out if os.path.isabs(args.out) else os.path.join(REPO_ROOT, args.out)
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        with open(out_path, "w", encoding="utf-8") as f:
            f.write(report + "\n")
        print("Wrote reviewer evidence to %s" % os.path.relpath(out_path, REPO_ROOT).replace("\\", "/"))
    else:
        print(report)


if __name__ == "__main__":
    main()
