# 흘려쓰기 / Find Later

아무렇게나 써도 나중에 찾을 수 있는 iOS 메모앱 MVP입니다. 현재 저장소에는 정적 웹 mockup, SwiftUI iOS 앱, AI 연동용 Node backend가 함께 들어 있습니다.

## 현재 상태

- SwiftUI 네이티브 앱 구현 완료
- GitHub Pages용 웹 mockup 및 소개 슬라이드 유지
- AI-ready 메모 데이터 구조 적용
- 메모 상세에서 수동 AI 태그/카테고리 추천 요청 가능
- 자연어 검색 보조 UI 및 로컬 scoring 구현
- Node backend mock provider 실행 가능
- Codex CLI runner/prompt/json 추출 레이어 구현

AI는 보조 기능입니다. 메모 원문과 사용자가 직접 입력한 태그/카테고리가 우선이며, AI 추천은 사용자가 `적용`을 누르기 전까지 실제 분류를 덮어쓰지 않습니다.

## 구조

```text
FindLater/                 SwiftUI iOS 앱
FindLater/AI/              AIService, provider 설정, adapter
FindLater/Models/          Memo, MemoStore, 검색 scoring
FindLater/Views/           최근/탐색/검색/상세/작성 화면
FindLaterTests/            단위 테스트
FindLaterUITests/          시뮬레이터 UI 테스트
backend/                   Node AI backend
doc/                       AI 연동 계획과 앱/백엔드 계약
index.html, slide.html     정적 웹 mockup과 소개 슬라이드
```

## 실행

웹 mockup:

```text
https://krnomad.github.io/memo/
https://krnomad.github.io/memo/slide.html
```

iOS 앱 테스트:

```bash
xcodebuild test \
  -project FindLater.xcodeproj \
  -scheme FindLater \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

백엔드 실행:

```bash
cd backend
npm install
npm start
```

현재 MVP backend 기본 URL:

```text
http://100.72.125.75:8989
```

상태 확인:

```bash
curl http://100.72.125.75:8989/health
```

## Backend

주요 endpoint:

```text
GET  /health
POST /api/ai/memo/analyze
POST /api/ai/search/extract-tags
```

환경 변수:

```text
PORT=8989
HOST=0.0.0.0
AI_PROVIDER=mock | codex-cli
CODEX_TIMEOUT_MS=20000
REQUEST_BODY_LIMIT=16kb
```

테스트:

```bash
cd backend
npm test
```

## iOS AI Provider

앱은 launch argument로 provider를 바꿀 수 있습니다.

```text
--ai-provider mock
--ai-provider backend
--ai-provider local
--ai-backend-url http://100.72.125.75:8989
--ai-diagnostics
```

기본값은 `mock`입니다. `local` provider는 명시적으로 `notImplemented`를 반환하는 stub입니다.

## 문서

```text
doc/PLAN.md          Phase와 DoD
doc/AI-WORKFLOW.md   앱-백엔드-Codex workflow
doc/AI-BACKEND.md    Backend API와 Codex 실행 정책
doc/AI-APP.md        iOS adapter/store/UI 계약
```

## 배포/설치

- GitHub Pages: `https://krnomad.github.io/memo/`
- iOS bundle id: `com.krnomad.FindLater`
- 기존 `io.krnomad.cartoonvault.ios` 앱을 덮어쓰지 않습니다.
