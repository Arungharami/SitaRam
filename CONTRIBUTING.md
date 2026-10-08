# Contributing

Useful contributions to **SitaRam** include:

- Report a reading or localization workflow problem with reproducible steps.
- Improve a source-registration or corpus-validation instruction.
- Review a passage only against its registered edition and record real evidence.

## Reporting a problem

Check existing issues first. Include the source commit or branch, environment, minimal steps, expected behavior, actual behavior, and a redacted error. State whether you used real data, an educational fixture, or exported results. Keep credentials and personal records out of public reports.

## Proposing a change

Choose one bounded task. Describe the intended behavior and how it will be checked before a large implementation. Use a focused branch and draft pull request; link any existing issue. Record exactly which checks ran, including failures and unavailable checks. Do not report a full suite as passed after running only a subset.

## Relevant local checks

These are focused checks, not a replacement for the full project workflow in the README.

```bash
flutter analyze
flutter test
python tools/validation/test_corpus_validation.py
```

## Project evidence and boundaries

Keep imported, human-verified, app-approved, and retrieval-approved content distinct. Never fill missing passages or invent source/reviewer metadata.

[Project overview and setup](README.md) · [Issues](https://github.com/Arungharami/SitaRam/issues) · [Author's portfolio](https://arungharami.info)
