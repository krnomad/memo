// 검색 화면 — 빠르고 단순한 결과
function SearchScreen({ onTabChange, active = "search", onCompose }) {
  const [q, setQ] = useState("");

  const recents = ["면접", "타일", "주방", "p.78", "오트밀"];
  const popularTags = ["메타", "생각", "집", "독서", "예산"];

  // 더미 결과 (q가 비어있지 않으면 표시)
  const results = q ? [
    {
      title: "면접 답변 정리",
      preview: "내가 진짜 잘하는 건 뭐지. 디테일에 강하다. 끝까지 본다…",
      category: "일/업무", tags: ["취업", "준비"],
      date: "어제", aiPending: false,
      highlight: "면접",
    },
    {
      title: "면접 후기 — 5월 3일",
      preview: "회의실이 너무 추웠다. 마지막 질문에서 살짝 막혔는데…",
      category: "일/업무", tags: ["취업"],
      date: "5월 4일",
      highlight: "면접",
    },
    {
      title: "면접 준비 체크리스트",
      preview: "복장, 출력물, 도착 시간, 자기소개 30초.",
      category: "일/업무", tags: ["준비"],
      date: "4월 28일",
      highlight: "면접",
    },
  ] : [];

  // 검색어를 카드 미리보기에서 하이라이트
  const highlight = (text, kw) => {
    if (!kw) return text;
    const parts = text.split(new RegExp(`(${kw})`, "g"));
    return parts.map((p, i) => p === kw
      ? <mark key={i} style={{ background: "var(--terracotta-100)", color: "var(--terracotta-900)", borderRadius: 3, padding: "0 2px" }}>{p}</mark>
      : <span key={i}>{p}</span>);
  };

  return (
    <>
      <StatusBar />
      <div style={{ padding: "8px 0 4px" }}>
        <SearchField value={q} onChange={setQ} placeholder="메모 · 태그 · 카테고리 검색" autoFocus />
      </div>

      <div style={{ flex: 1, overflow: "auto", padding: "12px 16px 120px" }}>
        {!q && (
          <>
            <div style={{
              font: "500 13px/16px var(--font-ui)", color: "var(--fg-3)",
              textTransform: "uppercase", letterSpacing: 0.06,
              padding: "4px 4px 10px",
            }}>최근 검색</div>
            <div style={{
              background: "#fff", borderRadius: 14, overflow: "hidden",
              boxShadow: "inset 0 0 0 0.5px var(--line-1)",
              marginBottom: 24,
            }}>
              {recents.map((r,i) => (
                <div key={r} onClick={() => setQ(r)} style={{
                  display: "flex", alignItems: "center", padding: "11px 14px",
                  borderBottom: i === recents.length-1 ? "none" : "0.5px solid var(--line-1)",
                  cursor: "pointer", gap: 10,
                }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--fg-3)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                    <circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15 14"/>
                  </svg>
                  <span style={{ font: "400 16px/22px var(--font-ui)", color: "var(--fg-1)", flex: 1, letterSpacing: -0.32 }}>{r}</span>
                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="var(--fg-4)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="6" y1="6" x2="18" y2="18"/><line x1="18" y1="6" x2="6" y2="18"/></svg>
                </div>
              ))}
            </div>

            <div style={{
              font: "500 13px/16px var(--font-ui)", color: "var(--fg-3)",
              textTransform: "uppercase", letterSpacing: 0.06,
              padding: "0 4px 10px",
            }}>자주 쓰는 태그</div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 6, padding: "0 2px" }}>
              {popularTags.map(t => <TagChip key={t} label={`#${t}`} onClick={() => setQ(`#${t}`)} />)}
            </div>

            <div style={{
              marginTop: 28,
              padding: "14px 18px",
              borderRadius: 14, background: "var(--ai-tint-soft)",
            }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 6 }}>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="var(--ai-tint)"><path d="M12 0l2.5 7.5L22 10l-7.5 2.5L12 20l-2.5-7.5L2 10l7.5-2.5z"/></svg>
                <span style={{ font: "500 12px/16px var(--font-ui)", color: "var(--ai-tint)", letterSpacing: 0.06, textTransform: "uppercase", whiteSpace: "nowrap" }}>곧 추가됩니다</span>
              </div>
              <div style={{ font: "400 14px/21px var(--font-display)", fontStyle: "italic", color: "var(--ink-900)" }}>
                자연어로 물어보세요. <span style={{ color: "var(--fg-3)" }}>“지난주 면접 어땠지?”</span>
              </div>
            </div>
          </>
        )}

        {q && (
          <>
            <div style={{
              font: "400 13px/16px var(--font-ui)", color: "var(--fg-3)",
              padding: "0 4px 12px",
            }}>{results.length}개의 결과</div>
            <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
              {results.map((n,i) => (
                <div key={i} style={{
                  background: "#fff", borderRadius: 14,
                  padding: "13px 16px", boxShadow: "var(--shadow-card)",
                  display: "flex", flexDirection: "column", gap: 5,
                }}>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", gap: 12 }}>
                    <div style={{
                      font: "600 16px/22px var(--font-ui)", letterSpacing: -0.32,
                      color: "var(--fg-1)", flex: 1, minWidth: 0,
                      whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
                    }}>{highlight(n.title, n.highlight)}</div>
                    <span style={{ font: "400 12px/16px var(--font-ui)", color: "var(--fg-3)", whiteSpace: "nowrap" }}>{n.date}</span>
                  </div>
                  <div style={{
                    font: "400 13px/20px var(--font-ui)", color: "var(--fg-3)",
                    letterSpacing: -0.1,
                    display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical",
                    overflow: "hidden",
                  }}>{highlight(n.preview, n.highlight)}</div>
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 5, marginTop: 3 }}>
                    {n.category && <CategoryDot label={n.category} />}
                    {n.tags.map(t => <TagChip key={t} label={t} subtle />)}
                  </div>
                </div>
              ))}
            </div>
          </>
        )}
      </div>

      <TabBar active={active} onChange={onTabChange} />
    </>
  );
}

Object.assign(window, { SearchScreen });
