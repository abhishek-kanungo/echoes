# ADR-015: Media and Image Strategy for Echoes MVP

## Status
Accepted (MVP)

## Context
Echoes MVP supports memories with up to 4 images. Media handling must balance UX quality, moderation safety, and operational simplicity in an India-first launch while preserving a path to future scale.

## Decision
1. **Storage model:** Object storage bucket + CDN.
2. **Processing model:** App-side processing at upload (resize/compress) and store derivatives.
3. **Per-image upload limit:** 5 MB.
4. **Accepted formats:** JPEG, PNG, WebP.
5. **Moderation scan path:** Async scan after upload; hide content if flagged.
6. **URL policy:** Signed/expiring URLs for originals + public CDN URLs for safe derivatives.

## Rationale
- Object storage + CDN is the simplest reliable baseline for web-first media delivery.
- App-side processing avoids early dependency on advanced external image pipelines.
- 5 MB cap controls storage and bandwidth costs while supporting common mobile captures.
- JPEG/PNG/WebP cover mainstream browser and mobile compatibility.
- Async moderation scanning avoids upload flow latency while still enforcing safety post-upload.
- Split URL policy protects originals while allowing high-performance public derivative delivery.

## Consequences
### Positive
- Predictable infra pattern with low operational complexity.
- Faster feed/event page rendering via CDN derivatives.
- Safer handling of originals with signed URL access.

### Tradeoffs
- Async moderation means brief exposure risk window before flagging action completes.
- App-side image processing can increase app/worker CPU load.
- Additional logic needed to ensure flagged assets are removed from public derivatives quickly.

## Implementation Notes
- Derivative generation at upload time (e.g., thumb, feed, detail sizes).
- Store moderation status per image asset.
- On flagged result:
  - hide associated memory from public surfaces,
  - block derivative access where policy requires,
  - create moderation queue entry.
- Keep audit trail linking asset -> memory -> moderation action.

## Revisit Triggers
- Upload volume or transformation cost exceeding current worker capacity.
- Need for stricter real-time pre-publication moderation.
- Expansion to video or richer media types.
- Multi-region latency requirements.
