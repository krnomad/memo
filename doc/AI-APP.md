# AI app integration contract

This document describes the iOS app side of the AI integration.

## Current app state

Already present:

- `Memo.rawText`
- `Memo.title`
- `Memo.category`
- `Memo.tags`
- `Memo.source`
- `Memo.aiStatus`
- `Memo.aiSuggestedTags`
- `Memo.aiSuggestedCategory`
- `MemoStore.createMemo`
- `MemoStore.search`

Recommended additions:

```swift
var aiConfidence: Double?
var aiProvider: AIProvider
var aiError: String?
```

Suggested enum:

```swift
enum AIProvider: String, Codable, Sendable {
    case none
    case mock
    case codexCLI = "codex-cli"
    case localLLM = "local-llm"
}
```

## Swift contracts

Use protocols so app UI does not know the backend implementation.

```swift
protocol AIAdapter {
    func extractMemoMetadata(text: String) async throws -> MemoAIResult
    func extractSearchTags(query: String, knownTags: [String]) async throws -> SearchAIResult
}
```

```swift
struct MemoAIResult: Decodable, Equatable {
    var title: String
    var category: MemoCategory
    var tags: [String]
    var entities: MemoEntities
    var importance: MemoImportance
    var isTask: Bool
    var confidence: Double
    var provider: String
}
```

```swift
struct SearchAIResult: Decodable, Equatable {
    var queryTags: [String]
    var matchedTags: [String]
    var categoryHints: [MemoCategory]
    var confidence: Double
    var provider: String
}
```

## Adapter implementations

Initial implementations:

- `MockAIAdapter`
- `BackendCodexAdapter`
- `LocalLLMAdapter` placeholder

Backend URL:

```swift
let aiBackendBaseURL = URL(string: "http://100.72.125.75:8989")!
```

Keep this value in one configuration location.

## AIService responsibilities

`AIService` should own:

- adapter selection
- request dispatch
- result mapping
- error normalization

UI should call `AIService`, not adapters.

## MemoStore additions

Suggested APIs:

```swift
func markMemoAIAnalysisPending(id: Memo.ID)
func applyMemoAISuggestions(id: Memo.ID, result: MemoAIResult)
func markMemoAIAnalysisFailed(id: Memo.ID, error: String)
func acceptAISuggestions(id: Memo.ID)
```

Behavior:

- pending persists immediately
- done stores suggestions separately
- accept applies suggestions to `tags` and `category`
- failed keeps existing raw/manual data unchanged

## Memo analysis UI

Recommended first UI:

- In memo detail, show a sage `AI로 태그 추천` button.
- On tap, set status to pending and call AI.
- On success, show suggested tags/category in a separate suggestion section.
- User must tap `적용`.
- On failure, show a small retryable error hint.

Do not:

- auto-overwrite manual tags
- block save on AI
- put AI controls in the primary compose path before raw text is saved

## Search UI

Search should support both:

- local text search
- AI-assisted natural language search

Flow:

```text
query entered
  -> local search immediately
  -> AI search optional/in parallel
  -> if AI succeeds, merge/rerank
  -> if AI fails, keep local results
```

App constructs `knownTags` from local memo tags.

## Tag vector interface

Keep this independent from AI provider.

```swift
protocol TagVectorAdapter {
    func buildVector(_ text: String) -> [Double]
    func similarity(_ lhs: [Double], _ rhs: [Double]) -> Double
}
```

Initial implementation:

```text
HashingNgramTagVectorAdapter
```

Future replacements:

- Local embedding
- BGE-M3
- Ollama embedding
- OpenAI embedding

## App DoD summary

- App builds without backend.
- Mock provider works without network.
- Backend provider failure does not break memo save/search.
- AI suggestions are visible but not auto-applied.
- Search has local fallback.
- Simulator test covers save, search, browse, and AI failure path before device install.
