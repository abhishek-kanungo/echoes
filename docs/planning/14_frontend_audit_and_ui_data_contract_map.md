# Echoes — Frontend Audit & UI/Data Contract Mapping (MVP)

## Purpose
Define the MVP frontend surface scope, implementation approach, and API contract mapping so UI development can run in parallel with backend without integration drift.

## Scope
In scope:
- frontend target platform strategy
- MVP UI surfaces
- design/component approach
- data fetching and error-handling model
- UI-to-API contract map

Out of scope:
- post-pilot native app architecture
- full visual design system maturity plan

---

## Locked Decisions
1. Runtime target: **Web-first now, mobile app after pilot**.
2. MVP surfaces: **Auth, For You feed, event page, memory composer, profile**.
3. Design system approach: **Established UI library for speed**.
4. Data fetching strategy: **Server-state library with caching/retries**.
5. Poor-network handling: **Basic retry + user-visible error states**.
6. Frontend quality bar: **Pixel-perfect for core loop screens**.

---

## Surface Inventory

## 1) Auth surfaces
- phone input + OTP verification
- token/session state handling

API dependencies:
- `POST /auth/otp/request`
- `POST /auth/otp/verify`
- `POST /auth/refresh`

## 2) For You feed
- ranked event cards
- prompt display
- navigation to event page

API dependencies:
- `GET /feeds/for-you`
- `GET /events/{slug}` (detail prefetch optional)

## 3) Event page
- event hero/title/summary/prompt
- memory list excerpt / CTA
- entry point to create memory

API dependencies:
- `GET /events/{slug}`
- `GET /events` (adjacent navigation)

## 4) Memory composer
- text input + up to 4 image attachments
- submit + optimistic/pending states

API dependencies:
- `POST /memories`
- `DELETE /memories/{memory_id}`
- `POST /memories/{memory_id}/reactions`
- `POST /memories/{memory_id}/comments`

## 5) Profile
- user identity display
- user-authored memory list
- follow stats/actions as available in MVP API scope

API dependencies:
- `GET /users/me`
- feed/memory endpoints for authored content views (until dedicated endpoint exists)

---

## UI Contract Mapping (by core loop)

### Core loop step 1: Relevant event discovery
UI: For You feed cards
Data contract fields needed:
- event id/slug/title/category/occurred_at/hero_image
- resolved prompt text
- social proof counters

### Core loop step 2: Emotional recognition
UI: event page + prompt block
Data contract fields needed:
- event summary
- prompt text
- memory_count

### Core loop step 3: Memory post/save/react
UI: composer + action buttons
Data contract fields needed:
- memory create payload/response schema
- reaction/comment mutation responses
- deletion semantics (immediate hide)

### Core loop step 4/5: social response + return
UI: profile + notifications entry points (MVP web-level basic rendering)
Data contract fields needed:
- reaction/comment/follow state indicators
- notification metadata availability (as backend exposes)

---

## Frontend Data Strategy
- Use server-state library for query caching/retries and mutation handling.
- Centralize API client with auth token refresh behavior.
- Normalize error envelope mapping (`errors[]`) into user-facing messages.
- Keep optimistic updates limited to low-risk actions (reaction toggles) in MVP.

---

## Error and Network UX
- Standard retry policy for idempotent reads.
- User-visible inline error states for failed writes.
- No offline queueing in MVP.
- Spinner/skeleton standards for feed/event surfaces.

---

## Pixel-Perfect Scope (strict)
Must be pixel-accurate at launch:
1. Auth screens
2. For You feed
3. Event page
4. Memory composer

Profile and non-core surfaces may prioritize functional correctness over perfect polish in early iterations.

---

## Implementation Notes
- Build web-first responsive layouts with mobile viewport priority.
- Keep component abstractions shallow for speed.
- Enforce API contract checks during CI via OpenAPI diff/validation hooks.

---

## Risks and Mitigations
1. Contract drift between frontend and backend
   - Mitigation: OpenAPI gate + contract tests + shared API types.
2. UI library mismatch with brand styling
   - Mitigation: theme tokens + targeted custom wrappers.
3. Slow perceived performance on feed
   - Mitigation: query caching + progressive rendering.

---

## Revisit Triggers
- External pilot requires native app parity.
- Web engagement ceiling indicates platform expansion urgency.
- UI library constraints materially block brand or accessibility targets.
