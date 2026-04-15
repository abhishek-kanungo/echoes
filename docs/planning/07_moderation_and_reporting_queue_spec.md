# Echoes — Moderation & Reporting Queue Spec (MVP)

## Purpose
Define how reported content is triaged and actioned in MVP, balancing user safety, operational simplicity, and fast iteration for a public-memory product.

## Scope
In scope:
- Report intake model
- Moderation queue workflow
- Enforcement actions
- Reporter visibility
- Appeals policy for MVP

Out of scope:
- Automated classifier enforcement
- Full trust-and-safety policy playbook
- Regional legal escalation procedures beyond MVP baseline

---

## Locked Decisions
1. Moderation operating model: **Auto-action for high-confidence violations + manual appeal**.
2. Report reason taxonomy: **Small fixed set (5–7 reasons)**.
3. Queue prioritization: **Severity first, then recency**.
4. Enforcement ladder: **Warning -> temporary restriction -> suspension**.
5. Appeals in MVP: **No user-facing appeals UI yet; internal reversal path only**.
6. Reporter transparency: **Simple status only** (`received`, `reviewed`, `actioned`).

---

## Report Intake

Users can report:
- memories
- comments
- events

Required payload:
- target_type
- target_id
- reason_code
- optional notes

Reason code set (MVP initial):
1. harassment_or_abuse
2. hate_or_discrimination
3. sexual_or_nudity
4. violence_or_harm
5. misinformation_or_false_context
6. spam_or_scams
7. other

---

## Queue Prioritization

### Priority score
`priority = severity_weight + recency_weight + repeat_offender_weight`

Ordering:
1. Severity bucket (critical/high/medium/low)
2. Newest first inside same severity

Severity mapping examples:
- Critical: violence/harm, explicit sexual exploitation
- High: hate/abuse targeted at individuals/groups
- Medium: harassment, misinformation
- Low: spam/other

---

## Moderation Workflow

Status lifecycle:
`received -> reviewed -> actioned | dismissed`

### Step-by-step
1. Report created (`received`) and added to priority queue.
2. High-confidence auto-action rules run immediately.
3. Moderator reviews queue item.
4. Moderator confirms, escalates, or reverses auto-action.
5. Final state set to `actioned` or `dismissed`.
6. Reporter sees status change (no detailed rationale in MVP).

---

## Auto-Action Rules (MVP)

Auto-action is allowed only for high-confidence patterns with low false-positive tolerance:
- repeated identical scam/spam payloads from new accounts,
- banned keyword/image hash matches from known abuse lists,
- repeated policy-violating content from recently warned/restricted users.

Default auto-action type:
- immediate content hide (soft removal from public surfaces),
- queue item flagged `auto_action_pending_review=true` for moderator confirmation.

Safeguards:
- every auto-action is reviewable and reversible,
- all auto-actions logged in `ModerationAction` with trigger metadata.

---

## Enforcement Ladder

For user-level violations:
1. **Warning**
   - content removed, user informed of policy category.
2. **Temporary restriction**
   - limited posting/commenting for defined period.
3. **Suspension**
   - account disabled pending final internal review.

Escalation logic:
- severity + repeat history drive step jumps (critical can skip warning).

---

## Appeals Policy (MVP)

- No user-facing appeals UI in MVP.
- Internal reversal path only:
  - moderators/admins can restore content or reverse account action if error identified.
- Future revisit: introduce lightweight appeal request flow once moderation volume stabilizes.

---

## Reporter Transparency

Reporter-visible statuses only:
- `received`
- `reviewed`
- `actioned`

No detailed action descriptions or policy notes are shown in MVP.

---

## Data Retention & Audit

For each moderation action, store:
- action_type
- actor (human/system)
- target reference
- timestamp
- rule/version if auto-triggered
- optional rationale notes

Retention/deletion windows defer to privacy-retention spec.

---

## Operational Controls
- Global switch to disable auto-action if false positives spike.
- Per-reason code thresholds configurable without deploy.
- Daily QA sample of auto-action decisions for precision tracking.
- Weekly repeat-offender review list for policy tuning.

---

## Edge Cases
1. Mass-report brigading: apply reporter-rate controls and trust weighting in queue ingestion.
2. Deleted target before review: keep report record; mark as closed with reason `target_removed`.
3. Multiple reports on same target: aggregate into one case view with report count.
4. Moderator disagreement: escalate to admin decision and log consensus note.

---

## Open Questions (non-blocking)
1. Exact temporary restriction durations by violation tier.
2. Whether reporter trust score should move from non-blocking idea to active prioritization in MVP+1.
3. Whether event-level reports require a dedicated editorial+moderation joint queue or shared queue is sufficient.
