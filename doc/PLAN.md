# AI integration plan

이 문서는 `흘려쓰기 / Find Later`의 AI 기능을 구현하기 위한 phase, 작업 분리, Definition of Done(DoD)을 정의한다. 구현 원칙은 앱이 Codex CLI를 직접 알지 않고 `AIService`와 backend API만 알도록 유지하는 것이다.

## Target outcome

- 메모는 항상 원문을 먼저 저장한다.
- AI 분석은 실패해도 메모 저장을 방해하지 않는다.
- 자연어 검색은 기존 수동 검색 위에 보조 랭킹으로 붙는다.
- Codex CLI는 Node backend 내부 구현 세부사항으로 숨긴다.
- Local LLM, mock, backend provider를 나중에 교체할 수 있다.

## Architecture boundary

```text
iOS app
  -> AIService
  -> AIAdapter protocol
  -> BackendCodexAdapter
  -> http://100.72.125.75:8989
  -> Node backend
  -> CodexRunner
  -> codex exec
```

Non-goals for first AI pass:

- 앱에서 Codex CLI 직접 실행
- 외부 공개 API 서버 운영
- 계정/클라우드 동기화
- 자동 AI 적용
- embedding 기반 검색
- Markdown 편집기

## Phase 0. Documentation and task split

Goal: 구현자가 바로 작업을 시작할 수 있도록 문서를 분리하고 DoD를 고정한다.

Tasks:

- `doc/PLAN.md`에 phase별 DoD와 작업 순서를 둔다.
- `doc/AI-WORKFLOW.md`에 메모 분석/검색 workflow를 둔다.
- `doc/AI-BACKEND.md`에 backend API, 폴더 구조, Codex 실행 정책을 둔다.
- `doc/AI-APP.md`에 iOS app 계약, Swift 모델 확장, UI 동작을 둔다.
- 기존 포괄 문서 `doc/AI.md`는 삭제한다.

DoD:

- 위 문서들이 존재한다.
- `doc/AI.md`가 제거되어 중복 출처가 없다.
- Backend sub-agent가 `doc/AI-BACKEND.md`와 이 문서만 보고 작업 범위를 이해할 수 있다.
- App 작업자는 `doc/AI-APP.md`와 `doc/AI-WORKFLOW.md`만 보고 앱 쪽 구현 순서를 이해할 수 있다.

## Phase 1. App AI interface scaffold

Goal: 실제 네트워크 호출 없이 앱 내부 AI 추상화와 mock 흐름을 만든다.

Owner: iOS app agent.

Tasks:

- Swift protocol `AIAdapter`를 추가한다.
- `MockAIAdapter`를 구현한다.
- `BackendCodexAdapter` skeleton을 추가하되 실제 호출은 feature flag 뒤에 둔다.
- `AIService`를 추가해 앱 화면이 adapter를 직접 만지지 않게 한다.
- `Memo` 모델에 필요한 AI metadata gap을 채운다.
  - 현재 있음: `aiStatus`, `aiSuggestedTags`, `aiSuggestedCategory`
  - 추가 후보: `aiConfidence`, `aiProvider`, `aiError`
- `MemoStore`에 AI 결과 업데이트 API를 추가한다.

DoD:

- 앱이 네트워크 없이 build/test 통과한다.
- 새 메모 저장은 기존처럼 즉시 완료된다.
- mock 분석 결과를 store에 적용하는 단위 테스트가 있다.
- AI 실패 상태를 store에 기록하는 단위 테스트가 있다.
- UI에는 아직 실제 AI 호출이 붙지 않아도 된다.

## Phase 2. Backend skeleton

Goal: Codex CLI 없이도 health/API contract가 동작하는 Node backend를 만든다.

Owner: Backend sub-agent.

Write scope:

- `backend/`
- `doc/AI-BACKEND.md`가 필요한 경우에만 문서 보정

Tasks:

- `backend/package.json` 생성
- Express server 생성
- `GET /health`
- `POST /api/ai/memo/analyze`
- `POST /api/ai/search/extract-tags`
- request body size limit 추가
- CORS는 local/LAN MVP 기준으로 최소 허용
- mock provider 응답으로 API contract 검증

DoD:

- `npm install` 후 `npm test` 또는 `npm run test`가 통과한다.
- `npm start`로 `0.0.0.0:8989` 또는 설정된 host/port에서 서버가 뜬다.
- `curl http://100.72.125.75:8989/health` 또는 local equivalent가 JSON을 반환한다.
- 두 POST endpoint가 schema에 맞는 JSON을 반환한다.
- Codex CLI 미설치 상태에서도 mock mode로 동작한다.

## Phase 3. Codex CLI runner

Goal: Backend가 `codex exec`를 통해 JSON 분석 결과를 가져오도록 연결한다.

Owner: Backend sub-agent.

Tasks:

- `CodexRunner` 구현
- `MemoPromptBuilder` 구현
- `SearchPromptBuilder` 구현
- `JsonExtractor` 구현
- timeout 처리
- invalid JSON 1회 재시도
- schema validation
- provider mode: `mock | codex-cli`

Required Codex execution policy:

```bash
codex exec --ephemeral --sandbox read-only --ask-for-approval never "<PROMPT>"
```

DoD:

- Codex timeout이 HTTP 504 또는 명시적 실패 JSON으로 변환된다.
- invalid JSON은 재시도 후 실패 JSON으로 변환된다.
- 사용자 메모가 shell command로 실행되지 않는다.
- stdout에 설명/markdown이 섞여도 JSON만 추출하거나 실패 처리한다.
- prompt builder 단위 테스트가 injection-like input을 분석 대상 텍스트로 감싼다.

## Phase 4. Memo AI suggestion UI

Goal: 저장된 메모에 대해 사용자가 수동으로 AI 추천을 요청하고 적용할 수 있게 한다.

Owner: iOS app agent.

Tasks:

- Compose 저장 후 자동 적용은 하지 않는다.
- Memo detail 또는 compose result context에 `AI로 태그 추천` 버튼을 둔다.
- 버튼 탭 시 `aiStatus = pending`.
- 성공 시 추천 태그/카테고리를 별도 섹션에 표시한다.
- 사용자가 `적용`을 눌러야 tags/category가 실제 값으로 바뀐다.
- 실패 시 기존 메모 원문/수동 태그/수동 카테고리는 유지한다.

DoD:

- backend off 상태에서 앱이 깨지지 않는다.
- AI 실패 상태가 UI에 표시된다.
- 추천 결과는 자동 적용되지 않는다.
- 추천 태그 적용 후 store persist가 확인된다.
- 시뮬레이터에서 저장 -> 추천 요청 -> 적용/실패 흐름을 확인한다.

## Phase 5. Natural language search

Goal: 검색어를 AI 태그 후보로 변환하고 기존 로컬 메모를 더 잘 좁힌다.

Owner: iOS app agent, optional backend support.

Tasks:

- 검색 탭에 일반 검색과 AI 검색 상태를 분리한다.
- `AIAdapter.extractSearchTags(query, knownTags)` 호출을 붙인다.
- app side에서 known tags를 만든다.
- `NoteSearchService`를 추가한다.
- scoring을 적용한다.
  - exact tag match * 10
  - similar tag match * 6
  - title match * 5
  - category match * 4
  - rawText match * 2
  - recency bonus
- AI 실패 시 기존 text search 결과로 fallback한다.

DoD:

- 자연어 검색 실패가 검색 화면을 깨지 않는다.
- 기존 일반 검색 테스트가 계속 통과한다.
- queryTags/matchedTags가 UI 또는 debug state에서 확인 가능하다.
- `지난번 노트북 고장 관련해서 적어둔 거` 같은 검색이 seed memo를 찾는다.

## Phase 6. Provider switch and cleanup

Goal: Mock, backend Codex, future Local LLM provider를 설정으로 교체할 수 있게 정리한다.

Owner: iOS app agent and backend sub-agent.

Tasks:

- app AI provider 설정값 분리
- backend provider 설정값 분리
- LocalLLMAdapter는 not implemented stub 유지
- backend URL은 한 곳에서만 정의
- dev diagnostics를 추가한다.

DoD:

- mock provider로 네트워크 없이 앱 테스트 가능
- backend provider로 실제 API smoke 가능
- LocalLLMAdapter가 명시적으로 unimplemented error를 반환
- 문서의 endpoint/field와 코드 contract가 일치

## Backend sub-agent task brief

Use this prompt when delegating backend work to a separate sub-agent:

```text
You are implementing the Find Later AI backend only.

Read:
- doc/PLAN.md
- doc/AI-BACKEND.md
- doc/AI-WORKFLOW.md

Own write scope:
- backend/**
- doc/AI-BACKEND.md only if implementation details need correction

Do not edit:
- FindLater/**
- iOS project files
- static web mockup files

Objective:
Implement Phase 2 and Phase 3 backend support for the AI-ready MVP.

Required endpoints:
- GET /health
- POST /api/ai/memo/analyze
- POST /api/ai/search/extract-tags

Required modes:
- mock provider mode
- codex-cli provider mode

Safety:
- Codex runs only through `codex exec --ephemeral --sandbox read-only --ask-for-approval never`
- use an empty backend sandbox working directory
- enforce request body size limits
- enforce timeout
- validate JSON schema before responding

Final response:
- list changed files
- list commands run
- report endpoint smoke results
- report any unsupported assumptions
```

## Current known app state

- Native app already has `Memo.aiStatus`, `Memo.aiSuggestedTags`, `Memo.aiSuggestedCategory`.
- Native app currently persists memos through `MemoStore`.
- Existing AI UI is placeholder-only.
- Recent UX improvements are committed through `64cfe1e`.
