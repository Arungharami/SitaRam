#!/usr/bin/env python3
"""
Generates assets/content/coverage_report.json from the actual validated corpus.

Counts here are derived, never asserted: a record is only counted as verified /
retrieval-approved / app-approved if it passes corpus_rules eligibility, not
merely because its review.status field says so. Do not hand-edit the output
file - run this script.
"""
import os
import json
import argparse
import glob
from datetime import datetime, timezone

import corpus_rules
import corpus_loader
import passage_rules

CANONICAL_SARGA_COUNTS = corpus_rules.CANONICAL_SARGA_COUNTS


def generate_coverage_report(records_dir, output_file):
    pattern = os.path.join(records_dir, "*.json")
    files = sorted(glob.glob(pattern))

    total_expected = sum(CANONICAL_SARGA_COUNTS.values())

    kanda_counts = {k: 0 for k in CANONICAL_SARGA_COUNTS.keys()}
    lang_sarga_filled = {lang: 0 for lang in corpus_rules.SUPPORTED_LANGUAGES}
    declared_status_counts = {}
    blocking_issues = []

    imported_count = 0
    verified_count = 0
    retrieval_count = 0
    app_count = 0
    placeholder_count = 0
    editions = set()
    translators = set()

    for file_path in files:
        name = os.path.basename(file_path)
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                record = json.load(f)
        except Exception as e:
            blocking_issues.append(f"{name}: malformed JSON, excluded from all counts ({e})")
            continue

        imported_count += 1

        kanda_id = (record.get("kandaId") or "").lower()
        if kanda_id in kanda_counts:
            kanda_counts[kanda_id] += 1
        else:
            blocking_issues.append(f"{name}: kandaId '{kanda_id}' is not one of the 7 canonical Kandas")

        status = corpus_rules.declared_status(record)
        declared_status_counts[status] = declared_status_counts.get(status, 0) + 1

        meta = record.get("sourceMetadata", {}) or {}
        if record.get("editionId"):
            editions.add(record["editionId"])
        if meta.get("translator"):
            translators.add(meta["translator"])

        if corpus_rules.is_placeholder_text(record.get("sourceText", "")):
            placeholder_count += 1

        # Eligibility is computed, not read off the record.
        reasons = []
        if corpus_rules.is_retrieval_eligible(record, reasons):
            retrieval_count += 1
            verified_count += 1
        elif status in corpus_rules.RETRIEVAL_ELIGIBLE_STATUSES:
            # The record claims approval it has not earned. That is a blocking issue.
            blocking_issues.extend(reasons)

        app_reasons = []
        if corpus_rules.is_app_eligible(record, app_reasons):
            app_count += 1

        # A language only counts as filled when its text is real, not a stub.
        translations = record.get("translations", {}) or {}
        for lang in lang_sarga_filled:
            if not corpus_rules.is_placeholder_text(translations.get(lang, "")):
                lang_sarga_filled[lang] += 1

    # --- v2 real-source passages (data/passages/) ---------------------------
    # These are counted separately from the legacy placeholder records so the
    # report can never blur "we imported real source text" with "we have
    # verified scripture".
    passages_dir = os.path.join(os.path.dirname(records_dir), "passages")
    registry = corpus_loader.load_registry()
    _, passages = corpus_loader.load_all(records_dir, passages_dir)

    real_imported = 0
    real_verified = 0
    real_retrieval = 0
    real_app = 0
    real_rejected = 0
    passage_state_counts = {}
    reviewers = set()
    real_kanda_sargas = {}

    for p in passages:
        real_imported += 1
        state = passage_rules.trust_state(p)
        passage_state_counts[state] = passage_state_counts.get(state, 0) + 1

        trust = p.get("trust") or {}
        if trust.get("reviewer"):
            reviewers.add(trust["reviewer"])
        if p.get("editionId"):
            editions.add(p["editionId"])
        prov = p.get("provenance") or {}
        if prov.get("translator"):
            translators.add(prov["translator"])
        if state == "rejected":
            real_rejected += 1

        kid = p.get("kandaId")
        if kid:
            real_kanda_sargas.setdefault(kid, set()).add(p.get("sargaNumber"))

        reasons = []
        if passage_rules.is_retrieval_eligible(p, reasons, registry=registry):
            real_retrieval += 1
            real_verified += 1
        else:
            if state in passage_rules.RETRIEVAL_ELIGIBLE_STATES:
                blocking_issues.extend(reasons)
            elif state == "text_verified":
                real_verified += 1
        if passage_rules.is_app_eligible(p, registry=registry):
            real_app += 1

    verified_count += real_verified
    retrieval_count += real_retrieval
    app_count += real_app

    if real_imported and real_retrieval == 0:
        blocking_issues.append(
            f"{real_imported} real-source passage(s) are imported but none has completed human "
            f"review; they are excluded from retrieval and from the app."
        )

    languages = {
        lang: {
            "coveragePercent": round((filled / total_expected) * 100, 2) if total_expected > 0 else 0.0,
            "sargasFilled": filled,
        }
        for lang, filled in lang_sarga_filled.items()
    }

    kandas_complete = sum(
        1 for k, count in kanda_counts.items() if count >= CANONICAL_SARGA_COUNTS[k]
    )

    if placeholder_count:
        blocking_issues.append(
            f"{placeholder_count} of {imported_count} imported record(s) contain placeholder or stub-length "
            f"text and require real segmented source text before human review."
        )
    if verified_count == 0 and imported_count > 0:
        blocking_issues.append(
            "No record has passed human verification yet; the corpus is not usable as verified scripture."
        )

    report = {
        "editionId": sorted(editions)[0] if len(editions) == 1 else (sorted(editions) or ["unknown"])[0],
        "generatedAt": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "generatedBy": "tools/validation/generate_coverage_report.py",
        "corpusComplete": False,
        "kandasExpected": 7,
        "kandasComplete": kandas_complete,
        "sargasExpected": total_expected,
        "sargasImported": imported_count + real_imported,
        "sargasPlaceholder": placeholder_count,
        "sargasRealSourceImported": real_imported,
        "sargasTextVerified": verified_count,
        "sargasApprovedForRetrieval": retrieval_count,
        "sargasApprovedForApp": app_count,
        "sargasRejected": real_rejected,
        "realSource": {
            "imported": real_imported,
            "textVerified": real_verified,
            "approvedForRetrieval": real_retrieval,
            "approvedForApp": real_app,
            "rejected": real_rejected,
            "trustStateCounts": passage_state_counts,
            "kandaSargas": {k: sorted(v) for k, v in sorted(real_kanda_sargas.items())},
        },
        "declaredReviewStatusCounts": declared_status_counts,
        "reviewers": sorted(reviewers),
        "provenance": {
            "editions": sorted(editions),
            "translators": sorted(translators),
        },
        "kandaSargaCoverage": {
            k: {
                "imported": count,
                "expected": CANONICAL_SARGA_COUNTS[k],
                "percent": round((count / CANONICAL_SARGA_COUNTS[k]) * 100, 2),
            }
            for k, count in kanda_counts.items()
        },
        "languages": languages,
        "blockingIssues": blocking_issues,
    }
    report["corpusComplete"] = (
        report["sargasApprovedForApp"] >= total_expected and not blocking_issues
    )

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    print(f"Generated coverage report saved to '{output_file}'.")
    print(
        f"  imported={imported_count} placeholder={placeholder_count} verified={verified_count} "
        f"retrieval={retrieval_count} app={app_count} blockingIssues={len(blocking_issues)}"
    )


def main():
    parser = argparse.ArgumentParser(description="Generate Ramayana corpus coverage report.")
    parser.add_argument("--records-dir", type=str, default="../content_import/data/records", help="Directory containing JSON records.")
    parser.add_argument("--output", type=str, default="../../assets/content/coverage_report.json", help="Path to save coverage report.")
    args = parser.parse_args()

    records_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.records_dir))
    output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), args.output))
    generate_coverage_report(records_path, output_path)

if __name__ == "__main__":
    main()
