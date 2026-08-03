# Claude Coworker Setup for SitaRam

This repository is prepared so Claude Code can operate as a persistent engineering coworker by reading the root-level `CLAUDE.md` instructions automatically.

## What Claude can handle

Claude Code can inspect the repository, implement features, fix errors, run Flutter and Python checks, prepare pull requests, build release candidates, review corpus coverage, and maintain release documentation.

Claude cannot independently complete identity verification, accept legal agreements, create paid credentials, approve charges, or make legally binding Google Play declarations for the account owner.

## One-time local setup

### 1. Clone the repository

```bash
git clone https://github.com/Arungharami/SitaRam.git
cd SitaRam
```

### 2. Install Claude Code

Follow Anthropic's current official installation instructions. After installation, authenticate using the Anthropic Console or an eligible Claude plan.

### 3. Start the coworker

```bash
claude
```

Claude Code will read `CLAUDE.md`. Begin with:

```text
Audit the complete SitaRam repository against CLAUDE.md. Do not change code yet. Report the top release blockers, the evidence for each blocker, and the safest execution order.
```

Then use:

```text
Work on the highest-priority unblocked release task. Implement it, add tests, run all relevant checks, and prepare a focused pull request. Do not claim the corpus is complete unless the generated coverage report proves it.
```

## Recommended working model

Use one focused branch per task:

```text
agent/corpus-validation
agent/real-rag-backend
agent/citation-tests
agent/android-release-hardening
agent/play-internal-release
```

Require every task to end with:

- changed files;
- test and build results;
- security review;
- remaining blockers;
- owner-only steps.

## Secrets Claude must never receive in chat or commit

Store secrets only in their designated secret managers:

- `ANTHROPIC_API_KEY`: Hugging Face Space or backend deployment secret;
- `HF_TOKEN`: Hugging Face secret;
- Android keystore: encrypted local storage and GitHub Actions secret;
- keystore passwords: GitHub Actions secrets;
- Google Play service-account JSON: GitHub Actions secret;
- production endpoint configuration: GitHub Actions environment secret.

Never paste these values into an issue, pull request, README, Claude conversation, source file, or screenshot.

## Recommended first Claude task

```text
Replace the mock generation path in huggingface_space/app.py with a retrieval-grounded model abstraction. Preserve the public API response schema. Retrieve only approved passages, validate all returned citation IDs against retrieved context, return no-evidence when grounding is insufficient, add unit tests, and keep all provider keys server-side. Do not change the mobile API contract unless required and documented.
```

## Owner checkpoints

Claude should stop and provide exact instructions when it reaches any of these gates:

1. Anthropic/Hugging Face secret creation;
2. GitHub Actions secret creation;
3. Google Play service-account permission;
4. app-content and Data Safety declarations;
5. first upload-key registration;
6. release promotion from internal testing;
7. production rollout approval.

These checkpoints protect the account, signing identity, costs, and legal declarations.
