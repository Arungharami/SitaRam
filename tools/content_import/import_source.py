#!/usr/bin/env python3
"""
Reproducible import of real public-domain source text into passage records.

Stages (each is explicit and separately inspectable):

  1. load the registered source            -> data/source_registry.json
  2. verify the local file's SHA-256        -> refuses to proceed on mismatch
  3. extract raw page text                  -> true scan-page boundaries
  4. preserve the raw extraction verbatim   -> never rewritten after this point
  5. normalize mechanical formatting only   -> de-hyphenation, whitespace, headers
  6. identify Kanda boundary                -> from the registry, verified in text
  7. identify Sarga boundaries              -> SECTION <roman> markers
  8. generate passage records               -> trust state 'imported', nothing approved

Stages 9-13 (validation, reviewer evidence, human review, approval, indexing)
are separate tools. This script cannot verify or approve anything.

Nothing here generates, reconstructs, modernises, or corrects scripture. The
normalizer only touches layout artefacts of the scan, and every transformation
it applies is recorded on the passage so a reviewer can audit raw vs normalized.

Usage:
    python tools/content_import/import_source.py \
        --edition-id m_n_dutt_1891_bala_kanda \
        --source tools/content_import/sources/ramayanablaknda00vlgoog_djvu.xml \
        --kanda bala_kanda --sarga-start 1 --sarga-end 1 \
        --import-date 2026-08-03
"""
import argparse
import hashlib
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")
REGISTRY_PATH = os.path.join(DATA_DIR, "source_registry.json")
RAW_DIR = os.path.join(DATA_DIR, "raw_extractions")
PASSAGE_DIR = os.path.join(DATA_DIR, "passages")

sys.path.insert(0, os.path.join(BASE_DIR, "..", "validation"))
import passage_rules  # noqa: E402

ROMAN = {
    "I": 1, "II": 2, "III": 3, "IV": 4, "V": 5, "VI": 6, "VII": 7, "VIII": 8,
    "IX": 9, "X": 10, "XI": 11, "XII": 12, "XIII": 13, "XIV": 14, "XV": 15,
}

KANDA_NUMBERS = {
    "bala_kanda": 1, "ayodhya_kanda": 2, "aranya_kanda": 3, "kishkindha_kanda": 4,
    "sundara_kanda": 5, "yuddha_kanda": 6, "uttara_kanda": 7,
}

PAGE_SEPARATOR_LINE = "<<<PAGE-BREAK>>>"


# --- Stage 1 -----------------------------------------------------------------
def load_registry():
    with open(REGISTRY_PATH, encoding="utf-8") as f:
        return json.load(f)


# --- Stage 2 -----------------------------------------------------------------
def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def verify_checksum(path, expected):
    actual = sha256_file(path)
    return actual == expected, actual


# --- Stage 3 -----------------------------------------------------------------
def extract_pages(xml_path):
    """
    Extract text per scan page from an archive.org DjVu XML.
    Page boundaries come from the scan itself, not from guesswork.
    """
    root = ET.parse(xml_path).getroot()
    pages = []
    for obj in root.iter("OBJECT"):
        lines = []
        for line in obj.iter("LINE"):
            lines.append(" ".join((w.text or "") for w in line.iter("WORD")))
        pages.append("\n".join(lines))
    return pages


# --- Stage 5 -----------------------------------------------------------------
# Running headers and scan furniture printed on every page of this volume.
# Removing them is a layout fix, not a text edit: they are not translated prose.
HEADER_PATTERNS = [
    r"^\s*\d{1,3}\s+[A-Za-z/^*\\]{0,3}[AI][AIRMV][A-Za-z^*.,/\\]{2,}\.?\s*$",
    r"^\s*[Bb][^\s]{0,3}[LlIi][AaSsXx][Kk][AaSsXxk][^\s]{0,4}[Mm][.,]?\s*\d{0,3}\s*$",
    r"^\s*Digitized by\s*$",
    r"^\s*Google\s*$",
    r"^\s*" + re.escape(PAGE_SEPARATOR_LINE) + r"\s*$",
    r"^\s*$",
]


def normalize_mechanical(raw_text):
    """
    Mechanical formatting only. Returns (normalized_text, applied_operations).

    Permitted:  drop running headers / scan furniture, join end-of-line
                hyphenation, collapse redundant whitespace.
    Forbidden:  changing words, spelling, transliteration, punctuation within a
                sentence, or supplying anything the scan does not contain.
    """
    ops = []

    kept = []
    dropped = 0
    for line in raw_text.split("\n"):
        if any(re.match(p, line) for p in HEADER_PATTERNS):
            dropped += 1
            continue
        kept.append(line)
    if dropped:
        ops.append("removed %d running-header/scan-furniture line(s)" % dropped)

    text = "\n".join(kept)

    # Join words split across a line end by a hyphen, e.g. "austeri-" + "ties".
    text, n_join = re.subn(r"(\w+)-\s*\n\s*(\w+)", r"\1\2", text)
    if n_join:
        ops.append("rejoined %d hyphenated line-break(s)" % n_join)

    # Collapse newlines inside a paragraph into spaces, keeping blank-line breaks.
    paragraphs = re.split(r"\n\s*\n", text)
    cleaned = []
    for para in paragraphs:
        para = re.sub(r"\s*\n\s*", " ", para).strip()
        if para:
            cleaned.append(para)
    text = "\n\n".join(cleaned)

    text, n_ws = re.subn(r"[ \t]{2,}", " ", text)
    if n_ws:
        ops.append("collapsed %d run(s) of repeated spaces" % n_ws)

    return text.strip(), ops


# --- Stages 6 & 7 ------------------------------------------------------------
SECTION_RE = re.compile(r"\bSECTION\s+([IVXLC]+|\\)\s*[.,]?", re.IGNORECASE)


def find_sarga_starts(pages):
    """
    Locate Sarga (SECTION) boundaries by scan page index.

    Returns a list of (sarga_number, scan_index). The opening section header of
    this volume OCRs as a backslash rather than 'I', so a marker that does not
    parse as a roman numeral is treated as the section following the previous
    one and is surfaced for reviewer confirmation.
    """
    found = []
    last_num = 0
    for idx, page in enumerate(pages):
        for m in SECTION_RE.finditer(page):
            token = m.group(1).upper()
            num = ROMAN.get(token, last_num + 1)
            if not found or num != found[-1][0]:
                found.append((num, idx))
                last_num = num
    return found


def build_passage(edition, source_meta, kanda_id, sarga_num, seq,
                  page_start, page_end, scan_start, scan_end,
                  raw_ref, raw_sha, normalized, ops):
    # editionId already encodes the Kanda for single-volume editions, so it is
    # not repeated here. kandaId remains an explicit field on the record.
    passage_id = "%s_sarga_%03d_p%03d" % (edition["editionId"], sarga_num, seq)
    return {
        "schemaVersion": 2,
        "passageId": passage_id,
        "editionId": edition["editionId"],
        "work": edition["work"],
        "kandaId": kanda_id,
        "kandaNumber": KANDA_NUMBERS[kanda_id],
        "sargaNumber": sarga_num,
        "passageSequence": seq,
        "language": edition["language"],
        "source": {
            "archiveIdentifier": edition["archiveIdentifier"],
            "sourceFilename": source_meta["filename"],
            "sha256": source_meta["sha256"],
            "pageStart": page_start,
            "pageEnd": page_end,
            "scanIndexStart": scan_start,
            "scanIndexEnd": scan_end,
            "rawTextRef": raw_ref,
            "rawTextSha256": raw_sha,
        },
        "provenance": {
            "sourceTitle": edition["sourceTitle"],
            "originalAuthor": edition["originalAuthor"],
            "translator": edition["translator"],
            "editor": edition.get("editor", ""),
            "publisher": edition["publisher"],
            "publicationCity": edition["publicationCity"],
            "publicationYear": edition["publicationYear"],
            "volume": edition.get("volume", ""),
            "edition": edition["edition"],
            "sourceUrl": edition["sourceUrl"],
            "publicDomainBasis": edition["publicDomainBasis"],
            "copyrightStatus": edition["copyrightStatus"],
            "dateAccessed": edition["dateAccessed"],
        },
        "text": {
            "normalized": normalized,
            "normalizationOperations": ops,
        },
        # Everything below is deliberately negative on import. Only a human
        # running review_record.py may change any of it.
        "trust": {
            "state": "imported",
            "verified": False,
            "approvedForRetrieval": False,
            "approvedForApp": False,
            "reviewer": None,
            "reviewedAt": None,
        },
        "approvalHistory": [],
        "corrections": [],
    }


def main():
    ap = argparse.ArgumentParser(description="Import real public-domain source text into passage records.")
    ap.add_argument("--edition-id", required=True)
    ap.add_argument("--source", required=True, help="Local path to the registered source file.")
    ap.add_argument("--kanda", required=True)
    ap.add_argument("--sarga-start", type=int, required=True)
    ap.add_argument("--sarga-end", type=int, required=True)
    ap.add_argument("--import-date", required=True, help="ISO date of this import run (UTC).")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    print("[1/8] Loading source registry")
    registry = load_registry()
    edition = registry["sources"].get(args.edition_id)
    if not edition:
        print("  ERROR: edition '%s' is not registered." % args.edition_id)
        sys.exit(1)
    print("  edition: %s (%s), tr. %s" % (
        edition["sourceTitle"], edition["publicationYear"], edition["translator"]))

    if not os.path.exists(args.source):
        print("  ERROR: source file not found: %s" % args.source)
        print("  Download it with:")
        print("    curl -L -o %s %s" % (args.source, edition["pageMapUrl"]))
        sys.exit(1)

    print("[2/8] Verifying SHA-256 against the registry")
    ok, actual = verify_checksum(args.source, edition["sha256"])
    if not ok:
        print("  ERROR: checksum mismatch.")
        print("    expected %s" % edition["sha256"])
        print("    actual   %s" % actual)
        sys.exit(1)
    print("  OK %s" % actual)

    print("[3/8] Extracting raw page text")
    pages = extract_pages(args.source)
    print("  %d scan pages" % len(pages))
    if len(pages) != edition["scanPageCount"]:
        print("  ERROR: expected %d pages, got %d" % (edition["scanPageCount"], len(pages)))
        sys.exit(1)

    print("[6/8] Locating Kanda boundary")
    if args.kanda != edition["kandaId"]:
        print("  ERROR: this source volume is %s, not %s" % (edition["kandaId"], args.kanda))
        sys.exit(1)
    print("  volume is a single-Kanda edition: %s" % args.kanda)

    print("[7/8] Locating Sarga boundaries")
    starts = find_sarga_starts(pages)
    if not starts:
        print("  ERROR: no SECTION markers found")
        sys.exit(1)
    by_num = {}
    for num, idx in starts:
        by_num.setdefault(num, idx)
    preview = [(n, by_num[n]) for n in sorted(by_num)[:5]]
    print("  detected %d Sarga start(s); first five (sarga, scanIndex): %s" % (len(by_num), preview))

    print("[4/8][5/8][8/8] Preserving raw, normalizing, building passage records")
    raw_edition_dir = os.path.join(RAW_DIR, edition["editionId"])
    if not args.dry_run:
        os.makedirs(raw_edition_dir, exist_ok=True)
        os.makedirs(PASSAGE_DIR, exist_ok=True)

    source_meta = {"filename": os.path.basename(args.source), "sha256": actual}
    repo_root = os.path.abspath(os.path.join(BASE_DIR, "..", ".."))
    written = []

    for sarga in range(args.sarga_start, args.sarga_end + 1):
        if sarga not in by_num:
            print("  ERROR: Sarga %d not found in this volume" % sarga)
            sys.exit(1)
        scan_start = by_num[sarga]
        later = [by_num[n] for n in sorted(by_num) if n > sarga]
        scan_end = later[0] if later else len(pages) - 1

        # The next section begins partway down its first page, so that page is
        # shared between two Sargas. It is included, and the reviewer sees the
        # exact boundary in the review report.
        separator = "\n" + PAGE_SEPARATOR_LINE + "\n"
        raw_text = separator.join(pages[scan_start:scan_end + 1])

        offset = edition.get("printedPageOffset", 0)
        page_start = scan_start - offset
        page_end = scan_end - offset

        raw_name = "%s_%s_sarga_%03d_raw.txt" % (edition["editionId"], args.kanda, sarga)
        raw_path = os.path.join(raw_edition_dir, raw_name)
        raw_rel = os.path.relpath(raw_path, repo_root).replace("\\", "/")

        # Stage 4: the raw extraction is immutable once written.
        if os.path.exists(raw_path):
            existing = open(raw_path, encoding="utf-8").read()
            if existing != raw_text:
                print("  ERROR: refusing to overwrite existing raw extraction %s" % raw_rel)
                print("         Raw source text is immutable. Remove it deliberately if the source changed.")
                sys.exit(1)
        elif not args.dry_run:
            with open(raw_path, "w", encoding="utf-8") as f:
                f.write(raw_text)

        raw_sha = hashlib.sha256(raw_text.encode("utf-8")).hexdigest()
        normalized, ops = normalize_mechanical(raw_text)

        passage = build_passage(
            edition, source_meta, args.kanda, sarga, 1,
            page_start, page_end, scan_start, scan_end,
            raw_rel, raw_sha, normalized, ops,
        )
        passage["source"]["importDate"] = args.import_date

        out = os.path.join(PASSAGE_DIR, passage["passageId"] + ".json")
        if not args.dry_run:
            with open(out, "w", encoding="utf-8") as f:
                json.dump(passage, f, indent=2, ensure_ascii=False)
        written.append(passage["passageId"])

        print("  Sarga %d: scan %d-%d = printed pages %d-%d, %d words -> %s" % (
            sarga, scan_start, scan_end, page_start, page_end,
            passage_rules.word_count(normalized), passage["passageId"]))
        for op in ops:
            print("      normalization: %s" % op)

    print("")
    print("Imported %d passage(s) at trust state 'imported'." % len(written))
    print("Nothing is verified or approved. Next steps:")
    print("  python tools/content_import/review_report.py --passage <id>")
    print("  python tools/content_import/review_record.py --passage <id> --reviewer \"<name>\" --decision start-review")


if __name__ == "__main__":
    main()
