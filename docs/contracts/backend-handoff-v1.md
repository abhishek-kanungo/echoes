# Echoes Backend Handoff v1 (Web + Mobile Consumers)

## Purpose
This document is the implementation handoff for backend development so web and mobile clients can integrate against one stable MVP contract.

Primary machine-readable spec:
- `openapi/openapi.frontend-derived.yaml`

Primary rationale/context:
- `docs/contracts/frontend-implied-api-contracts.md`

---

## Contract guardrails (must hold)
1. **Stable IDs and timestamps**
   - Use opaque string IDs.
   - Return UTC ISO 8601 datetime for server timestamps.
2. **Consistent error envelope**
   - `{ "error": { "code": "...", "message": "...", "details": {...} } }`
3. **Cursor pagination**
   - Feed, echoes, and notifications return `next_cursor` consistently.
4. **Privacy and moderation readiness**
   - Echo privacy supported at create/update time.
   - Moderation report endpoint available from MVP.
5. **Web + Mobile parity**
   - No web-only response shape assumptions.
   - Avoid UI-derived/HTML-formatted strings in API contracts.

---

## Endpoint implementation checklist

## 1) Auth & user bootstrap

### POST `/auth/session`
**Goal**: start authenticated session from email/social provider.

**Request**
```json
{
  "provider": "email",
  "email": "user@example.com",
  "password": "secret"
}
```

**Success 200**
```json
{
  "access_token": "jwt-or-session-token",
  "onboarding_required": true,
  "user": {
    "id": "usr_123",
    "handle": "@newuser",
    "display_name": null,
    "dob": "1996-08-24",
    "city": "Mumbai",
    "interests": ["cricket", "films", "music"]
  }
}
```

**Error codes**
- `400` invalid payload
- `401` invalid credentials/token
- `429` rate-limited

**Client expectation**
- Web/mobile both read `onboarding_required` to route user.

---

### GET `/me`
**Goal**: hydrate session and profile.

**Success 200**
```json
{
  "id": "usr_123",
  "handle": "@you",
  "display_name": "You",
  "dob": "1995-06-14",
  "city": "Mumbai",
  "interests": ["cricket", "films", "music"]
}
```

**Error codes**
- `401` unauthorized/expired session

**Client expectation**
- Called on app launch by both clients.

---

## 2) Onboarding

### POST `/onboarding`
**Goal**: persist required onboarding fields.

**Request**
```json
{
  "dob": "1995-06-14",
  "city": "Mumbai",
  "interests": ["cricket", "films", "music"]
}
```

**Success 200**: returns full `User` object.

**Validation rules**
- `dob` required
- `city` required
- `interests` minimum 3

**Error codes**
- `400` invalid fields
- `401` unauthorized

**Client expectation**
- On success, both clients proceed to Past Feed.

---

## 3) Feed

### GET `/feed/past`
**Goal**: ranked, paginated event cards.

**Query params**
- `category` optional
- `cursor` optional
- `limit` optional (1..50)

**Success 200**
```json
{
  "items": [
    {
      "id": "evt_1",
      "slug": "india-wins-world-cup-2011",
      "title": "India Wins the Cricket World Cup",
      "category": "cricket",
      "event_date": "2011-04-02",
      "place_label": "Mumbai",
      "significance_summary": "Dhoni's iconic six...",
      "hero_image_url": "https://...",
      "relevance": {
        "cue_text": "You were 16 · Near Mumbai",
        "age_at_event": 16,
        "city_match": true
      },
      "engagement_counts": {
        "echoes": 2847,
        "reactions": 2981,
        "comments": 480,
        "saves": 210
      }
    }
  ],
  "next_cursor": "cur_abc"
}
```

**Error codes**
- `400` invalid query params
- `401` unauthorized

**Client expectation**
- Infinite scroll support via `next_cursor`.

---

## 4) Event detail and echoes

### GET `/events/{slug}`
**Goal**: full event surface for detail page.

**Success 200**
- Returns `EventDetail` schema in OpenAPI.
- Must include: title/category/date/place/media/significance + optional timeline + related events.

**Error codes**
- `404` not found
- `401` unauthorized (if policy requires auth)

**Client expectation**
- Web/mobile render from this object only (no side-map lookups).

---

### GET `/events/{eventId}/echoes`
**Goal**: list event memories with tabs/sort.

**Query params**
- `tab`: `friends|top|recent|nearby`
- `cursor`

**Success 200**
```json
{
  "featured": [{ "id": "ech_1", "event_id": "evt_1", "text": "...", "privacy": "public", "user": { "id": "usr_2", "handle": "@priya" }, "created_at": "2026-04-16T18:12:00Z" }],
  "items": [{ "id": "ech_2", "event_id": "evt_1", "text": "...", "privacy": "public", "user": { "id": "usr_3", "handle": "@rahul" }, "created_at": "2026-04-16T19:05:00Z" }],
  "next_cursor": null
}
```

**Error codes**
- `404` event not found
- `400` invalid tab/cursor

---

### POST `/events/{eventId}/echoes`
**Goal**: create user memory for an event.

**Request**
```json
{
  "text": "We all ran into the street when Dhoni hit that six.",
  "privacy": "public",
  "relative_location": "Hostel common room",
  "city": "Delhi",
  "first_experienced_month": "2011-04",
  "companions": ["Hostel gang"]
}
```

**Success 201**
- Returns created `Echo`.

**Hard rule**
- **One echo per event per user**.

**Error codes**
- `409` duplicate echo for `(eventId,userId)`
- `400` validation
- `401` unauthorized

**Client expectation**
- Web/mobile should treat `409` as “edit existing echo” affordance.

---

## 5) Comments & reactions

### GET `/echoes/{echoId}/comments`
**Goal**: load comment thread.

**Success 200**
```json
{ "items": [{ "id": "c_1", "echo_id": "ech_1", "parent_comment_id": null, "depth": 0, "body": "I remember this too", "created_at": "2026-04-16T20:00:00Z" }] }
```

**Rules**
- Max depth 2 (comment -> reply).

---

### POST `/echoes/{echoId}/comments`
**Request**
```json
{ "body": "Same memory!", "parent_comment_id": "c_1" }
```

**Success**: `201` with `Comment`.

**Errors**
- `400` invalid depth/body
- `404` echo/comment not found

---

### POST `/echoes/{echoId}/reactions`
**Request**
```json
{ "type": "emotional" }
```

**Allowed reaction enum**
- `love`, `funny`, `wow`, `emotional`, `that_was_us`

**Success**: `200`

**Errors**
- `400` invalid reaction type
- `404` echo not found

---

## 6) Saves / Time Capsule

### POST `/saves`
**Request**
```json
{ "object_type": "event", "object_id": "evt_1" }
```

**Success**: `201`

**Behavior**
- Save visibility defaults private.

---

### GET `/time-capsule?tab=events|memories`
**Success**: `200` with items array of saved objects.

**Client expectation**
- Same endpoint powers both web and mobile capsule tabs.

---

## 7) Prompts & notifications

### GET `/prompts`
**Goal**: fetch prompt cards (with server-side cap logic applied).

### GET `/notifications`
**Goal**: mixed notification feed with canonical `kind` enum.

**Notification kinds**
- `prompt`, `friend_request`, `comment`, `reaction`, `system`

---

## 8) Operational endpoint

### POST `/moderation/reports`
**Goal**: report content/user from client surfaces.

**Request (example)**
```json
{
  "target_type": "echo",
  "target_id": "ech_2",
  "reason": "harassment",
  "details": "Contains abusive language"
}
```

**Success**: `201`

---

## Definition of done for backend v1
1. All endpoints above implemented and response-validated against OpenAPI.
2. Error envelope and status code behavior consistent.
3. One-echo-per-event uniqueness enforced server-side.
4. Seed/dev data available so frontend integration can proceed without fixture imports.
5. Contract test suite added in backend CI.

---

## Integration sequencing recommendation
1. Auth + `/me`
2. Onboarding
3. Feed + event detail
4. Echo create/list
5. Comments/reactions
6. Saves/time-capsule
7. Prompts/notifications + moderation report

This sequence gets web to usable MVP quickly while keeping APIs mobile-ready from day one.
