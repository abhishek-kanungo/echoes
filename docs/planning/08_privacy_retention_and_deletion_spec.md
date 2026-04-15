# Echoes — Privacy, Retention, and Deletion Spec (MVP)

## Purpose
Define how Echoes handles personal data collection, storage, deletion, retention, and child-data risk controls for India-first MVP operations.

## Scope
In scope:
- Account lifecycle privacy controls
- Data retention windows
- Deletion and deactivation behavior
- Phone data handling
- Data export process
- Child/minor handling baseline

Out of scope:
- Full legal opinion or jurisdiction-by-jurisdiction matrix
- Post-MVP rights automation portals

---

## Locked Decisions
1. Account deletion model: **Deactivate-only in MVP** (no full self-serve irreversible deletion flow yet).
2. Soft-deleted content retention: **180 days**.
3. Analytics retention: **Indefinite with aggregation/anonymisation after 24 months**.
4. Phone number handling: **Encrypted at rest + strict access controls + masked in ops tools**.
5. Data export: **No self-serve export in MVP; manual support workflow**.
6. Underage policy: **18+ only at launch** (risk-minimizing default for India-first MVP).

---

## Data Classification

### Tier 1 (high sensitivity)
- phone number
- auth secrets/tokens
- abuse/moderation evidence payloads

Controls:
- encryption at rest,
- access logging,
- least-privilege controls,
- masking in internal tools.

### Tier 2 (personal profile/content)
- username, display name, profile image
- memories/comments/reactions
- follows and engagement metadata

### Tier 3 (analytics/telemetry)
- event stream IDs and behavioral metrics
- aggregated dashboards

---

## Account Lifecycle

## States
- active
- deactivated
- reinstated
- internally purged (admin/legal workflow only; not user self-serve in MVP)

## Deactivation behavior
- user can deactivate account through settings/support flow.
- profile and authored content become non-discoverable publicly.
- backend keeps data for restoration, moderation audit, and legal-compliance windows.

No full self-serve irreversible delete in MVP.

---

## Content Deletion and Retention

### Memories/comments
- User deletion is immediate from user-visible surfaces.
- Record remains soft-deleted for **180 days**.
- After retention window, eligible for purge pipeline unless legal hold exists.

### Moderation artifacts
- moderation and report logs retained per compliance need; exact final retention table to be finalized with legal counsel.

### Backups
- backup snapshots age out per infrastructure retention policy; restore procedures must re-apply delete tombstones.

---

## Analytics Retention Policy
- Raw event-level analytics retained in active analytics system for up to 24 months.
- After 24 months, retain aggregated/anonymised trend data indefinitely.
- Personal-level drill-down access beyond 24 months should be disabled by policy.

---

## Phone Number Handling Policy
- Encrypt phone numbers at rest.
- Never expose full phone number in admin dashboards/logs.
- Use masked format for support operations.
- Restrict read access to auth/support systems only.
- Do not forward raw phone numbers into analytics payloads.

---

## Data Export Handling (MVP)
- No self-serve export UI/API.
- Manual support process:
  1. identity verification,
  2. request logging,
  3. scoped data extraction,
  4. secure delivery,
  5. closure audit trail.

Target SLA can be defined in ops runbook (outside this doc).

---

## Child / Age Risk Controls (India-first)

MVP launch policy is **18+ only** to reduce child-data compliance exposure.

Required controls:
- explicit age-gate at onboarding,
- block account creation if declared age < 18,
- periodic anti-circumvention checks (suspicious age signals),
- rapid trust-and-safety path for suspected underage accounts.

### Compliance implementation note
Before launch, legal counsel should confirm onboarding language and age-gate flow satisfy applicable Indian requirements.

---

## Security and Access Controls
- Role-based access control (RBAC) for personal data stores.
- Audit logs for admin access to sensitive records.
- Incident response playbook for privacy/security breach.
- Periodic access review for support/moderation/admin roles.

---

## Edge Cases
1. Deactivated account reactivation after long inactivity: restore profile state but keep prior moderation restrictions.
2. Content deleted by user but under active report investigation: remains hidden publicly but retained for case resolution.
3. Export request from deactivated account: permit via verified identity and policy check.
4. Suspected underage account after signup: temporarily restrict and route to trust-and-safety verification review.

---

## Open Questions (non-blocking)
1. Exact legal-hold policy and maximum retention for moderation evidence.
2. Whether user-facing irreversible delete should be introduced in v1.1.
3. Exact underage detection/escalation mechanism beyond self-declared age.
