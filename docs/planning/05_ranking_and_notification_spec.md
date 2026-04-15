# Echoes — Ranking & Notification Spec (MVP)

## Purpose
Define how Echoes prioritizes events/memories for discovery and how prompt-driven return notifications are triggered, while staying simple, explainable, and iteration-friendly for MVP.

## Scope
In scope:
- For You ranking strategy
- Following feed ordering rules
- Cold-start behavior
- Notification channels and cadence
- Safety and fatigue guardrails
- Basic experimentation hooks

Out of scope:
- ML model training pipelines
- Multi-armed bandits / deep personalization systems
- Cross-channel growth automation

---

## Locked Decisions
1. Ranking objective: **Emotional relevance first, then popularity** (selected as best-fit default to product thesis).
2. Signal weights source: **Rule-based tiers per category**.
3. Cold-start strategy: **Onboarding interests + city/hometown + trending fallback**.
4. Notification channels: **In-app + email digest**.
5. Notification trigger cadence: **Real-time social actions + daily rediscovery prompt**.
6. Prompt-driven return policy: **Max 1 rediscovery prompt/day/user**.

---

## Ranking Architecture (MVP)

### Feed surfaces
1. **For You**: event-centric recommendations designed to trigger memory recall.
2. **Following**: memory-centric stream from followed users.

### For You scoring formula (rule-based)
`score = relevance_tier + freshness_bonus + social_proof_bonus + editorial_priority_bonus`

Where:
- `relevance_tier` (dominant term):
  - tier 1: category interest match + geo match
  - tier 2: category interest match only
  - tier 3: geo match only
  - tier 4: global/trending fallback
- `freshness_bonus` favors recent event anniversaries and current cultural spikes.
- `social_proof_bonus` uses bounded counts (memories/reactions/comments).
- `editorial_priority_bonus` allows temporary boosts for launch-critical moments.

### Why relevance-first
This directly supports the Echoes loop (recognition before reaction), and avoids a popularity-only feed that over-amplifies mainstream items at the expense of personal recall.

---

## Signal Inputs

## User profile signals
- selected interests (category-level)
- current city
- hometown
- follow graph density (lightweight social relevance)

## Event signals
- category
- geo tags (country/state/city)
- occurred_at and anniversary proximity
- editorial quality/confidence flags
- optional editorial boost window

## Social proof signals
- memory_count
- reaction_count (`felt_this`)
- comment_count
- follow-network interaction proximity

---

## Following Feed Ordering
- Primary sort: newest memory first.
- Secondary tie-breakers: interaction velocity and author affinity.
- Hard filter: hide soft-deleted or moderated-removed content immediately.

---

## Cold-Start Strategy
For users with low/no interaction history:
1. Build candidate set from interests + hometown/current-city matching events.
2. Fill gaps using category-trending events.
3. Apply diversity cap so one category cannot dominate first-page impressions.

Fallback behavior if profile is incomplete:
- Use national trending + India-first default categories.

---

## Notification Model (MVP)

## Channels
- In-app notifications (real-time social + rediscovery prompts).
- Email digest support enabled for prompt-driven return (lightweight cadence, not high-frequency marketing).

## Trigger types
1. **Social action trigger (real-time/in-app):**
   - someone reacts to your memory,
   - someone comments on your memory,
   - someone follows you.

2. **Rediscovery prompt (scheduled):**
   - at most one per user per day,
   - selected from top-ranked unengaged event candidates,
   - suppress if user already engaged heavily in last 24h.

## Daily rediscovery selection logic
- Candidate pool: events in top relevance tiers not yet acted on.
- Exclusions: recently shown prompts, already-muted categories, low-quality flags.
- Pick top candidate after fatigue checks.

---

## Fatigue and Safety Guardrails
- Max 1 rediscovery prompt/day/user.
- Do not send rediscovery within cooldown window after recent open/post session.
- Quiet hours respected by user locale settings (default India-friendly evening windows for initial launch unless user overrides later).
- Exclude out-of-scope sensitive events by ingestion policy.

---

## Metrics & Instrumentation (MVP)
Track at minimum:
- feed_impression
- feed_item_click
- memory_create_from_prompt
- reaction_create
- comment_create
- follow_create
- notification_sent (type/channel)
- notification_open
- notification_to_action_conversion

Core health metrics:
- D1/D7 return rate from prompts
- memory creation rate per active user
- prompt conversion rate
- feed diversity score (category spread)

---

## Operational Controls
- Category-level weight tuning table editable without deploy.
- Editorial priority boosts with start/end timestamps.
- Global kill-switch for rediscovery notifications.
- Per-channel send pause (email or in-app) for incident response.

---

## Edge Cases
1. User with zero profile data: fallback trending-only but capped for diversity.
2. Event with high global popularity but low relevance: capped in top slots for relevance-first integrity.
3. Notification storm from viral memory: per-user burst limits and digest fallback.
4. Deleted memory after notification sent: notification click resolves gracefully to unavailable content state.

---

## Open Questions (non-blocking)
1. Should email digest be strictly daily or configurable weekly for low-engagement users?
2. Exact cooldown duration before rediscovery prompt after active session.
3. Whether follow-affinity should influence For You ranking in MVP or v1.1.
