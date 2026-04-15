# Echoes — Phase 1 Audit & Phase 2 Gap Analysis (Initial, Updated with Domain Decisions v0.1)

## Status
- **Date:** 2026-04-15
- **Prepared from:** user prompt context + current repository contents + user decision responses
- **Important limitation:** Product/strategy/design/launch/investor source documents are still not present in this repo yet.

---

## A) What is already well-defined

### Product thesis (defined)
- Echoes is a **personalized cultural memory engine**, not a generic social network.
- Core loop is explicitly defined:
  - relevant event → emotional recognition → memory post/save/react → social response → prompt-driven return.

### Strategic constraints (defined)
- Launch narrow.
- India-first wedge.
- Initial categories: cricket, films, TV, internet culture, music, safe public moments.
- Event quality/relevance > breadth.
- MVP must be tightly scoped.
- System bias: boring, reliable, fast to iterate.
- Product quality critical areas: event modeling, ranking, prompts, privacy, public shareable event pages.

### Technical baseline from repo (defined but minimal)
- Existing app appears to be a Rails API-oriented starter with:
  - `User` model,
  - JWT utility,
  - base app config,
  - no Echoes-specific domain entities or endpoints yet.

---

## B) Missing / incomplete build-enabling documents (blocking)

The following artifacts are currently missing or incomplete enough to block confident implementation:

1. Frontend audit + UI surface map
2. Backend architecture ADR set
3. API style + authentication ADR
4. Canonical domain model (events, memories, reactions, prompts, feeds, reports, etc.)
5. MVP OpenAPI spec
6. Event ingestion + editorial workflow spec
7. Ranking + notification spec
8. Analytics instrumentation plan
9. Media/image strategy ADR (storage, transforms, CDN, moderation implications)
10. Moderation + reporting queue spec
11. Privacy, retention, deletion, and consent spec
12. Repo workflow + ownership doc
13. Deployment/environment config doc
14. Testing strategy
15. Vertical-slice implementation plan

---

## C) First 3 documents to complete (recommended order)

1. **Canonical Domain Model (MVP)**
   - Why first: all API, ranking, moderation, analytics, and frontend contracts depend on shared entities and lifecycle states.

2. **API Style/Auth ADR + MVP OpenAPI Skeleton**
   - Why second: converts domain decisions into concrete integration contracts for frontend/backend parallel work.

3. **Event Ingestion & Editorial Workflow Spec**
   - Why third: event quality is a core differentiator and heavily shapes ranking, notifications, and moderation workload.

---

## D) Clarification batch for Document #1 (Canonical Domain Model) — Responses Received

User-selected answers:

1. Memory visibility → **C** (Public-only for simplicity)
2. Identity model → **A** (Username + optional display name + optional profile photo)
3. Event geo granularity → **A** (Country + state + city tags)
4. User place history shape → **B** (Current city + hometown)
5. Memory attachments → **C** (Text + up to 4 images)
6. Reactions model → **A** (Single lightweight reaction)
7. Comments → **A** (Yes, flat comments)
8. Prompt model → **C** (Hybrid template + editorial override)
9. Social graph scope → **A** (Follow model)
10. Deletion semantics → **C** (Soft delete internal, immediate user-visible removal)

---

## E) Locked MVP domain decisions (v0.1)

Based on responses above, the Canonical Domain Model draft will assume:

- User-generated memories are public at launch and linked to events.
- Identity is lightweight profile-first (username required; display name/photo optional).
- Event relevance can leverage country/state/city tags, while user location history for MVP is limited to current city + hometown.
- Memories support rich capture (text + up to 4 images).
- Engagement includes single reaction type + flat comments.
- A follow graph exists for social distribution.
- Prompting is hybrid (template base with editorial per-event overrides).
- Deletion is user-visible immediate removal with internal soft-delete semantics for operations/compliance workflows.

---

## F) Next immediate action

Proceed to draft **Document #1: Canonical Domain Model (MVP)** from these locked decisions, then run the next focused question batch only for unresolved fields that cannot be confidently inferred.

---

## G) Second clarification batch for Document #1 — Responses Received

User-selected answers:

1. Event source of truth → **B** (Ingestion pipeline + editorial approval gate)
2. Event creation authority → **A** (Internal/admin only)
3. Comment moderation mode → **A** (Post-first + report/removal)
4. Memory edit policy → **C** (No edit; delete/repost only)
5. Feed behavior → **A** (Following feed + For You feed)
6. Public event URL model → **A** (Stable slug route)

---

## H) Third clarification batch for Document #2 — Responses Received

User-selected answers:

1. Auth token strategy → **B** (JWT access + refresh pair)
2. Login method → **B** (Phone OTP only)
3. API versioning → **A** (URL versioning)
4. Error envelope → **A** (JSON:API-like errors array)
5. Rate limiting → **B** (Per-IP + per-user)
6. Public event API access → **B** (Public read + optional auth personalization)

---

## I) Fourth clarification batch for Document #3 — Responses Received

User-selected answers:

1. Ingestion cadence → **A** (Daily batch + manual urgent publish path)
2. Editorial SLA target → **C** (No formal SLA in MVP)
3. Source attribution requirement → **C** (Source optional; editor judgment)
4. Duplicate detection policy → **A** (Automatic similarity flag + manual merge)
5. Sensitive event handling → **A** (Exclude from MVP)
6. Backfill strategy → **A** with extension (backfill even longer for significant events)

---

## J) Fifth clarification batch for Document #4 — Responses Received

User responses + interpretation:

1. For You ranking objective → **A (chosen by assistant as best-fit default)** based on product thesis, per user note "whichever approach makes the most sense".
2. Signal weights source → **B** (Rule-based tiers per category)
3. Cold-start strategy → **A** (Onboarding interests + city/hometown + trending fallback)
4. Notification channels → **C** (In-app + email digest)
5. Trigger cadence → **A** (Real-time social + daily rediscovery)
6. Prompt return policy → **A** (Max 1 rediscovery prompt/day/user)

---

## K) Sixth clarification batch for Analytics Plan — Responses Received

User-selected answers + interpretation:

1. Analytics stack → **A** (Product analytics SaaS)
2. Event schema governance → **B** (Start lightweight, tighten later)
3. Identity stitching → **A** (Anonymous pre-login ID + merge on auth)
4. Experimentation in MVP → **A** (Feature flags only)
5. Data freshness requirement → **A** (Near-real-time dashboards)
6. North-star KPI → **Prompt-to-memory conversion** (assistant recommendation; user open to ideas)

---

## L) Seventh clarification batch for Moderation/Reporting Spec — Responses Received

User-selected answers:

1. Moderation operating model → **C** (Auto-action high-confidence + manual appeal path)
2. Report taxonomy size → **A** (Small fixed set)
3. Queue prioritization → **A** (Severity first, then recency)
4. Enforcement ladder → **A** (Warning -> temporary restriction -> suspension)
5. Appeals in MVP → **A** (No appeals UI; internal reversal path)
6. Reporter transparency → **A** (Simple status only)

---

## M) Eighth clarification batch for Privacy/Retention/Deletion Spec — Responses Received

User-selected answers:

1. Account deletion model → **C** (Deactivate-only in MVP)
2. Soft-delete retention window → **C** (180 days)
3. Analytics retention → **C** (Indefinite aggregated after 24 months)
4. Phone number handling → **A** (Encrypted + strict access + masked ops)
5. User data export → **A** (Manual support workflow)
6. Underage policy → **C** (All ages)

---

## N) Policy Update — Age Limit Direction Locked

User direction update:

- Final age policy for launch should prioritize minimizing legal risk.
- **Locked update:** launch as **18+ only** (supersedes prior all-ages selection in Section M).

---

## O) Ninth clarification batch for Repo Workflow/Ownership — Responses Received

User-selected answers:

1. Branching model → **A** (`main` + short-lived feature branches)
2. PR approval rule → **A** (1 reviewer) + explicit founder note: founder must approve before any merge
3. Release cadence → **A** (Continuous deploy with feature flags)
4. Ownership model → **A** (Single DRI per surface)
5. Hotfix policy → **A** (Hotfix branch allowed)
6. API contract gate → user asked "what is OpenAPI"; default kept as **A** (OpenAPI update required with API changes)

---

## P) Tenth clarification batch for Deployment/Environment Config — Responses Received

User-selected answers + interpretation:

1. Hosting model → **A** (Single cloud VM + managed DB)
2. Environment count → **B** (dev + prod for now, until go-live)
3. DB strategy → **A** (Single primary + daily backups)
4. Secrets handling → selected "whichever is simplest"; locked to **A** (Managed secret store) as simplest secure baseline
5. Background jobs → **A** (same deploy unit, separate process)
6. Rollback policy → **B** (Manual redeploy previous tag)

---

## Q) Eleventh clarification batch for Testing Strategy — Responses Received

User-selected answers:

1. Test pyramid → **A** (API/integration heavy)
2. Pre-merge checks → **A** (Lint + changed-area tests)
3. Contract testing → **A** (OpenAPI schema + response contract tests)
4. E2E scope → **A** (3 critical flows)
5. Load testing → **A** (basic pre-launch smoke)
6. Release bug bar → **C** (Ship unless outage risk)

---

## R) Twelfth clarification batch for Vertical-Slice Plan — Responses Received

User-selected answers:

1. First slice → **B** (Auth + event page + memory create)
2. Team execution mode → **B** (Parallel backend/frontend by milestone contracts)
3. Definition of done → **A** (API + UI + analytics + tests + docs)
4. Pilot launch strategy → **A** (Internal dogfood first)
5. Go/no-go gate → **A** (Quality checklist + moderation readiness + on-call ready)
6. Timeline style → **B** (Milestone-based)

---

## S) Next Missing Docs (post-vertical-slice)

After completing vertical-slice planning, remaining notable artifacts to finalize:

1. Backend architecture ADR (service/runtime boundaries)
2. Frontend audit + UI/data contract mapping
3. Media/image strategy ADR

---

## T) Thirteenth clarification batch for Backend Architecture ADR — Responses Received

User-selected answers:

1. Core architecture → **A** (Modular monolith)
2. Admin/editorial interface → **A** (Same app namespace)
3. Caching approach → **A** (No cache initially)
4. Search strategy → **A** (Postgres-native search)
5. Media pipeline tie-in → **C** (Hybrid: app-side now, external later)
6. Destructive migration governance → **A** (Founder + backend owner approval)

---

## U) Fourteenth clarification batch for Frontend Audit — Responses Received

User-selected answers:

1. Frontend runtime target → **C** (Web-first now, mobile after pilot)
2. Primary UI surfaces → **A** (Auth, For You, event page, memory composer, profile)
3. Design system approach → **B** (Established UI library)
4. Data fetching strategy → **A** (Server-state library)
5. Poor-network handling → **A** (Basic retry + visible errors)
6. Frontend quality bar → **A** (Pixel-perfect for core loop screens)

---

## V) Fifteenth clarification batch for Media/Image ADR — Responses Received

User-selected answers:

1. Media storage → **A** (Object storage + CDN)
2. Image processing model → **A** (App-side processing + variants)
3. Max image upload size → **A** (5 MB)
4. Accepted formats → **A** (JPEG/PNG/WebP)
5. Moderation scan path → **A** (Async scan + hide if flagged)
6. Public URL policy → **A** (Signed originals + public safe derivatives)

---

## W) Cross-Repo Coordination Concern Raised

User note:
- Frontend (Lovable-generated) is in a separate repository.

Action:
- Added a dedicated cross-repo sync playbook to ensure planning, backend, and frontend stay contract-aligned with explicit source-of-truth and merge choreography.
