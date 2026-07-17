---
language:
  - en
  - bn
  - sa
  - hi
  - es
license: apache-2.0
library_name: transformers
pipeline_tag: text-generation
base_model: Qwen/Qwen2.5-1.5B-Instruct
tags:
  - ramayana
  - valmiki-ramayana
  - source-grounded-ai
  - retrieval-augmented-generation
  - question-answering
  - multilingual
  - digital-humanities
  - religious-texts
---

# SitaRam Ramayana AI

**Repository:** `arun-gharami/SitaRam-ramyana-ai`  
**Project:** SitaRam mobile application  
**Purpose:** A respectful, multilingual, source-grounded AI guide for reading and studying the complete Valmiki Ramayana.

> **Development status:** This repository is the model and knowledge-system project for SitaRam. It must not be described as knowing the complete Ramayana until the seven-Kanda coverage checks and evaluation gates in this README have passed.

## Mission

SitaRam Ramayana AI should help a user:

- read the complete Valmiki Ramayana in a clear Kanda → Sarga → passage structure;
- search characters, events, places, themes, relationships, duties, promises, conflicts, and moral questions;
- ask questions in English, Bangla, Spanish, Hindi, or Sanskrit;
- receive an answer grounded in identified source passages;
- distinguish scripture text, translation, editorial summary, interpretation, and AI-generated reflection;
- receive useful educational feedback without presenting the AI as a religious authority.

The system must value **accuracy, provenance, respect, accessibility, and transparency** above fluent but unsupported answers.

---

## 1. The Seven-Kanda Coverage Contract

The knowledge base is complete only when all seven Kandas are represented from one declared canonical edition and every imported Sarga has provenance and review metadata.

| Order | Kanda | Core narrative scope | Required status |
|---:|---|---|---|
| 1 | Bala Kanda | Valmiki and Narada, origin of the poem, Rama’s early life, Vishvamitra, Sita’s svayamvara | Complete Sarga-level import |
| 2 | Ayodhya Kanda | Planned coronation, Kaikeyi’s boons, exile, Dasaratha, Bharata, duty and kingship | Complete Sarga-level import |
| 3 | Aranya Kanda | Forest life, sages, Surpanakha, golden deer, Sita’s abduction, Jatayu | Complete Sarga-level import |
| 4 | Kishkindha Kanda | Rama–Sugriva alliance, Vali, the Vanara search, preparation to find Sita | Complete Sarga-level import |
| 5 | Sundara Kanda | Hanuman’s journey to Lanka, meeting Sita, Lanka mission, return with news | Complete Sarga-level import |
| 6 | Yuddha Kanda | Ocean crossing, Lanka war, Ravana’s defeat, Sita’s recovery, return to Ayodhya | Complete Sarga-level import |
| 7 | Uttara Kanda | Later reign, earlier histories, Lava and Kusha, Sita’s final account, Rama’s later life | Complete Sarga-level import with textual-history note |

### Important edition rule

Sarga and verse counts can differ across recensions, editions, and translations. The project must never combine numbering from different editions without recording an explicit alignment. Each record must contain an `edition_id`, and the user interface must cite the numbering of that edition.

---

## 2. Canonical Source Policy

### Primary machine-readable English source

Use the public-domain **Manmatha Nath Dutt** English translation as the first complete English layer:

1. Volume 1 — Bala Kanda and Ayodhya Kanda  
2. Volume 2 — Aranya, Kishkindha, and Sundara Kandas  
3. Volume 3 — Yuddha Kanda  
4. Volume 4 — Uttara Kanda  

Public-domain Project Gutenberg editions are suitable for a reproducible import pipeline. Preserve the original title, translator, publication information, source URL, and Project Gutenberg identifier in every generated record.

### Sanskrit and cross-checking

A Sanskrit layer should be stored separately and aligned by Kanda, Sarga, and verse. Do not scrape or redistribute a modern digital edition unless its terms permit that use. A source may be used for manual verification without becoming redistributable training data.

### Alternative public-domain comparison

The Ralph T. H. Griffith translation may be used as a secondary comparison layer, not silently merged into Dutt’s wording.

### Source hierarchy

1. Declared canonical source passage  
2. Verified translation aligned to that passage  
3. Human-reviewed summary and annotation  
4. General scholarly background  
5. AI interpretation or reflection  

The model must never present levels 3–5 as exact scripture.

---

## 3. Recommended Repository Architecture

A model repository should not be the only location for the book corpus. Use three Hugging Face repositories:

```text
arun-gharami/SitaRam-ramyana-ai                 # model card, adapter/config, inference examples
arun-gharami/SitaRam-valmiki-ramayana-dataset  # complete reviewed corpus
arun-gharami/SitaRam-ramayana-ai-space          # live RAG API / demo
```

Suggested project layout:

```text
.
├── README.md
├── LICENSE
├── model/
│   ├── adapter_config.json
│   ├── adapter_model.safetensors
│   └── generation_config.json
├── prompts/
│   ├── system_prompt.md
│   ├── answer_template.md
│   └── safety_rules.md
├── retrieval/
│   ├── build_index.py
│   ├── search.py
│   ├── rerank.py
│   └── citation_verifier.py
├── data_manifest/
│   ├── corpus_manifest.json
│   ├── coverage_report.json
│   └── source_registry.json
├── evaluation/
│   ├── golden_questions.jsonl
│   ├── citation_tests.jsonl
│   ├── multilingual_tests.jsonl
│   └── evaluation_report.json
└── examples/
    ├── request.json
    └── response.json
```

Recommended dataset layout:

```text
data/
├── manifest.json
├── kandas/
│   ├── 01_bala/
│   │   ├── sarga_001.json
│   │   └── ...
│   ├── 02_ayodhya/
│   ├── 03_aranya/
│   ├── 04_kishkindha/
│   ├── 05_sundara/
│   ├── 06_yuddha/
│   └── 07_uttara/
├── translations/
│   ├── en/
│   ├── bn/
│   ├── es/
│   ├── hi/
│   └── sa/
├── annotations/
│   ├── characters.json
│   ├── places.json
│   ├── relationships.json
│   ├── events.json
│   └── themes.json
└── qa/
    ├── human_reviewed.jsonl
    └── adversarial.jsonl
```

---

## 4. Sarga Knowledge Schema

Each Sarga must be stored as a structured record. Never keep the entire book as one untraceable text file.

```json
{
  "document_id": "mndutt_en_bala_001",
  "work": "Valmiki Ramayana",
  "tradition": "Valmiki Sanskrit Ramayana",
  "edition_id": "m_n_dutt_project_gutenberg",
  "kanda_id": "bala",
  "kanda_order": 1,
  "kanda_name": "Bala Kanda",
  "sarga_number": 1,
  "sarga_title": "Human-reviewed title",
  "verse_start": null,
  "verse_end": null,
  "source_language": "en",
  "source_text": "Exact public-domain source passage",
  "transliteration": "",
  "translations": {
    "en": "Verified English text",
    "bn": "",
    "es": "",
    "hi": "",
    "sa": ""
  },
  "summary": {
    "en": "Human-reviewed summary",
    "bn": "",
    "es": ""
  },
  "characters": ["Valmiki", "Narada", "Rama"],
  "places": [],
  "events": [],
  "themes": ["dharma", "virtue", "truth"],
  "relationships": [],
  "moral_reflections": [],
  "content_type": "source_text",
  "provenance": {
    "source_title": "The Ramayana, Volume 1",
    "translator": "Manmatha Nath Dutt",
    "publication_status": "public_domain",
    "source_url": "",
    "retrieved_at": "",
    "content_hash": ""
  },
  "review": {
    "status": "draft",
    "text_reviewer": "",
    "language_reviewer": "",
    "religious_content_reviewer": "",
    "reviewed_at": "",
    "notes": ""
  }
}
```

### Required content types

Use an explicit value for every text block:

- `source_text`
- `translation`
- `human_summary`
- `human_commentary`
- `scholarly_background`
- `ai_explanation`
- `ai_reflection`

The application must display these labels to the user.

---

## 5. Corpus Import and Review Pipeline

```text
Public-domain source
        ↓
Edition registration
        ↓
Kanda and Sarga segmentation
        ↓
Text cleanup without paraphrasing
        ↓
Stable document IDs and hashes
        ↓
Metadata extraction
        ↓
Human text review
        ↓
Language review
        ↓
Character/event/theme annotation
        ↓
Approval for app
        ↓
Embedding and search index
        ↓
AI answer evaluation
```

### Import rules

- Preserve the source wording in `source_text`.
- Do not use an LLM to silently “correct” scripture text.
- Keep editorial corrections in a separate change log.
- Hash each approved passage so accidental changes can be detected.
- Record skipped front matter, footnotes, translator notes, and appendices.
- Maintain a mapping from source page or section to generated Sarga record.
- Never mark OCR text as approved before human comparison.
- Do not generate Bangla, Spanish, Hindi, or Sanskrit text and label it as a verified translation without review.

### Approval states

```text
raw_import
cleaned
segmented
needs_review
text_verified
translation_verified
approved_for_retrieval
approved_for_app
rejected
```

---

## 6. Why Retrieval-Augmented Generation Is Required

Fine-tuning alone is not a reliable way to preserve exact scripture, Sarga numbering, quotations, or provenance. The production assistant should use **retrieval-augmented generation (RAG)**:

1. Understand the user’s question and language.
2. Detect requested Kanda, Sarga, person, place, event, or theme.
3. Search only approved passages.
4. Apply metadata filters.
5. Retrieve several candidate passages.
6. Rerank candidates for relevance.
7. Provide the chosen passages to the language model.
8. Generate an answer constrained by those passages.
9. Verify every citation.
10. Remove or qualify unsupported claims.

Recommended retrieval stack:

- lexical search: BM25;
- multilingual embeddings;
- metadata filters for Kanda, Sarga, language, character, place, and content type;
- cross-encoder reranking where resources permit;
- FAISS, Qdrant, or another reproducible vector store;
- passage-size chunks that do not break verse or paragraph boundaries.

The live model should answer from the retrieved context, not from an unsupported claim that it has memorized the full book.

---

## 7. Required System Prompt

```text
You are SitaRam AI, a respectful educational guide to the Valmiki Ramayana.

SOURCE RULES
1. Treat the supplied approved passages as the primary evidence.
2. Never invent a Sanskrit verse, quotation, verse number, Sarga number,
   character relationship, location, event, or source.
3. If the evidence is insufficient, say so clearly.
4. Separate:
   a. exact source or verified translation,
   b. human-reviewed summary,
   c. historical or scholarly background,
   d. AI interpretation or reflection.
5. Cite Kanda, Sarga, edition/translator, and passage identifier.
6. Do not describe yourself as a priest, guru, prophet, or religious authority.
7. Do not give divine commands, fortune-telling, medical advice, legal advice,
   political persuasion, or discriminatory judgments.
8. Answer in the user's selected language.
9. When traditions or editions differ, explain the difference instead of
   declaring one interpretation universally correct.
10. Respect Rama, Sita, Lakshmana, Hanuman, Valmiki, and all traditions while
    remaining transparent about the source and uncertainty.

ANSWER FORMAT
- Direct answer
- Evidence from the Ramayana
- Context or interpretation
- Practical reflection, when requested
- Sources and confidence
```

---

## 8. User Answer and Feedback Format

A production answer should look like this:

```text
Direct answer:
[Clear response to the question.]

Evidence:
- Bala Kanda, Sarga X, passage ID ...
- Approved translation: ...

Explanation:
[Source-grounded explanation.]

Reflection:
[Optional modern-life reflection, clearly labeled as interpretation.]

Confidence:
High / Medium / Low

Limitations:
[Missing passage, edition difference, translation uncertainty, or review status.]
```

### “Real feedback” rules

The assistant may offer educational feedback about:

- a user’s interpretation of a passage;
- comparison between a user’s statement and the cited text;
- themes such as duty, truthfulness, compassion, leadership, grief, loyalty, courage, or self-control;
- study progress and comprehension;
- respectful reflective questions.

The assistant must not:

- tell a user that God has personally approved or rejected them;
- predict divine reward, punishment, marriage, death, health, immigration, wealth, or future events;
- shame a user through caste, gender, religion, nationality, disability, or other identity;
- use an uncited AI opinion as scripture;
- automatically learn from unreviewed user corrections.

### Feedback record

```json
{
  "feedback_id": "uuid",
  "question_id": "uuid",
  "answer_id": "uuid",
  "rating": "helpful",
  "reason": "citation_correct",
  "user_comment": "",
  "reported_passage_id": "",
  "language": "en",
  "created_at": "",
  "review_status": "pending"
}
```

User feedback should enter a human review queue. It must not directly modify the approved corpus.

---

## 9. Flutter API Contract

### Request

```json
{
  "question": "Why did Rama accept exile?",
  "language_code": "en",
  "mode": "student",
  "filters": {
    "kanda_id": "ayodhya",
    "content_types": ["source_text", "translation", "human_summary"]
  },
  "conversation_id": "optional-uuid"
}
```

### Response

```json
{
  "answer": "Rama accepted exile to uphold his father's pledged word...",
  "mode": "student",
  "confidence": "high",
  "citations": [
    {
      "document_id": "mndutt_en_ayodhya_018",
      "kanda": "Ayodhya Kanda",
      "sarga": 18,
      "edition": "M. N. Dutt",
      "content_type": "source_text",
      "quoted_text": "Short permitted excerpt"
    }
  ],
  "interpretation_label": "AI-generated explanation",
  "limitations": [],
  "retrieval": {
    "passages_considered": 8,
    "passages_used": 3
  }
}
```

### User modes

- `child`
- `beginner`
- `student`
- `research`
- `devotional_reflection`
- `character_analysis`
- `compare_translations`

Every mode uses the same approved evidence. Only vocabulary, depth, and presentation change.

---

## 10. Training Plan

### Phase 1 — Complete the corpus

Do not fine-tune yet.

- import all seven Kandas;
- create a source registry;
- review Sarga segmentation;
- create English source records;
- add reviewed Bangla and Spanish layers gradually;
- build character, place, event, and theme indexes;
- publish a coverage report.

### Phase 2 — Launch source-grounded RAG

- use a strong instruct model as the answer generator;
- retrieve approved passages;
- require citations;
- log failures;
- create a human-reviewed golden question set.

### Phase 3 — Build instruction data

Create instruction records only from approved passages:

```json
{
  "messages": [
    {
      "role": "system",
      "content": "SitaRam source-grounded assistant rules"
    },
    {
      "role": "user",
      "content": "What does this Sarga teach about keeping a promise?"
    },
    {
      "role": "assistant",
      "content": "Reviewed answer with Kanda/Sarga citations"
    }
  ],
  "evidence_ids": ["mndutt_en_ayodhya_018"],
  "review_status": "human_approved"
}
```

Include factual, character, chronology, quotation-verification, conflicting-edition, multilingual, child-friendly, research, unanswerable, and adversarial examples.

### Phase 4 — Optional LoRA fine-tuning

Fine-tune for answer structure, citation behavior, multilingual style, refusal to invent, and respectful tone. Do not fine-tune with the expectation that weights replace the corpus or citation system.

### Phase 5 — Optimize deployment

- quantize only after quality evaluation;
- test latency on selected Hugging Face hardware;
- cache embeddings and frequent questions;
- stream long answers;
- retain offline verified summaries in the Flutter app.

---

## 11. Evaluation and Release Gates

The following are **targets**, not current claimed results.

| Area | Release gate |
|---|---|
| Kanda coverage | 7/7 Kandas imported and approved |
| Sarga coverage | 100% of the declared canonical edition |
| Provenance | 100% of passages have source and edition metadata |
| Duplicate IDs | 0 |
| Broken citations | 0 in the release test suite |
| Citation precision | ≥ 98% |
| Retrieval Recall@5 | ≥ 95% on the golden set |
| Source faithfulness | ≥ 95% human-reviewed pass rate |
| Invented verse/number critical failures | 0 |
| Correct “insufficient evidence” behavior | ≥ 95% |
| English quality | Human-reviewed |
| Bangla quality | Native-language human-reviewed |
| Spanish quality | Native-language human-reviewed |
| Child-mode safety | 100% critical safety tests pass |

### Golden evaluation set

Create at least 200 reviewed questions per Kanda, plus cross-Kanda, chronology, relationship, quotation, edition-difference, unanswerable, multilingual, and adversarial tests. Every record must include expected evidence IDs and acceptable answer boundaries.

---

## 12. Coverage Report

Generate `coverage_report.json` during every release:

```json
{
  "edition_id": "m_n_dutt_project_gutenberg",
  "generated_at": "",
  "kandas_expected": 7,
  "kandas_complete": 0,
  "sargas_expected": null,
  "sargas_imported": 0,
  "sargas_text_verified": 0,
  "sargas_approved_for_app": 0,
  "languages": {
    "en": {"coverage_percent": 0},
    "bn": {"coverage_percent": 0},
    "es": {"coverage_percent": 0},
    "hi": {"coverage_percent": 0},
    "sa": {"coverage_percent": 0}
  },
  "blocking_issues": []
}
```

The Hugging Face model card and Flutter app should display this real coverage status. Never use “complete Ramayana AI” as a release claim while any blocking field is incomplete.

---

## 13. Local Model Example

The intended base generator is currently:

```text
Qwen/Qwen2.5-1.5B-Instruct
```

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

model_id = "Qwen/Qwen2.5-1.5B-Instruct"
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(
    model_id,
    device_map="auto",
    torch_dtype="auto",
)

messages = [
    {
        "role": "system",
        "content": "You are SitaRam AI. Answer only from supplied approved evidence."
    },
    {
        "role": "user",
        "content": "Evidence: [approved passages]\n\nQuestion: Why did Rama accept exile?"
    }
]

text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
inputs = tokenizer(text, return_tensors="pt").to(model.device)
output = model.generate(
    **inputs,
    max_new_tokens=500,
    temperature=0.2,
    do_sample=True,
)
print(tokenizer.decode(output[0][inputs.input_ids.shape[1]:], skip_special_tokens=True))
```

For production, use this only after retrieval has supplied approved evidence.

---

## 14. Hugging Face Publishing Workflow

```bash
curl -LsSf https://hf.co/cli/install.sh | bash -s
hf auth login
hf auth whoami
hf upload arun-gharami/SitaRam-ramyana-ai README.md README.md \
  --commit-message "Add complete Ramayana AI model card"
```

Do not put a Hugging Face write token in Flutter, GitHub, a model file, or a public Space variable.

---

## 15. Full-Book Completion Checklist

### Corpus

- [ ] Canonical edition selected and documented
- [ ] Bala Kanda complete
- [ ] Ayodhya Kanda complete
- [ ] Aranya Kanda complete
- [ ] Kishkindha Kanda complete
- [ ] Sundara Kanda complete
- [ ] Yuddha Kanda complete
- [ ] Uttara Kanda complete
- [ ] All Sargas have stable IDs
- [ ] Source hashes generated
- [ ] Provenance complete
- [ ] Copyright/public-domain status reviewed

### Quality

- [ ] Text review complete
- [ ] Kanda/Sarga numbering verified
- [ ] Character names normalized
- [ ] Place names normalized
- [ ] Event order reviewed
- [ ] Human summaries clearly labeled
- [ ] Bangla translations reviewed
- [ ] Spanish translations reviewed
- [ ] Sanskrit alignment reviewed
- [ ] Coverage report passes

### AI

- [ ] Hybrid retrieval implemented
- [ ] Metadata filtering implemented
- [ ] Reranking implemented
- [ ] Citation verifier implemented
- [ ] Unsupported-claim detector implemented
- [ ] Multilingual answer modes implemented
- [ ] “Insufficient evidence” behavior tested
- [ ] User feedback review queue implemented
- [ ] Golden evaluation set passes
- [ ] Flutter integration tested
- [ ] Offline fallback tested

---

## 16. Limitations

- The Ramayana has multiple recensions, translations, interpretations, and living traditions.
- A single English translation cannot represent every linguistic or theological nuance.
- Sarga and verse numbering may differ by edition.
- AI-generated interpretation can be wrong even when retrieved passages are correct.
- Translations and summaries can reflect translator or reviewer choices.
- User feedback is valuable but is not automatically authoritative.
- This tool is educational and reflective; it is not a replacement for the scripture, qualified teachers, textual scholars, or a user’s own tradition.

---

## 17. Responsible Use

Suitable uses include reading assistance, source-grounded question answering, multilingual explanation, literary and character study, chronology and event search, classroom support, personal reflection, and digital-humanities research with documented limitations.

Unsuitable uses include inventing scripture, impersonating a religious authority, predicting divine judgment or future events, creating hatred or discrimination, and replacing professional medical, legal, financial, or mental-health advice.

---

## 18. Project Ownership

**Creator:** Arun Kumar Gharami  
**GitHub:** `Arungharami/SitaRam`  
**Hugging Face:** `arun-gharami/SitaRam-ramyana-ai`  
**Application:** SitaRam — Valmiki Ramayana Reader and AI Research Guide

**Jai Shri Ram**
