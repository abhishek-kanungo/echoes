# Echoes — Testing Strategy (MVP)

## Purpose
Define the minimum effective test strategy to ship Echoes MVP safely while preserving iteration speed.

## Scope
In scope:
- test pyramid emphasis
- pre-merge checks
- contract testing approach
- E2E coverage for launch
- basic load testing
- release bug bar policy

Out of scope:
- full-scale performance engineering program
- advanced fuzz/property testing framework

---

## Locked Decisions
1. Test pyramid: **API/integration-heavy + minimal UI tests**.
2. Pre-merge checks: **Lint + tests on changed areas only**.
3. Contract testing: **OpenAPI schema validation + response contract tests for core endpoints**.
4. E2E scope at launch: **3 critical flows only**.
5. Load testing: **Basic pre-launch smoke load test for auth/feed/post endpoints**.
6. Release bug bar: **Ship unless outage risk**.

---

## Testing Layers

## 1) Unit tests (targeted)
- Model/domain logic invariants
- Utility functions (token handling, serializers)
- Validation edge cases

## 2) Integration/API tests (primary investment)
- Auth flows (OTP request/verify/refresh)
- Feed reads (For You, Following)
- Memory lifecycle (create/delete)
- Reaction/comment/report endpoints

## 3) Contract tests (required for core endpoints)
- Validate API responses against OpenAPI schemas.
- Prevent undocumented field drift.
- Required for auth, events, feeds, memories, reports.

## 4) E2E smoke tests (3 critical flows)
1. User auth flow (request OTP -> verify -> access protected endpoint)
2. Feed read flow (`/feeds/for-you` happy path)
3. Memory create flow (event selection -> memory post -> appears in feed/profile context)

Minimal E2E only for launch to preserve speed.

---

## Pre-Merge Policy
- Always run lint/static checks.
- Run tests for changed areas and dependent modules.
- API-shape changes must include OpenAPI update + passing contract checks.
- Founder approval remains required before merge (from workflow doc).

---

## Load Test Policy (MVP)

Run once before external launch and again before first major growth campaign:
- endpoint group: auth, feeds, memories create
- goals:
  - catch obvious bottlenecks,
  - verify acceptable response times under expected MVP concurrency,
  - verify error-rate stability under burst traffic.

No continuous performance test suite in MVP phase.

---

## Release Bug Bar

Locked policy: **ship unless outage risk**.

Operational interpretation:
- P0/P1 outage/security/regression blockers must stop release.
- Non-outage defects may ship with:
  - owner assigned,
  - remediation date,
  - documented workaround if user-facing.

---

## Suggested Minimum Coverage Targets (pragmatic)
- Core auth/feed/memory integration paths covered before launch.
- Contract tests for every OpenAPI-tagged critical endpoint.
- E2E smoke suite green for every production release candidate.

---

## Observability Coupling
Testing is paired with runtime monitoring:
- 5xx rate alarms
- auth error spikes
- queue lag alerts
- API latency alerts for feed + memory post endpoints

---

## Edge Cases to Include Early
1. Expired access token + valid refresh token flow.
2. Memory delete visibility (immediate public hide + internal soft-delete).
3. Duplicate report submissions on same target.
4. Event slug lookup for missing/archived events.

---

## Revisit Triggers
- Frequent regressions escaping to production.
- Expansion of client surfaces (web + native divergence).
- Rising API complexity requiring broader contract coverage.
- Incident postmortems pointing to insufficient E2E/load validation.
