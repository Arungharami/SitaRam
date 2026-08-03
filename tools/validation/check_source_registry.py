#!/usr/bin/env python3
"""
Validates the source registry itself.

Confirms every registered edition declares the provenance a passage will inherit,
that its checksums are well formed, and that its public-domain basis is stated.
If the local source file is present, its SHA-256 is verified against the
registry; if it is absent, that is reported but not failed, because the large
scans are intentionally not committed.
"""
import argparse
import hashlib
import json
import os
import re
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_REGISTRY = os.path.join(_HERE, "..", "content_import", "data", "source_registry.json")
SOURCES_DIR = os.path.join(_HERE, "..", "content_import", "sources")

REQUIRED = [
    "editionId", "work", "sourceTitle", "originalAuthor", "translator",
    "publisher", "publicationCity", "publicationYear", "edition", "language",
    "kandaId", "archiveIdentifier", "sourceUrl", "sourceFilename", "sha256",
    "fileSizeBytes", "publicDomainBasis", "copyrightStatus", "dateAccessed",
]


def main():
    ap = argparse.ArgumentParser(description="Validate the ingestion source registry.")
    ap.add_argument("--registry", default=DEFAULT_REGISTRY)
    args = ap.parse_args()

    path = os.path.abspath(args.registry)
    if not os.path.exists(path):
        print("No source registry at %s; nothing to validate." % path)
        sys.exit(0)

    with open(path, encoding="utf-8") as f:
        registry = json.load(f)

    errors, notes = [], []
    sources = registry.get("sources", {})

    for edition_id, src in sources.items():
        missing = [k for k in REQUIRED if not src.get(k)]
        if missing:
            errors.append("%s: missing required field(s) %s" % (edition_id, missing))

        if src.get("editionId") != edition_id:
            errors.append("%s: editionId field '%s' does not match its key"
                          % (edition_id, src.get("editionId")))

        for digest_field in ["sha256", "plainTextSha256"]:
            digest = src.get(digest_field)
            if digest and not re.fullmatch(r"[0-9a-f]{64}", str(digest)):
                errors.append("%s: %s is not a sha256 digest" % (edition_id, digest_field))

        if src.get("copyrightStatus") != "public_domain":
            errors.append("%s: copyrightStatus must be 'public_domain' to be ingestible, got %r"
                          % (edition_id, src.get("copyrightStatus")))

        basis = src.get("publicDomainBasis", "")
        if len(basis) < 40:
            errors.append("%s: publicDomainBasis must state actual evidence, not a label"
                          % edition_id)

        year = src.get("publicationYear")
        if not isinstance(year, int) or year > 1929:
            errors.append("%s: publicationYear %r is not clearly public domain by "
                          "publication date" % (edition_id, year))

        # Verify the local artefact when it is present.
        local = os.path.join(SOURCES_DIR, src.get("sourceFilename", ""))
        if os.path.exists(local):
            h = hashlib.sha256()
            with open(local, "rb") as fh:
                for chunk in iter(lambda: fh.read(1 << 20), b""):
                    h.update(chunk)
            actual = h.hexdigest()
            if actual != src.get("sha256"):
                errors.append("%s: local file checksum mismatch (expected %s, got %s)"
                              % (edition_id, src.get("sha256"), actual))
            else:
                notes.append("%s: local source present and checksum verified" % edition_id)
        else:
            notes.append("%s: local source not present (expected; re-download with the "
                         "command in tools/content_import/README.md)" % edition_id)

    for n in notes:
        print("  note: %s" % n)

    if errors:
        print("Source registry validation FAILED:")
        for e in errors:
            print("  - %s" % e)
        sys.exit(1)

    print("Source registry validation passed: %d registered edition(s)." % len(sources))
    sys.exit(0)


if __name__ == "__main__":
    main()
