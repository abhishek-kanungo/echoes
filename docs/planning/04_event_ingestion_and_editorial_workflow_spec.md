# Echoes — Event Ingestion & Editorial Workflow Spec (MVP)

## Purpose
Define how events enter the system, how editors approve/reject/merge them, and how published events become eligible for ranking, prompts, and public event pages.

## Scope
In scope:
- Event intake paths
- Deduplication flow
- Editorial review and publish states
- Backfill strategy for launch
- Category and safety boundaries

Out of scope (later docs):
- Ranking formula internals
- Notification trigger thresholds
- Detailed moderator staffing model and SLAs

---

## Locked Decisions (from clarification batch)
1. Ingestion cadence: **daily batch** plus **manual urgent publish path**.
2. Editorial SLA: **no formal SLA in MVP**.
3. Source attribution: **optional always** (editor judgment allowed).
4. Duplicate detection: **auto similarity flag + manual merge decision**.
5. Sensitive/unsafe events: **excluded from MVP taxonomy**.
6. Backfill: **A with extension** — curated historical backfill, and for significant moments go beyond standard launch window.

---

## Event Intake Model

### Intake channels
1. **Batch ingestion job (daily)**
   - Pulls candidate events from configured feeds/sources/import sheets.
   - Normalizes category/time/place metadata.
   - Inserts candidates as `draft`.

2. **Manual urgent entry (editor/admin)**
   - Used for same-day culturally important moments.
   - Allows fast draft creation directly in editorial UI.

### Candidate record minimum fields
- title
- occurred_at
- category
- at least one geo tag (country/state/city as available)
- short summary
- optional source URL(s)

Records failing minimum fields remain in intake-error queue for manual fix.

---

## Editorial Workflow States

Canonical lifecycle:
`draft -> review -> approved -> published -> archived`

### State behavior
- `draft`:
  - Ingested or manually created candidate.
  - Not user-visible.
- `review`:
  - Editor checks relevance, cultural fit, duplication, taxonomy match.
- `approved`:
  - Content is valid and publishable.
  - Eligible for scheduling.
- `published`:
  - Public event page live.
  - Eligible for ranking feed retrieval and memory attachment.
- `archived`:
  - Hidden from active discovery, retained for history/audit.

No formal SLA is guaranteed in MVP; editorial queue is processed opportunistically based on launch priorities.

---

## Deduplication Rules

### Automatic similarity flagging
At ingest time, compute similarity candidates using:
- normalized title similarity,
- occurred_at proximity,
- geo overlap,
- category match.

If score passes threshold, mark candidate `possible_duplicate=true` and attach duplicate candidates list.

### Manual merge decision
Editor chooses one action:
1. Merge into canonical existing event.
2. Keep as distinct event (different context/region framing).
3. Reject low-quality duplicate.

Merge action keeps canonical slug/event id and retains merged-source references in audit log.

---

## Safety & Taxonomy Policy (MVP)

- MVP includes only: cricket, films, TV, internet culture, music, safe public moments.
- Unsafe/sensitive events are excluded from ingestion/publish scope in MVP.
- If an ingest source provides out-of-scope sensitive event, candidate is auto-rejected with reason `out_of_scope_sensitive`.

---

## Backfill Strategy

## Baseline
- Curate historical events for launch categories (initial target window can start with last ~10 years).

## Extended rule for significant events
- For culturally significant moments, backfill may extend much further than the baseline window.
- Significance decision is editorial (e.g., iconic cricket finals, landmark film releases, major music-era moments).

## Operational guidance
- Build launch list in descending importance buckets:
  1. Tier 1: universally recognized moments (long-tail historical allowed)
  2. Tier 2: category staples with broad recall
  3. Tier 3: regional/segment moments

---

## Data Quality Checklist Before Publish
Editor must confirm:
1. Category in allowed MVP taxonomy.
2. Time is correct and normalized to UTC storage.
3. Geo tags are sufficiently specific where known.
4. Title/summary are neutral, concise, and culturally recognizable.
5. Prompt is resolved (template or editorial override).
6. No unresolved high-confidence duplicate flag.

---

## Minimal Roles (MVP)
- **Admin/Editor:** create, review, approve, publish, archive, merge.
- **System ingestion worker:** import candidates and set duplicate flags.
- **End users:** no direct event publishing in MVP.

---

## Interface Dependencies
This spec drives:
- Event-admin APIs (internal)
- Public event read APIs (`/events`, `/events/{slug}`)
- Ranking eligibility filters (published-only, in-scope categories)
- Analytics events for editorial throughput and publish quality

---

## Edge Cases
1. Urgent manual event and later batch import duplicate: auto-flag and queue for merge.
2. Event published with weak geo data: still publishable; ranking degrades gracefully.
3. Late correction after publish: allowed via editorial update while slug remains stable.
4. Category drift discovered post-publish: archive + optionally republish corrected event.

---

## Open Questions (next pass, non-blocking)
1. Exact similarity threshold values and feature weights.
2. Whether publish scheduling (future publish_at) is needed in MVP.
3. Whether source URL should become mandatory after launch.
