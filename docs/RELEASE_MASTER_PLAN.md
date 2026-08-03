# SitaRam Release Master Plan

## Objective

Publish a trustworthy SitaRam Android application through Google Play with verified Ramayana reading content, source-grounded question answering, clear AI limitations, protected credentials, and reproducible release evidence.

## Current repository status

### Working foundations

- Flutter Android application exists.
- Package identity is `com.leadai.sitaram`.
- Release signing configuration exists and reads untracked `android/key.properties`.
- `.gitignore` excludes common signing files and `key.properties`.
- Mobile AI service can call a configured HTTPS backend.
- FastAPI routes exist for health, coverage, search, ask, feedback, and citation verification.
- A coverage report exists.
- Feedback and citation response models exist.

### Blocking evidence

1. **Corpus is not complete or approved.** The current coverage report records 7 imported Sargas out of 645 expected, with zero text-verified and zero approved-for-retrieval/app records.
2. **AI generation is still a mock path.** The backend currently selects initial records and returns a truncated summary rather than performing genuine relevance retrieval and a grounded provider call.
3. **Current search is only basic substring matching.** It is not yet the documented hybrid BM25/vector retrieval implementation.
4. **A shared application token is compiled into the app.** This cannot be treated as a secret and requires server-side rate limiting and abuse controls.
5. **Release automation previously did not exist.** The new guarded workflow prepares an AAB and optional internal-track draft but still requires repository secrets and Play service-account authorization.
6. **Google Play owner work remains.** Verification, declarations, signing confirmation, service-account authorization, tester management, and production approval cannot be completed by repository code.

## Execution program

### Milestone 1 — Truthful content foundation

Deliverables:

- define the canonical public-domain source editions;
- import all legally usable source files through the content pipeline;
- normalize text without changing meaning;
- verify Kanda and Sarga numbering;
- track language and translator provenance;
- reject duplicates and malformed records;
- require human approval before retrieval/app eligibility;
- generate an auditable coverage report;
- display truthful in-app coverage rather than a complete-book claim.

Exit gate:

- validation scripts pass;
- coverage output matches stored assets;
- every approved record has stable identifiers and provenance;
- store-listing language matches actual coverage.

### Milestone 2 — Real grounded RAG backend

Deliverables:

- retrieval index over approved passages only;
- lexical and semantic retrieval with deterministic filters;
- provider abstraction for Claude or another configured server-side model;
- structured answer schema;
- citation-ID validation;
- quotation verification;
- confidence/no-evidence behavior;
- input limits, rate limits, timeouts, retries, and safe logging;
- unit and integration tests.

Exit gate:

- benchmark questions retrieve expected passages;
- hallucinated citation IDs are rejected;
- no-evidence questions do not produce invented scripture;
- provider credentials are absent from the Android bundle.

### Milestone 3 — Android product readiness

Deliverables:

- complete reading/navigation behavior for available content;
- citation cards that open exact passages;
- visible online/offline status;
- clear interpretation labels;
- in-app report/flag flow;
- privacy-policy link;
- error, loading, timeout, and retry states;
- accessibility and text-scaling checks;
- physical-device smoke tests.

Exit gate:

- core reader and ask flows pass on a physical device;
- unavailable backend does not crash the app;
- reports are received and reviewable;
- privacy disclosures match actual traffic.

### Milestone 4 — Secure release candidate

Deliverables:

- GitHub Actions secrets configured;
- upload keystore restored only during the job;
- analysis and tests pass;
- signed AAB generated;
- checksum stored;
- version code confirmed unique;
- internal-testing upload prepared as a draft.

Exit gate:

- workflow is green;
- artifact is downloadable;
- certificate identity matches the intended upload key;
- no secret is present in tracked files or logs.

### Milestone 5 — Google Play testing and production

Deliverables:

- Play Console app created with correct package identity;
- Play App Signing configured;
- store listing and graphics completed;
- App content and Data Safety forms completed truthfully;
- internal testing completed;
- closed testing completed when the account requires it;
- production-access application completed when required;
- owner-approved rollout submitted.

Exit gate:

- Play review approves the app;
- production release is visible;
- monitoring and rollback ownership are documented.

## Release issue priority

Use this order unless a dependency changes:

1. Corpus provenance and validation
2. Real relevance retrieval
3. Grounded model provider integration
4. Citation and hallucination tests
5. Backend security/rate limiting
6. In-app reporting and privacy
7. Android build/test stabilization
8. Cloud AAB workflow validation
9. Play internal testing
10. Closed testing/production access when applicable
11. Production rollout

## Owner action register

The account owner must complete or approve:

- Anthropic API billing/key creation;
- Hugging Face Space secret values;
- GitHub Actions secret values;
- Google Play developer verification;
- service-account permissions;
- policy and legal declarations;
- upload-key registration confirmation;
- tester enrollment;
- production rollout.

All other engineering work should be prepared and validated by the Claude/GitHub coworker before asking for owner action.
