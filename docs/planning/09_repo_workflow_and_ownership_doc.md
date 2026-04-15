# Echoes — Repo Workflow & Ownership (MVP Locked)

## Purpose
Define contribution workflow, ownership boundaries, review gates, and release rhythm so the team can ship MVP quickly without chaos.

## What is already known
- Team goal is fast iteration with boring/reliable systems.
- MVP is narrow with high quality bar around event relevance, privacy, moderation, and public event pages.
- Current repository is a single app codebase with planning docs under `docs/planning`.

## Locked Workflow Decisions
- Single default branch (`main`) with short-lived feature branches.
- PR-required merges with at least one reviewer.
- **Founder approval is mandatory before every merge** (no exceptions in MVP phase).
- Conventional commit style optional; clear commit subjects required.
- MVP-owned surfaces mapped explicitly (API, ingestion/editorial ops, ranking/notifications, moderation/privacy, frontend integration).

## Ownership Map (Locked)
- **Backend/API owner** — auth, feeds, memories, reactions/comments, reports.
- **Data/ingestion owner** — event intake, editorial tools, dedupe workflows.
- **Trust/privacy owner** — moderation queue, policy operations, retention/deletion.
- **Product/frontend owner** — feed UX integration, event pages, memory creation flow.

## Merge and Release Controls (Locked)
- Required checks before merge:
  - lint/static checks,
  - test suite,
  - OpenAPI/documentation consistency check for API changes.
  - founder explicit approval.
- Release cadence:
  - continuous deploy behind feature flags.

## Hotfix Policy (Locked)
- Allow hotfix branches for urgent issues.
- Hotfixes still require post-fix documentation and founder approval before merge.

## API Contract Gate (Locked)
- Any API behavior/shape change must include OpenAPI updates in the same PR.

## Consequences
- Pros:
  - Maximum decision control and launch quality consistency.
  - Reduced contract drift between backend/frontend through enforced OpenAPI sync.
- Tradeoff:
  - Founder approval dependency can become a throughput bottleneck as PR volume grows.
