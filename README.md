# 흘려쓰기 / Find Later

아무렇게나 써도 나중에 찾을 수 있는 iOS 메모앱 MVP입니다.

현재 저장소에는 세 가지 결과물이 함께 있습니다.

- 정적 웹 mockup: GitHub Pages에서 확인하는 iPhone canvas
- SwiftUI iOS 앱: 실제 iPhone/Simulator에 설치 가능한 MVP
- AI 연동 계획 문서: Codex CLI backend와 app adapter 구조

## 현재 구현

- 빠른 메모 작성
- 원문 저장
- 수동 태그 입력
- 수동 카테고리 선택
- 최근 / 탐색 / 검색 탭
- 메모 상세 보기
- 롱프레스 삭제 메뉴
- 검색 탭 빠른 메모 버튼
- 좌우 스와이프 탭 이동
- AI placeholder UI

AI 기능은 아직 실제 호출하지 않습니다. 앱은 AI-ready 데이터 구조와 placeholder만 갖고 있습니다.

## 웹 mockup

```text
https://krnomad.github.io/memo/
https://krnomad.github.io/memo/slide.html
```

로컬에서는 `index.html` 또는 `slide.html`을 브라우저에서 열면 됩니다.

## iOS 앱

Xcode project:

```text
FindLater.xcodeproj
```

주요 파일:

```text
FindLater/
  Models/
  Views/
  Theme.swift
  FindLaterApp.swift
```

테스트:

```bash
xcodebuild test \
  -project FindLater.xcodeproj \
  -scheme FindLater \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

실기기 설치 시 현재 bundle id는 다음을 사용합니다.

```text
com.krnomad.FindLater
```

기존 `io.krnomad.cartoonvault.ios` 앱을 덮어쓰지 않습니다.

## AI 연동 문서

기존 포괄 문서 `doc/AI.md`는 제거하고 아래 문서로 나눴습니다.

```text
doc/PLAN.md          Phase, DoD, sub-agent 작업 분리
doc/AI-WORKFLOW.md   앱-백엔드-Codex workflow
doc/AI-BACKEND.md    Node backend/API/Codex runner 계약
doc/AI-APP.md        iOS app AI adapter/store/UI 계약
```

예정 구조:

```text
iOS app
  -> AIService
  -> AIAdapter
  -> BackendCodexAdapter
  -> Node backend :8989
  -> codex exec
```

원칙:

- 앱은 Codex CLI를 직접 알지 않는다.
- 메모 원문 저장이 항상 먼저다.
- AI 실패가 메모 저장 실패로 이어지면 안 된다.
- 추천 태그/카테고리는 사용자가 적용하기 전까지 제안으로만 둔다.

## 디자인 방향

- warm paper 배경
- warm ink 텍스트
- terracotta primary accent
- sage AI placeholder
- Apple Notes, Bear, Things 사이의 차분한 iOS 감성

## 상태

- 웹 mockup 배포 완료
- SwiftUI MVP 실기기 설치 확인
- AI 연동은 문서화 및 phase 분리 완료
