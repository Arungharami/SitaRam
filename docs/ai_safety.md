# SitaRam — AI Safety & Scriptural Guardrails

SitaRam implements strict safeguards to prevent the AI backend from inventing scripture or acting as a false religious authority.

## AI Safety Rules

1. **Hallucination Refusals**:
   - Refuse requests to invent Sanskrit verses or verse numbers.
   - Refuse requests to predict the future (fortunes, marriages, deaths, wealth, divine rewards, or punishments).
   - Refuse requests to claim to be a prophet, representative of God, or sectarian religious arbiter.

2. **Prompt Injection Protection**:
   - The user query cannot override the system instruction block.
   - Low-temperature sampling (`temperature = 0.1` or lower) is enforced in inference settings.

3. **Grounded Verification (RAG)**:
   - All facts must have matching passage document IDs.
   - If context passages contain no relevant facts, the AI must reply:
     `The approved SitaRam knowledge base does not contain enough evidence to answer this confidently.`
