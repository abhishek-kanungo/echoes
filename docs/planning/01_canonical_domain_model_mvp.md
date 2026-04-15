# Echoes — Canonical Domain Model (MVP)

## Purpose
Define the implementation-ready canonical entities, relationships, and lifecycle rules for Echoes MVP so backend APIs, frontend surfaces, ranking, moderation, and analytics can work from one source of truth.

## Scope (MVP only)
Included:
- Users and lightweight profiles
- Place context (current city + hometown)
- Events and event geo tags
- Memories (public), memory media attachments, reactions, comments
- Follow graph
- Editorial prompts
- Reports and moderation actions
- Soft-delete semantics for memory content

Excluded (post-MVP):
- Private/friends-only visibility
- Threaded comments
- Multi-reaction schema
- User-created published events without editorial approval

---

## Locked Decisions

1. Event source of truth: ingestion pipeline with editorial approval gate.
2. Event creation authority: internal/admin only.
3. Comment moderation: post-first + report/removal.
4. Memory edits: no edit; delete/repost only.
5. Feed model: following feed + For You feed.
6. Public event URL model: stable slug (`/events/:slug`).
7. Memory visibility: public-only.
8. Identity: username required; display name/profile photo optional.
9. Event geo granularity: country + state + city tags.
10. User place context: current city + hometown.
11. Memory attachment support: text + up to 4 images.
12. Reactions: single lightweight reaction type.
13. Comments: flat comments enabled.
14. Prompt model: hybrid template + per-event editorial override.
15. Social graph: follow model (asymmetric).
16. Deletion semantics: immediate user-visible removal with internal soft-delete.

---

## Core Entities

## 1) User
Represents account identity and profile.

Fields:
- id (uuid)
- username (unique, required)
- display_name (optional)
- profile_photo_url (optional)
- hometown_city_id (optional FK -> City)
- current_city_id (optional FK -> City)
- created_at, updated_at
- deactivated_at (nullable)

Constraints:
- username immutable after initial grace period (implementation detail in auth/profile spec).

## 2) Follow
Asymmetric social relationship.

Fields:
- follower_user_id (FK -> User)
- followed_user_id (FK -> User)
- created_at

Constraints:
- unique composite (follower_user_id, followed_user_id)
- self-follow disallowed

## 3) Event
Canonical cultural moment shown in feeds and public pages.

Fields:
- id (uuid)
- slug (unique, stable)
- title
- summary
- description (optional longform)
- category (enum: cricket, films, tv, internet_culture, music, safe_public_moment)
- occurred_at (timestamp)
- geo_scope_country_codes (array)
- geo_scope_state_codes (array)
- geo_scope_city_ids (array FK refs)
- prompt_template_key (optional)
- editorial_prompt_override (optional)
- hero_image_url (optional)
- source_confidence (enum: low/medium/high)
- editorial_status (enum: draft, review, approved, rejected, archived)
- published_at (nullable)
- created_by_user_id (internal admin FK)
- created_at, updated_at

Constraints:
- only `approved` events can be published and ranked.
- slug must remain stable once published.

## 4) Memory
User-authored memory tied to an event.

Fields:
- id (uuid)
- user_id (FK -> User)
- event_id (FK -> Event)
- body_text (required, bounded length)
- visibility (enum; MVP always `public`)
- deleted_at (nullable, soft-delete)
- delete_reason (nullable enum: user_deleted, moderation_removed, policy_removed)
- created_at, updated_at

Constraints:
- No edit flow in MVP: updates after publish are disallowed except internal moderation fields.
- Soft-deleted memories excluded from all user-visible APIs immediately.

## 5) MemoryImage
Image attachments for memories (max 4).

Fields:
- id (uuid)
- memory_id (FK -> Memory)
- storage_key
- cdn_url
- position (1..4)
- width, height (optional)
- created_at

Constraints:
- max 4 per memory.
- accepted type/size constraints deferred to media strategy ADR.

## 6) MemoryReaction
Single lightweight reaction.

Fields:
- memory_id (FK -> Memory)
- user_id (FK -> User)
- reaction_type (enum; MVP fixed single value: `felt_this`)
- created_at

Constraints:
- unique composite (memory_id, user_id, reaction_type).

## 7) MemoryComment
Flat comments on memories.

Fields:
- id (uuid)
- memory_id (FK -> Memory)
- user_id (FK -> User)
- body_text
- deleted_at (nullable)
- created_at, updated_at

Constraints:
- Flat only in MVP (no parent_comment_id).
- Post-first moderation model.

## 8) PromptTemplate
Reusable prompt text by category/event archetype.

Fields:
- key (unique)
- category (enum aligned with Event.category)
- text
- active (bool)
- created_at, updated_at

Resolution order:
1. Event.editorial_prompt_override
2. Event.prompt_template_key → PromptTemplate.text
3. System fallback prompt by category

## 9) Report
User-generated moderation report for memory/comment/event.

Fields:
- id (uuid)
- reporter_user_id (FK -> User)
- target_type (enum: memory, comment, event)
- target_id (uuid)
- reason_code (enum; defined in moderation spec)
- notes (optional)
- status (enum: open, triaged, actioned, dismissed)
- created_at, updated_at

## 10) ModerationAction
Audit log of moderation decisions.

Fields:
- id (uuid)
- target_type, target_id
- action_type (enum: remove_content, warn_user, ban_user, restore_content)
- actor_user_id (internal moderator)
- rationale
- created_at

---

## Relationship Map (high-level)
- User 1—N Memory
- Event 1—N Memory
- Memory 1—N MemoryImage
- Memory 1—N MemoryComment
- Memory 1—N MemoryReaction
- User N—N User via Follow
- Event 1—N Memory (core emotional loop linkage)
- Report targets Event/Memory/Comment polymorphically

---

## Lifecycle Rules

### Event lifecycle
`draft -> review -> approved -> published -> archived`
- Ranking, notifications, and public event pages operate only on published events.

### Memory lifecycle
`created -> published (immediate) -> soft_deleted (optional)`
- No edit state in MVP.
- Deletion immediately hides content publicly while preserving internal record.

### Comment lifecycle
`created -> visible -> deleted (optional)`
- Post-first; moderation acts after report/flags.

---

## Feed Data Contracts (entity-level)

For You feed item requires:
- Event core fields (id/slug/title/category/occurred_at/hero)
- Prompt resolved text
- Social proof counters (memory_count, reaction_count)
- User relevance metadata (geo/age/interest match signals handled in ranking spec)

Following feed item requires:
- Memory core fields + author profile snapshot
- Associated Event summary (id/slug/title)

---

## Edge Cases
- Event slug collision: reject publish until unique slug resolved.
- Event geo sparse data: allowed (country-only event still valid), but schema supports full country/state/city tagging.
- User missing hometown/current city: ranking should gracefully degrade to interests + global popularity.
- Deleted memory with existing comments/reactions: cascade hide from user-visible queries; retain internally.
- User deactivation: authored memories/comments hidden by policy rule (final behavior in privacy/moderation specs).

---

## Dependencies / Follow-up Docs
This model is upstream of:
- API style/auth ADR
- OpenAPI MVP spec
- Event ingestion/editorial workflow spec
- Ranking & notification spec
- Moderation queue spec
- Privacy/retention/deletion spec

---

## Open Questions (non-blocking for schema draft, blocking for API finalization)
1. Username mutability window (e.g., one change vs fixed forever).
2. Exact body/comment max lengths.
3. Initial report reason taxonomy and moderation SLA targets.
4. Whether event-level comments are needed later (currently memory-only comments).
