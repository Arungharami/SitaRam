#!/usr/bin/env python3
"""
Single entry point for "what may the AI actually retrieve?".

The corpus now has two record shapes:

  v1  data/records/*.json    legacy Sarga records (currently 7 placeholders)
                             governed by corpus_rules.py
  v2  data/passages/*.json   real-source passages from import_source.py
                             governed by passage_rules.py

Both gates are enforced. Anything that fails either one is withheld. Indexers,
exporters, and the coverage report all read through this module so a record can
never be eligible in one code path and ineligible in another.
"""
import glob
import json
import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _HERE)

import corpus_rules  # noqa: E402
import passage_rules  # noqa: E402

DEFAULT_RECORDS_DIR = os.path.join(_HERE, "..", "content_import", "data", "records")
DEFAULT_PASSAGES_DIR = os.path.join(_HERE, "..", "content_import", "data", "passages")
DEFAULT_REGISTRY = os.path.join(_HERE, "..", "content_import", "data", "source_registry.json")


def _load_json_dir(path):
    out = []
    if not path or not os.path.isdir(path):
        return out
    for fp in sorted(glob.glob(os.path.join(path, "*.json"))):
        try:
            with open(fp, encoding="utf-8") as f:
                out.append(json.load(f))
        except Exception:
            continue
    return out


def load_registry(registry_path=None):
    path = os.path.abspath(registry_path or DEFAULT_REGISTRY)
    if not os.path.exists(path):
        return {"sources": {}}
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def load_all(records_dir=None, passages_dir=None):
    """Returns (v1_records, v2_passages) with no filtering applied."""
    records = _load_json_dir(os.path.abspath(records_dir or DEFAULT_RECORDS_DIR))
    passages = _load_json_dir(os.path.abspath(passages_dir or DEFAULT_PASSAGES_DIR))
    return records, passages


def as_retrievable(item, kind):
    """Flatten either record shape into the common form the indexers consume."""
    if kind == "v1":
        return {
            "id": item.get("documentId"),
            "text": item.get("sourceText", ""),
            "kandaId": item.get("kandaId"),
            "sargaNumber": item.get("sargaNumber"),
            "editionId": item.get("editionId"),
            "schema": "v1",
        }
    return {
        "id": item.get("passageId"),
        "text": passage_rules.normalized_text(item),
        "kandaId": item.get("kandaId"),
        "sargaNumber": item.get("sargaNumber"),
        "editionId": item.get("editionId"),
        "pageStart": (item.get("source") or {}).get("pageStart"),
        "pageEnd": (item.get("source") or {}).get("pageEnd"),
        "reviewer": (item.get("trust") or {}).get("reviewer"),
        "schema": "v2",
    }


def retrieval_eligible(records_dir=None, passages_dir=None, registry_path=None):
    """
    Every item the AI backend is permitted to use as grounding evidence.
    Returns (eligible_items, withheld_count).
    """
    records, passages = load_all(records_dir, passages_dir)
    registry = load_registry(registry_path)

    eligible, withheld = [], 0
    for r in records:
        if corpus_rules.is_retrieval_eligible(r):
            eligible.append(as_retrievable(r, "v1"))
        else:
            withheld += 1
    for p in passages:
        if passage_rules.is_retrieval_eligible(p, registry=registry):
            eligible.append(as_retrievable(p, "v2"))
        else:
            withheld += 1
    return eligible, withheld


def app_eligible(records_dir=None, passages_dir=None, registry_path=None):
    """Every item cleared to ship in the app as verified scripture."""
    records, passages = load_all(records_dir, passages_dir)
    registry = load_registry(registry_path)

    eligible = []
    for r in records:
        if corpus_rules.is_app_eligible(r):
            eligible.append(as_retrievable(r, "v1"))
    for p in passages:
        if passage_rules.is_app_eligible(p, registry=registry):
            eligible.append(as_retrievable(p, "v2"))
    return eligible
