# ADR-013: Backend Architecture Baseline for Echoes MVP

## Status
Accepted (MVP)

## Context
Echoes now has locked MVP decisions across domain model, API/auth, ingestion workflow, ranking, moderation, privacy, deployment, and testing. The backend architecture ADR now needs to formalize service boundaries and runtime composition to prevent accidental over-engineering.

## Known Constraints
- Launch narrow, India-first, quality over breadth.
- System should remain boring, reliable, and fast to iterate.
- Current deployment direction is single VM + managed Postgres.
- Background jobs run as separate process in same deploy unit.

## Decision
1. **Core architecture:** Option A — Modular monolith.
2. **Admin/editorial surface:** Same app (`/admin`-style protected namespace).
3. **Caching at MVP:** No cache layer initially (DB-first).
4. **Search strategy:** Postgres-native search only.
5. **Media processing:** Hybrid — basic app-side now, external pipeline later trigger-based.
6. **Destructive migration approvals:** Founder + backend owner required.

## Rationale
- Modular monolith aligns with speed and low-ops MVP constraints.
- Keeping admin/editorial in-app reduces deployment complexity and coordination overhead.
- Avoiding premature cache/search infra reduces moving parts early.
- Hybrid media strategy allows launch speed now while preserving a clean path to CDN/pipeline externalization later.
- Dual-approval for destructive schema changes reduces irreversible data-risk.

## Consequences
### Positive
- Faster implementation and easier debugging in one runtime.
- Lower infra footprint for launch.
- Clear governance for high-risk schema operations.

### Tradeoffs
- Performance headroom depends heavily on query discipline and indexing.
- In-app admin surface increases need for strict authz separation and audit logging.
- Future split to services will require deliberate refactor boundaries.

## Revisit Triggers
- Sustained traffic/load beyond monolith comfort zone.
- Team scaling requiring independent deploy trains.
- Security/compliance isolation needs that require service separation.
- Search relevance requirements exceeding Postgres-native capabilities.
- Media transformation/throughput needs that justify full external pipeline by default.
