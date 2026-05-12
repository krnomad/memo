# AI workflow

This document describes how AI features should behave from the product and system perspective. It is the primary reference for app/backend integration flow.

## Principle

AI is assistive, not authoritative.

- Raw memo text is the source of truth.
- Manual tags and manual category remain user-owned.
- AI suggestions are stored separately until the user applies them.
- AI failure must not block memo creation, reading, browsing, or normal search.

## End-to-end topology

```text
iOS App
  -> AIService
  -> AIAdapter
  -> BackendCodexAdapter
  -> http://100.72.125.75:8989
  -> Node backend
  -> CodexRunner
  -> codex exec
  -> JSON response
  -> App local store
```

Provider replacement must stay possible:

```text
AIAdapter
  -> MockAIAdapter
  -> BackendCodexAdapter
  -> LocalLLMAdapter
```

## Memo analysis workflow

Recommended first implementation: manual button.

```text
1. User writes memo.
2. App saves rawText immediately.
3. Memo starts with manual tags/category.
4. User opens detail or post-save surface.
5. User taps "AI로 태그 추천".
6. App sets aiStatus = pending.
7. App calls POST /api/ai/memo/analyze.
8. Backend asks Codex CLI for JSON metadata.
9. Backend validates JSON.
10. App stores AI result as suggestions.
11. User reviews suggestions.
12. User taps apply.
13. App updates tags/category and persists.
```

Automatic analysis can be added later:

```text
save memo -> background AI request -> show suggestions later
```

Do not implement automatic application in the MVP. It makes the product feel less trustworthy and makes failures harder to reason about.

## Memo analysis state machine

```text
none
  -> pending
  -> done
  -> failed
```

State meanings:

- `none`: AI has not been requested.
- `pending`: request is in flight.
- `done`: validated suggestions are stored.
- `failed`: request failed; raw memo remains usable.

Failure examples:

- `timeout`
- `invalid_json`
- `backend_unreachable`
- `schema_validation_failed`

## Natural language search workflow

Search is the feature that best demonstrates "아무렇게나 써도 나중에 찾을 수 있다".

```text
1. User enters natural language query.
2. App collects knownTags from local memos.
3. App calls POST /api/ai/search/extract-tags.
4. Backend returns queryTags, matchedTags, categoryHints.
5. App runs local search scoring.
6. App shows ranked memo results.
7. If AI fails, app falls back to existing text search.
```

Example:

```text
Query:
지난번 노트북 고장 관련해서 적어둔 거

AI queryTags:
["노트북", "고장", "블루스크린", "윈도우"]

matchedTags:
["노트북", "블루스크린", "윈도우", "문제해결"]
```

## Search ranking

Start with simple local scoring.

```text
score =
  exact tag match * 10
+ similar tag match * 6
+ title match * 5
+ category match * 4
+ rawText match * 2
+ recency bonus
```

MVP matching order:

```text
1. exact match
2. lowercase / trim / Korean whitespace removal
3. char n-gram similarity
4. small synonym dictionary
5. future embedding vector
```

## Backend request flow

Memo analysis:

```http
POST /api/ai/memo/analyze
Content-Type: application/json

{
  "text": "내일 철수한테 전화하고 Growise 견적 다시 봐야함",
  "locale": "ko-KR"
}
```

Search tag extraction:

```http
POST /api/ai/search/extract-tags
Content-Type: application/json

{
  "query": "지난번 노트북 고장 관련해서 적어둔 거",
  "knownTags": ["노트북", "블루스크린", "윈도우", "문제해결"]
}
```

## UX rules

- AI controls should use sage visual treatment.
- Do not show AI as required for saving.
- Use "추천" wording, not "자동 정리 완료", until the user accepts.
- Show failure as recoverable.
- Keep the compose flow fast; AI belongs after save or in detail.

## Fallback behavior

Memo analysis fallback:

```text
AI request fails
  -> aiStatus = failed
  -> aiError saved
  -> rawText/tags/category unchanged
```

Search fallback:

```text
AI search fails
  -> use existing local text search
  -> optionally show small "AI 검색을 사용할 수 없습니다" hint
```

## References

- Backend details: `doc/AI-BACKEND.md`
- App contracts: `doc/AI-APP.md`
- Phase plan and DoD: `doc/PLAN.md`
