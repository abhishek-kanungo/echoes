# ADR-002: API Style, Versioning, and Authentication (MVP)

## Status
Accepted (MVP)

## Context
Echoes MVP needs a simple, consistent API contract that supports:
- mobile/web clients,
- fast iteration with minimal integration breakage,
- public event pages with optional personalization,
- authenticated social actions (follow, memory post, reaction, comments).

The canonical domain model is already locked for MVP and requires both public and authenticated read paths.

## Decision

### 1) API style and transport
- JSON over HTTPS REST API.
- Base path uses URL versioning: `/api/v1/...`.
- All responses use JSON objects; list responses include pagination metadata.

### 2) Authentication
- Token model: **JWT access token + refresh token pair**.
- Login method for MVP: **phone OTP only (India-first)**.
- Access token: short TTL, sent via `Authorization: Bearer <token>`.
- Refresh token: longer TTL, rotated on refresh.

### 3) Public event page data access
- Public event endpoints are available without auth.
- If auth is present, response may include personalization decorations (e.g., whether user has reacted/saved/following author contexts where relevant).

### 4) Error envelope
- Use JSON:API-like top-level error list:

```json
{
  "errors": [
    {
      "code": "invalid_request",
      "title": "Invalid request",
      "detail": "phone_number is required",
      "source": { "pointer": "/phone_number" }
    }
  ]
}
```

### 5) Rate limiting
- Enforce both:
  - per-IP limits (abuse/network protection), and
  - per-user limits (fair-use and anti-spam).
- Return HTTP `429` with retry metadata headers.

### 6) Time, IDs, and enums
- IDs: UUIDs for all first-class entities.
- Timestamps: ISO-8601 UTC strings.
- Enums remain explicit strings in payloads.

## Rationale
- URL versioning is explicit and easy for client teams.
- Access+refresh is standard for mobile/web while reducing forced re-logins.
- Phone OTP aligns with India-first launch and lowers sign-up friction.
- JSON:API-like errors improve consistency and debuggability.
- Dual-layer rate limiting addresses both anonymous abuse and authenticated spam.
- Optional-auth public event reads preserve SEO/shareability while allowing richer signed-in UX.

## Consequences
### Positive
- Clear integration contract for frontend and backend.
- Secure-enough auth for MVP without introducing full OAuth complexity.
- Public event pages remain shareable and crawlable.

### Negative / Tradeoffs
- OTP provider integration adds operational dependency.
- Refresh-token rotation requires careful token revocation logic.
- JSON:API-like error objects are slightly more verbose than simple error strings.

## Revisit Triggers
- Multi-region launch beyond India.
- Need for third-party auth providers (Google/Apple).
- Major client proliferation (public API ecosystem).
- Abuse profile exceeding current rate-limit strategy.
