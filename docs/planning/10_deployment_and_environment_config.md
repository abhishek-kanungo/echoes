# Echoes — Deployment & Environment Configuration (MVP)

## Purpose
Define a minimal, reliable deployment setup for Echoes MVP that supports fast iteration and low operational overhead before scale.

## Scope
In scope:
- Hosting model
- Environment topology
- Database baseline
- Secrets management
- Job process topology
- Rollback and release operations

Out of scope:
- Multi-region HA architecture
- Kubernetes orchestration
- Advanced disaster-recovery automation

---

## Locked Decisions
1. Hosting model: **Single cloud VM + managed Postgres**.
2. Environment count: **dev + prod only for now** (add staging before/at go-live if risk increases).
3. DB strategy: **Single primary Postgres + daily backups**.
4. Secrets handling: **Managed secret store** (selected as simplest secure option).
5. Background jobs: **Same deploy unit as app, separate process**.
6. Rollback policy: **Manual redeploy of previous known-good tag**.

---

## Environment Topology

## dev
- Shared developer integration environment.
- Lower-cost resources.
- Seed/test data only.

## prod
- Customer-facing runtime.
- Managed DB with automated backups.
- Strict secrets/access controls.

### Note on staging
- Not in initial setup by decision.
- Revisit trigger: before first external beta or whenever release-risk/incident frequency rises.

---

## Runtime Layout

Single VM hosts:
- web app process
- worker process (background jobs)

Managed services:
- Postgres (primary)
- secret manager

Expected properties:
- simple deploy pipeline,
- minimal moving parts,
- clear incident debugging path.

---

## Database Configuration
- One primary Postgres instance.
- Daily automated backups.
- PITR optional if managed provider supports with low complexity.
- Migration policy: migrations run during deploy with rollback checklist.

Data-safety controls:
- backup verification check weekly,
- restore drill at least once before public launch.

---

## Secrets & Config
- All sensitive values in managed secret store (DB URL, JWT keys, OTP provider creds, email creds).
- Non-sensitive config via env vars or deploy config file.
- No plaintext secrets in repo.
- Rotation policy for critical secrets (JWT signing keys, provider keys) documented in ops runbook.

---

## Deployment Process (MVP)
1. Merge approved PR to `main` (including founder approval requirement from repo policy).
2. Build and deploy release artifact.
3. Run health checks.
4. Run DB migration checks.
5. Verify key flows (auth, feed read, memory post).
6. Mark release tag.

---

## Rollback Process (Manual)
1. Identify previous known-good tag.
2. Redeploy previous tag.
3. Verify app health and critical flows.
4. If migration introduced incompatibility, apply rollback playbook or forward-fix migration.
5. Record incident summary.

---

## Operational Guardrails
- Uptime/health endpoint checks.
- Error rate and queue latency monitoring.
- Disk/CPU/memory alerts.
- DB connection saturation alerts.
- On-call ownership rotation defined before external launch.

---

## Edge Cases
1. VM failure: reprovision from infra template, restore app, reconnect managed DB.
2. Failed migration on deploy: stop rollout, redeploy previous tag, run migration recovery procedure.
3. Job backlog spike: temporarily scale worker process vertically or split worker to separate host (revisit trigger).
4. Secret leak suspicion: rotate affected secrets immediately and invalidate sessions/tokens as required.

---

## Revisit Triggers
- External user growth causing sustained resource pressure.
- Frequent incidents requiring pre-prod validation environment.
- Need for zero-downtime deploy guarantees.
- Compliance/enterprise requirements demanding stricter environment separation.
