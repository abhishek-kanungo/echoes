# Echoes — Cross-Repo Sync Playbook (Backend + Frontend + Planning)

## Purpose
Ensure backend and frontend repositories remain contract-aligned while planning artifacts live in this planning-first repository.

## Repositories
1. **Planning repo (this repo):** ADRs/specs/source-of-intent.
2. **Backend repo:** API implementation + contract tests.
3. **Frontend repo (Lovable-generated):** UI implementation + consumer contract checks.

---

## Source-of-Truth Rules

## 1) Product/architecture intent
- Source of truth: planning repo (`docs/planning/*`).
- Any scope/policy/behavior change starts here (ADR/spec update PR).

## 2) API contract
- Source of truth artifact: `03_openapi_mvp_skeleton.yaml` (or promoted v1 OpenAPI file).
- Backend implements against this contract.
- Frontend consumes generated types/SDK from this contract.

## 3) Runtime behavior
- Source of truth: backend integration/contract tests + staging behavior.

---

## Required Change Flow (must follow)

1. **Change proposed**
   - Open PR in planning repo to update relevant ADR/spec.
2. **Contract updated**
   - Update OpenAPI spec in planning repo (or linked contract repo path).
3. **Backend PR**
   - Reference planning PR + contract version.
   - Include contract tests for changed endpoints.
4. **Frontend PR**
   - Reference same planning PR + contract version.
   - Regenerate API types/client and update UI calls.
5. **Integration check**
   - Deploy backend branch to integration environment.
   - Run frontend against that environment with smoke flow checks.
6. **Merge order**
   - planning PR merged first,
   - then backend/frontend in coordinated window,
   - founder approval remains final gate before production merge.

---

## Versioning & Compatibility

- Tag OpenAPI contract versions (e.g., `api-v0.1.0`, `api-v0.1.1`).
- Use backward-compatible additions when possible.
- For breaking changes:
  - mark as breaking in planning PR,
  - ship backend compatibility shim window when feasible,
  - coordinate frontend cutover in same milestone.

---

## CI/CD Guardrails Across Repos

## Backend repo checks
- OpenAPI validation.
- Response contract tests vs OpenAPI.
- Breaking-change detector against previous contract tag.

## Frontend repo checks
- Generated API types up to date with target contract tag.
- Compile-time failure on contract mismatch.
- E2E smoke against integration backend.

## Planning repo checks
- Lint/format for docs/spec files.
- PR template requiring linked backend/frontend issue IDs.

---

## Operational Cadence

- **Weekly architecture sync (30 min):** review upcoming API changes and risks.
- **Per-slice contract review:** before slice implementation starts.
- **Release readiness review:** confirm frontend/backed contract tag alignment.

---

## PR Template Requirements (all repos)
Each PR must include:
- linked planning decision/ADR reference,
- target OpenAPI contract version,
- impacted endpoints/surfaces,
- rollout + rollback note,
- checkboxes for cross-repo dependency PRs.

---

## Ownership Model
- Backend owner: API correctness + contract tests.
- Frontend owner: client integration + UX correctness.
- Planning owner: ADR/spec consistency and decision log.
- Founder: final merge approval gate.

---

## Fast Failure Signals
Trigger immediate coordination when:
- frontend fails type generation or contract compile,
- backend introduces undocumented response fields,
- E2E smoke on auth/event/memory path fails in integration env,
- contract-breaking diff appears without explicit approval.

---

## Minimal Tooling Starter (recommended)
1. OpenAPI diff tool in backend CI.
2. API client/type generation in frontend CI.
3. Shared “contract version” file referenced in both repos.
4. Integration env URL convention (`api-int.echoes...`) for branch testing.
