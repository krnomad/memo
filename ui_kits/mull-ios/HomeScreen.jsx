// 홈 화면 — 최근 메모 리스트
function HomeScreen({ onCompose, onSearch, onTabChange, active = "home" }) {
  const notes = [
    {
      title: "왜 이렇게 정리하기가 싫지",
      preview: "그냥 적기만 하고 싶다. 분류는 나중에. 어차피 검색하면 다 나오니까.",
      category: "아이디어", tags: ["생각", "메타"],
      date: "방금", aiPending: true,
    },
    {
      title: "장보기",
      preview: "오트밀, 사과 두 개, 두유, 빨래세제, 그리고 잊지 말고 우표.",
      category: "장보기", tags: ["주말"],
      date: "오후 2:14",
    },
    {
      title: "면접 답변 정리",
      preview: "내가 진짜 잘하는 건 뭐지. 디테일에 강하다. 끝까지 본다. 그런데 시작이 느리다…",
      category: "일/업무", tags: ["취업", "준비"],
      date: "어제",
    },
    {
      title: "주방 리노베이션 메모",
      preview: "타일 견적 다시 받기. 싱크대 위치는 그대로 두는 게 나을 듯.",
      category: "일상", tags: ["집", "예산"],
      date: "월",
      aiPending: true,
    },
    {
      title: "책 — 가만한 당신",
      preview: "p.78 — “결국 우리는 우리가 잊지 못한 것의 합이다.”",
      category: "독서", tags: ["인용"],
      date: "일",
    },
    {
      title: "공항에서",
      preview: "두 시간 남았다. 노트북 가져올 걸 그랬나. 책이 더 나을지도.",
      category: "일상", tags: [],
      date: "5월 8일",
    },
  ];
  return (
    <>
      <StatusBar />
      <NavBarLarge
        title="흘려쓰기"
        sub="대충 쓰고, 나중에 찾기"
        trailing={
          <IconBtn label="더보기" color="var(--fg-2)">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="2"/><circle cx="5" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>
          </IconBtn>
        }
      />
      <SearchField placeholder="검색" onFocus={onSearch} />

      <div style={{
        flex: 1, overflow: "auto",
        padding: "16px 16px 120px",
        display: "flex", flexDirection: "column", gap: 10,
      }}>
        <div style={{
          font: "500 13px/16px var(--font-ui)", color: "var(--fg-3)",
          textTransform: "uppercase", letterSpacing: 0.06,
          padding: "0 4px 2px",
        }}>오늘</div>
        {notes.slice(0,1).map((n,i) => <NoteCard key={i} note={n} />)}
        <div style={{
          font: "500 13px/16px var(--font-ui)", color: "var(--fg-3)",
          textTransform: "uppercase", letterSpacing: 0.06,
          padding: "8px 4px 2px",
        }}>이번 주</div>
        {notes.slice(1,4).map((n,i) => <NoteCard key={i} note={n} />)}
        <div style={{
          font: "500 13px/16px var(--font-ui)", color: "var(--fg-3)",
          textTransform: "uppercase", letterSpacing: 0.06,
          padding: "8px 4px 2px",
        }}>지난 주</div>
        {notes.slice(4).map((n,i) => <NoteCard key={i} note={n} />)}
      </div>

      <ComposeFab onClick={onCompose} />
      <TabBar active={active} onChange={onTabChange} />
    </>
  );
}

Object.assign(window, { HomeScreen });
