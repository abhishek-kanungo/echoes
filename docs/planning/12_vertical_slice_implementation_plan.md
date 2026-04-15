# Echoes — Vertical-Slice Implementation Plan (MVP)

## Purpose
Turn locked architecture/spec decisions into an executable implementation sequence with clear handoffs, gates, and definition-of-done.

## Scope
In scope:
- slice sequencing
- backend/frontend parallel execution model
- milestone gates
- pilot rollout path

Out of scope:
- detailed sprint staffing allocations
- post-MVP feature roadmap

---

## Locked Decisions
1. First slice: **Auth + event page + memory create**.
2. Execution mode: **Parallel backend/frontend by milestone contracts**.
3. Definition of done: **API + UI + analytics + tests + docs all complete**.
4. Pilot strategy: **Internal dogfood first**.
5. Go/no-go gate: **Quality checklist + moderation readiness + on-call readiness**.
6. Timeline style: **Milestone-based (not strict date-locked)**.

---

## Slice Plan

## Slice 1 — Core loop activation
Goal:
- user can authenticate,
- open public event page,
- post memory with text/images,
- view resulting state in core surfaces.

Includes:
- OTP auth endpoints + token refresh
- event detail payload + prompt resolution
- memory create/delete API
- basic UI wiring for auth, event page, composer
- analytics events for prompt->memory funnel
- moderation hooks (report memory)

Exit criteria:
- contract tests pass for auth/events/memory create
- E2E smoke: auth -> event page -> memory post
- production-like dry run in dev/prod with seed data

---

## Slice 2 — Social reinforcement loop
Goal:
- reactions/comments/follows drive return behavior.

Includes:
- reaction/comment/follow APIs
- following feed endpoint + UI
- notification triggers for social actions
- moderation queue intake for comments

Exit criteria:
- social action events tracked end-to-end
- moderation workflow handles reported comments/memories
- notification send/open telemetry visible in dashboards

---

## Slice 3 — Discovery quality hardening
Goal:
- stabilize For You relevance and editorial content quality.

Includes:
- ingestion/editorial queue operations
- ranking rule tuning controls
- rediscovery prompt scheduler guardrails
- load smoke test + rollout readiness checks

Exit criteria:
- editorial publish cycle operational
- relevance KPI monitoring active
- incident runbooks + rollback path validated

---

## Parallel Work Model (Backend/Frontend)

For each slice, run two synchronized tracks:

1. **Backend contract track**
- finalize endpoint/schema behavior,
- publish OpenAPI updates,
- ship API + contract tests.

2. **Frontend integration track**
- build UI against locked contracts,
- add analytics instrumentation,
- validate E2E smoke flows.

Coordination rule:
- no frontend merge on unstable contracts,
- no backend breaking change without OpenAPI + migration note.

---

## Definition of Done (applies to every slice)
A slice is complete only when all are true:
1. API behavior implemented and documented.
2. UI integration complete for targeted flows.
3. Analytics events wired and visible.
4. Tests pass (changed-area + contract + required E2E smoke).
5. Documentation updated (spec/ADR/runbook deltas).

---

## Pilot Rollout Path
1. Internal dogfood cohort only.
2. Observe quality metrics and moderation load.
3. Fix high-severity gaps.
4. Re-run go/no-go checklist.
5. Progress to invite-only external pilot (next phase, outside this locked decision set).

---

## Go/No-Go Checklist (must be green)
- Core product loop stable (auth -> event page -> memory post).
- Moderation queue staffed/operational.
- On-call runbook and incident contacts active.
- Rollback procedure tested with prior tag deploy.
- Privacy/age-gate and policy flows verified.

---

## Risks and Mitigations
1. Contract drift in parallel work
   - Mitigation: OpenAPI gate + contract tests.
2. Founder-approval bottleneck on many PRs
   - Mitigation: bundle low-risk changes and pre-review asynchronously.
3. Moderation overload during pilot
   - Mitigation: strict pilot cohort size and auto-action safeguards.

---

## Revisit Triggers
- If slice completion repeatedly slips due hidden dependency coupling.
- If pilot uncovers safety/quality incidents requiring sequence reorder.
- If staffing model changes significantly (new teams/owners).
