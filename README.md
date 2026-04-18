# 🏛️ Vasudha KnowledgeSphere AI — RAG-Powered Legal Intelligence Agent

> **Production-ready, end-to-end Retrieval-Augmented Generation (RAG) system** that delivers Article-cited legal insights from Kuwait Labour Law through a secure, rate-limited webhook API — built on n8n, OpenAI, Pinecone, and PostgreSQL.

---

## 📌 Overview

**Vasudha KnowledgeSphere AI** is a fully deployed enterprise AI agent that answers natural language questions about Kuwait Labour Law No. 6 of 2010 with precision, speed, and full auditability.

The system transforms a 136-page scanned PDF into a searchable vector knowledge base, then serves grounded, Article-cited answers through a production-grade REST API — complete with session memory, enhanced logging, and rate limiting.

Built as a flagship product of the **Black Elephant AI Learning Ecosystem**, this project demonstrates a complete, client-deployable RAG architecture — from raw document to live intelligent API.

---

## 🎯 Business Use Case

| Problem | Solution |
|---|---|
| HR & Legal teams spend hours searching labour law | Instant natural language Q&A with Article-level citations |
| Scanned PDFs are unsearchable | Docling OCR + semantic chunking makes every Article queryable |
| Generic AI hallucinates legal answers | RAG grounds every answer strictly in the law text |
| No visibility into AI system behaviour | Full audit log with retrieval scores, latency, and cited Articles |
| API abuse and runaway costs | Rate limiting (20 req/hour/user) with 429 enforcement |
| Unstructured API responses | Structured JSON with answer + metadata on every response |

**Target Users:** HR Managers, Legal Advisors, Compliance Officers, and Operations Teams at Kuwait private sector enterprises.

---

## 🏗️ System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    INGESTION PIPELINE                         │
│                   (one-time / on update)                      │
│                                                               │
│  Kuwait Labour Law PDF (136 pages, Canon-scanned, 2010)      │
│           │                                                   │
│           ▼                                                   │
│  [Docling OCR] ──► kuwait_labour_law.md  (167,367 chars)     │
│           │                                                   │
│           ▼                                                   │
│  [Python Chunker] ──► 169 chunks (Article-level + Preamble)  │
│           │            metadata: source, article_number       │
│           ▼                                                   │
│  [OpenAI text-embedding-3-small] ──► 1536-dim vectors        │
│           │                                                   │
│           ▼                                                   │
│  [Pinecone vasudha-knowledge] ──► namespace: kuwait-labour-law│
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                    QUERY PIPELINE                             │
│                 (n8n webhook workflow)                        │
│                                                               │
│  POST /webhook/vasudhachatbotv1                               │
│    Headers: x-api-key                                         │
│    Body: { message, session_id, user_id }                    │
│           │                                                   │
│           ▼                                                   │
│  [Session Manager] ── API Key Auth + Input Validation        │
│           │                          │                        │
│           │                    (invalid) ──► 400/401         │
│           ▼                                                   │
│  [Rate Limit Check] ── Query rate_limits table               │
│           │                                                   │
│           ▼                                                   │
│  [Rate Limit Gate] ── IF requests < 20/hour                  │
│           │                    │                              │
│         TRUE                 FALSE ──► 429 Too Many Requests │
│           │                                                   │
│           ▼                                                   │
│  [Rate Limit Logger] ── INSERT into rate_limits              │
│           │                                                   │
│           ▼                                                   │
│  [Embed Question] ── OpenAI text-embedding-3-small           │
│           │                                                   │
│           ▼                                                   │
│  [Query Pinecone] ── top_k=10, cosine similarity             │
│           │                                                   │
│           ▼                                                   │
│  [Format Context] ── Assemble Articles + capture metadata    │
│           │                                                   │
│           ▼                                                   │
│  [AI Agent / GPT-3.5-turbo] ── Cite Articles, stay grounded  │
│           │           │                                       │
│           │    [Postgres Chat Memory] ── session history      │
│           ▼                                                   │
│  [Upsert Conversation] ── Full audit log to Postgres         │
│           │          (articles, confidence, latency, times)   │
│           ▼                                                   │
│  [Respond to Webhook] ── Structured JSON response            │
└──────────────────────────────────────────────────────────────┘
```

---

## 📦 Sample API Response

```json
{
  "success": true,
  "answer": "According to Article 70 of Kuwait Labour Law No. 6 of 2010, a labourer shall have the right to a paid annual leave of thirty (30) days. However, a labourer is entitled to leave for the first year only after completing at least nine months of service with the employer.",
  "metadata": {
    "session_id": "hr-session-001",
    "user_id": "manager-kuwait",
    "articles_retrieved": ["Article 70", "Article 71", "Article 73", "Article 72"],
    "top_confidence": 0.6147,
    "retrieval_count": 10,
    "source": "Kuwait Labour Law No. 6 of 2010",
    "timestamp": "2026-04-18T17:57:50.277Z"
  }
}
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Orchestration** | n8n (self-hosted via Docker) |
| **OCR / Document Processing** | Docling by IBM |
| **Embedding Model** | OpenAI `text-embedding-3-small` (1536 dimensions) |
| **Vector Database** | Pinecone Serverless (AWS us-east-1, cosine similarity) |
| **LLM** | OpenAI GPT-3.5-turbo |
| **Memory** | PostgreSQL (`n8n_chat_history`) |
| **Audit Logging** | PostgreSQL (`conversation_history`) |
| **Rate Limiting** | PostgreSQL (`rate_limits`) |
| **Authentication** | API Key via `x-api-key` header |
| **Runtime** | Python 3.11, Docker, macOS Apple Silicon compatible |

---

## 📂 Repository Structure

```
vasudha-knowledgesphere-ai/
│
├── 📄 Kuwait_Labour_Law_English.pdf          # Source: 136-page scanned PDF
├── 📄 kuwait_labour_law.md                   # Docling OCR output (167,367 chars)
├── 📄 kuwait_labour_law_chunks.json          # 169 Article-level chunks with metadata
│
├── 🐍 ocr_labour_law.py                      # Phase 1: Docling OCR extraction
├── 🐍 chunk_labour_law.py                    # Phase 2: Article-level chunking
├── 🐍 embed_and_upsert.py                    # Phase 3: OpenAI embed + Pinecone upsert
├── 🐍 test_rag.py                            # RAG pipeline test script
│
├── 🔄 6_Vasudha-Knowledge-HR-Sphere-AI-Agent.json  # Complete n8n workflow (importable)
├── 🗄️  vasudha-db.sql                        # Full PostgreSQL schema
│
├── 📄 .env.example                           # Environment variable template
├── 📄 .gitignore
└── 📄 README.md
```

---

## 🚀 Getting Started

### Prerequisites

- Python 3.11+
- Docker Desktop (for n8n)
- PostgreSQL (local or cloud)
- OpenAI API key
- Pinecone account (free tier sufficient)

---

### Step 1 — Clone the Repository

```bash
git clone https://github.com/hrswatirai-debug/vasudha-knowledgesphere-ai.git
cd vasudha-knowledgesphere-ai
```

### Step 2 — Set Up Python Environment

```bash
python3 -m venv vasudha_rag_env
source vasudha_rag_env/bin/activate
pip install docling pinecone openai python-dotenv --timeout 300
```

> ⚠️ Docling installs PyTorch (~80MB). Use `--timeout 300` on slower connections.

### Step 3 — Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env`:
```env
PINECONE_API_KEY=your_pinecone_api_key
OPENAI_API_KEY=your_openai_api_key
```

### Step 4 — Set Up PostgreSQL

```bash
psql -U postgres -d your_database -f vasudha-db.sql
```

Creates three tables:
- `conversation_history` — full audit log with RAG metadata
- `n8n_chat_history` — session memory for multi-turn conversations
- `rate_limits` — per-user request tracking for rate limiting

### Step 5 — Create Pinecone Index

In [app.pinecone.io](https://app.pinecone.io), create an index:

| Setting | Value |
|---|---|
| Index name | `vasudha-knowledge` |
| Dimensions | `1536` |
| Metric | `cosine` |
| Type | `Dense / Serverless` |
| Cloud | `AWS us-east-1` |

### Step 6 — Run the Ingestion Pipeline

Skip if using the pre-built sample data files included in this repo.

```bash
# OCR the PDF (10-15 mins, downloads Docling models on first run)
python3 ocr_labour_law.py

# Chunk by Article
python3 chunk_labour_law.py

# Embed and upsert to Pinecone
python3 embed_and_upsert.py
```

Expected output:
```
📦 Loaded 169 chunks
✅ Upserted 20/169 chunks
...
🎉 DONE! 169 chunks stored in Pinecone!
📊 Total vectors in index: 169
```

### Step 7 — Test the RAG Pipeline

```bash
python3 test_rag.py
```

Expected output:
```
🔍 Query: What are the rules for annual leave?
  Score: 0.6147 | Article 70 — 30 days paid annual leave...
  Score: 0.5947 | Article 73 — Cash equivalent for leave...
  Score: 0.5566 | Article 71 — Leave carry-forward rules...
```

### Step 8 — Import n8n Workflow

1. Start n8n: `docker start n8n`
2. Open `http://localhost:5678`
3. **Workflows** → **Import from file**
4. Select `6_Vasudha-Knowledge-HR-Sphere-AI-Agent.json`
5. Configure credentials: OpenAI API key + PostgreSQL connection
6. **Publish** the workflow

### Step 9 — Test the Live API

```bash
curl -X POST http://localhost:5678/webhook/vasudhachatbotv1 \
  -H "Content-Type: application/json" \
  -H "x-api-key: black-elephant-2026" \
  -d '{
    "message": "What is the annual leave entitlement?",
    "session_id": "test-session-001",
    "user_id": "demo-user"
  }'
```

---

## 🔐 Security & Enterprise Features

### API Key Authentication
All requests validated via `x-api-key` header. Invalid keys return `401 Unauthorized`.

### Input Validation
- Message field required and non-empty
- Maximum 1000 characters per message
- `session_id` required for conversation tracking

### Rate Limiting
- Maximum **20 requests per hour per user**
- Tracked in PostgreSQL `rate_limits` table
- Exceeding limit returns `429 Too Many Requests`
- Logged before expensive OpenAI calls to prevent abuse

### Full Audit Trail
Every interaction logged to `conversation_history` with:

| Field | Description |
|---|---|
| `session_id` | Conversation identifier |
| `user_id` | Requesting user |
| `message` | AI response text |
| `articles_retrieved` | JSON array of cited Articles |
| `top_confidence` | Pinecone similarity score (0–1) |
| `retrieval_count` | Number of Articles retrieved |
| `request_time` | When user sent the message |
| `response_time` | When AI response was written |
| `processing_ms` | End-to-end latency in milliseconds |

---

## 🧩 n8n Workflow — Node Reference

| Node | Type | Purpose |
|---|---|---|
| **Webhook** | Trigger | POST endpoint `/vasudhachatbotv1` |
| **Session Manager** | Code | API key auth, input validation, session init |
| **Rate Limit Check** | Postgres | Count requests in last hour for this user |
| **Rate Limit Gate** | IF | Branch: allow (< 20) or block (≥ 20) |
| **Rate Limit Logger** | Postgres | Log valid request to `rate_limits` |
| **Rate Limit Error** | Response | Return 429 with JSON error |
| **Embed Question** | HTTP Request | OpenAI Embeddings API call |
| **Query Pinecone** | HTTP Request | Semantic search — top 10 Articles |
| **Format Context** | Code | Build context + capture RAG metadata |
| **AI Agent** | LangChain | GPT-3.5-turbo with system prompt |
| **OpenAI Chat Model** | LangChain | Language model sub-node |
| **Postgres Chat Memory** | LangChain | Multi-turn session memory |
| **Upsert Conversation** | Postgres | Full audit log write |
| **Respond to Webhook** | Response | Structured JSON response |
| **Error Response** | Response | 400/401 error responses |

---

## 📊 Performance Benchmarks

| Metric | Value |
|---|---|
| Source document | Kuwait Labour Law No. 6 of 2010 |
| Pages processed | 136 pages |
| OCR engine | Docling (IBM) |
| Extracted text | 167,367 characters |
| Total chunks | 169 (168 Articles + Preamble) |
| Embedding model | text-embedding-3-small (1536 dims) |
| Avg similarity score | 0.51 – 0.61 for relevant queries |
| Avg end-to-end latency | ~7–15 seconds |
| Rate limit | 20 requests / hour / user |

---

## 🗺️ Roadmap

- [ ] Multi-document support (HR Manuals, Service Agreements, Oil & Gas regulations)
- [ ] RBAC — namespace-level access control per user role
- [ ] Telegram bot interface for mobile access
- [ ] Arabic language support
- [ ] Document update pipeline (automated re-ingestion on change)
- [ ] Analytics dashboard for usage and confidence trends

---

## 👩‍💼 About

Built by **Swati Rai** — AI Entrepreneur & Applied AI Consultant, based in Kuwait and India.
Technically mentored and supported by **Black Elephant AI Learning Ecosystem**, India.

Specializing in Generative AI and Agentic AI solutions for enterprise clients across Oil & Gas, HR, Legal, and Government sectors in the GCC.

- 💼 [LinkedIn](https://linkedin.com/in/hrswatirai)
- <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="14"/> [GitHub](https://github.com/hrswatirai-debug)

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

> **Disclaimer:** This system is a legal reference tool. Always consult a qualified legal professional for binding legal advice.
