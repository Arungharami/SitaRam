# SitaRam — User Feedback Process

System flow showing how feedback comments and ratings are stored, validated, and used to resolve dataset anomalies.

```
       ┌──────────────────┐
       │   User Feedback  │ (Thumbs Up / Down in App)
       └────────┬─────────┘
                │ HTTP Post (/feedback)
                ▼
       ┌──────────────────┐
       │ FastAPI Feedback │ (Logged in review queue)
       └────────┬─────────┘
                │
                ▼
       ┌──────────────────┐
       │  Review Database │ (Stored in review_feedback.json)
       └────────┬─────────┘
                │
                ▼
       ┌──────────────────┐
       │   Admin Review   │ (Manual inspection & cleanups)
       └──────────────────┘
```

## Feedback Categories
- `citation_correct`: thumbs up validation.
- `incorrect_citation`: incorrect sarga or verse cited.
- `translation_problem`: spelling or wording error in translation.
- `safety_concern`: ungrounded claim or religious ruling hallucination.
