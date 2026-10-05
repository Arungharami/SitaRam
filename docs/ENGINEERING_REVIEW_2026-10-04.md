# Engineering review — October 4, 2026

## Scope

Source review of `huggingface_space/app.py`, backend tests, shared corpus rules, chapter metadata, corpus coverage and quality workflow. This review addresses a bounded correctness issue; it does not certify the entire application, rerun all research experiments, or establish production readiness.

## Finding and repair

The ask endpoint selected the first approved passages regardless of the question, called the result a high-confidence AI explanation, and cited more passages than the response used. Search ignored its kanda filter.

Share deterministic lexical ranking between ask and search, honor kanda filters, return no evidence for unmatched questions, bound search/query inputs, and cite only the one excerpt actually used. Label it as a retrieved English source excerpt with low confidence and explicit generation/translation limitations.

## Verification

`python -m unittest test_retrieval -v` in `huggingface_space` — 4 tests passed. FastAPI endpoint tests require CI because FastAPI is unavailable locally; the quality workflow now includes the retrieval tests.

All changed Python files were syntax-compiled. Package installation from this workspace is blocked, so full dependency-backed suites and production builds are not described as passed. GitHub checks on the pull request provide the remaining integration validation.

## Next implementation work

Review source passages against registered editions and preserve reviewer/provenance metadata before corpus approval. Connect validated model generation only after relevant approved evidence is available. Store feedback durably before claiming it entered a review queue. Flutter/device release verification is still required.

## Evidence boundary

No raw benchmark data, measured research results, corpus approval records, model releases or production deployments were changed. Any affected scientific output must be re-executed and linked to the accepted source commit before updating manuscript claims.
