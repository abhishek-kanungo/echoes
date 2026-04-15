# Echoes — Analytics Instrumentation Plan (MVP)

## Purpose
Define what events we track, how identity is stitched, how quickly data is available, and which core KPI evaluates whether Echoes’ cultural-memory loop is working.

## Scope
In scope:
- Event taxonomy for product analytics
- Identity and session stitching
- Data freshness expectations
- Dashboard definitions
- MVP experimentation stance

Out of scope:
- Full warehouse modeling and BI semantic layer
- Long-term attribution/multi-touch marketing analytics
- Advanced causal inference tooling

---

## Locked Decisions
1. Analytics stack: **Product analytics SaaS** (fastest launch).
2. Event schema governance: **Lightweight start; tighten later**.
3. Identity stitching: **Anonymous pre-login ID merged on auth**.
4. Experimentation in MVP: **Feature flags only; no formal A/B platform yet**.
5. Data freshness: **Near-real-time dashboards (<=15 min lag target)**.
6. North-star KPI: **Prompt-to-memory conversion** (chosen as best-fit default to Echoes loop).

---

## Tracking Architecture (MVP)

## Client + server event flow
1. Client emits product interaction events (view/click/open/post actions).
2. Server emits authoritative outcome events (memory_created, report_created, follow_created).
3. Analytics SaaS ingests both streams with shared event IDs where possible.
4. Daily export snapshot retained for backup analysis and future warehouse migration.

## Source-of-truth rule
- Behavioral funnels should rely on server-confirmed events for conversion metrics.
- Client events are used for UX diagnostics and drop-off points.

---

## Identity Model

Identifiers:
- `anonymous_id` (generated on first app open/web session)
- `user_id` (after OTP verification)
- `session_id`

Merge rule:
- On successful login/signup, merge prior anonymous activity into authenticated profile.
- Preserve both IDs in analytics payload for auditability.

Privacy note:
- Phone number is never sent as analytics dimension in raw form.

---

## Event Catalog (MVP v1)

## Core funnel events
- `app_open`
- `feed_impression`
- `event_card_open`
- `prompt_shown`
- `prompt_click`
- `memory_create_started`
- `memory_create_submitted`
- `memory_create_success`

## Social loop events
- `reaction_create`
- `comment_create`
- `follow_create`
- `notification_sent`
- `notification_open`

## Editorial quality observability events
- `event_published`
- `event_merged_duplicate`
- `event_archived`

## Moderation observability events
- `report_submitted`
- `moderation_action_taken`

---

## Required Properties (baseline)
All events:
- `event_name`
- `event_time_utc`
- `anonymous_id`
- `user_id` (nullable)
- `session_id`
- `app_platform` (ios/android/web)
- `app_version`
- `locale`

Content events (when applicable):
- `event_id` / `event_slug`
- `memory_id`
- `category`
- `city_id`, `state_code`, `country_code` (nullable as available)

Notification events:
- `notification_type` (social|rediscovery)
- `channel` (in_app|email)
- `delivery_status`

---

## KPI & Dashboard Definitions

## North-star (recommended)
`Prompt-to-memory conversion = unique users with memory_create_success within window after prompt / unique users who received prompt_shown`

Why this metric:
- Directly measures the product loop from rediscovery trigger to emotional expression action.
- Better aligned than pure retention or generic engagement counts for this product thesis.

## Supporting KPIs
- D1/D7 prompt-driven return
- Memory creation rate per active user
- Feed relevance proxy (event_card_open / feed_impression)
- Notification open and action rates
- Category diversity exposure index

---

## Freshness and Reliability Targets
- Dashboard freshness target: <=15 minutes.
- Late-arriving event tolerance: up to 24h with backfill reconciliation.
- Daily metric reconciliation job compares client and server totals for core events.

---

## Governance Plan (Lightweight-first)

MVP process:
1. Keep event catalog in this doc + tracking spreadsheet.
2. Require PR review from one engineering owner before adding/changing event names.
3. Use `*_v2` suffix for breaking property changes.
4. Monthly cleanup pass to remove dead events and tighten schema.

Post-MVP trigger to harden governance:
- >3 client surfaces emitting analytics,
- >2 teams emitting events independently,
- frequent dashboard breakage due to schema drift.

---

## Experimentation Stance (MVP)
- Use feature flags for controlled rollouts and simple cohort comparisons.
- Defer formal randomized experimentation platform to post-MVP.

---

## Edge Cases
1. User reinstalls app before login: preserve anonymous continuity where possible; otherwise treat as new anonymous user.
2. Offline events queued client-side: send with original event timestamp and ingestion timestamp.
3. Duplicate submissions due to retries: dedupe by event UUID and idempotency keys on server-confirmed events.
4. Deleted content: keep historical aggregate analytics but remove direct content payload lookups from dashboards.

---

## Open Questions (non-blocking)
1. Whether to mirror all SaaS analytics into a warehouse from day 1 or start with weekly exports.
2. Exact attribution window for prompt-to-memory conversion (e.g., 6h vs 24h).
3. Whether email notification analytics should include provider-level bounce/complaint telemetry in MVP.
