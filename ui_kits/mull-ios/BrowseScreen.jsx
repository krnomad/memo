// 탐색 화면 — 카테고리 + 태그
function BrowseScreen({ onTabChange, active = "browse", onCompose }) {
  const [filter, setFilter] = useState(null); // "tag:집" or "cat:일상"

  const categories = [
    { name: "아이디어", count: 18, color: "var(--accent)" },
    { name: "일/업무",  count: 42, color: "var(--ios-blue)" },
    { name: "일상",     count: 31, color: "var(--sage-500)" },
    { name: "공부",     count: 12, color: "var(--ios-indigo)" },
    { name: "장보기",   count: 8,  color: "var(--ios-orange)" },
    { name: "독서",     count: 24, color: "var(--terracotta-700)" },
    { name: "미분류",   count: 11, color: "var(--fg-3)" },
  ];

  // 태그 — 사용 빈도에 따라 크기 다르게
  const tags = [
    { name: "집",     count: 14, size: "lg" },
    { name: "예산",   count: 9,  size: "md" },
    { name: "메타",   count: 22, size: "xl" },
    { name: "생각",   count: 28, size: "xl" },
    { name: "주말",   count: 6,  size: "sm" },
    { name: "취업",   count: 11, size: "md" },
    { name: "준비",   count: 7,  size: "sm" },
    { name: "인용",   count: 18, size: "lg" },
    { name: "공항",   count: 2,  size: "sm" },
    { name: "회의",   count: 9,  size: "md" },
    { name: "면접",   count: 4,  size: "sm" },
    { name: "리노",   count: 3,  size: "sm" },
    { name: "쇼핑",   count: 5,  size: "sm" },
    { name: "운동",   count: 12, size: "md" },
    { name: "여행",   count: 16, size: "lg" },
  ];

  const sizeMap = {
    sm: { font: "400 13px/18px var(--font-ui)", padding: "5px 10px" },
    md: { font: "500 14px/20px var(--font-ui)", padding: "6px 12px" },
    lg: { font: "500 16px/22px var(--font-ui)", padding: "7px 14px" },
    xl: { font: "600 18px/24px var(--font-ui)", padding: "8px 16px" },
  };

  return (
    <>
      <StatusBar />
      <NavBarLarge title="탐색" sub="카테고리 · 태그" />

      <div style={{ flex: 1, overflow: "auto", padding: "8px 16px 120px" }}>
        {/* 카테고리 */}
        <div style={{
          font: "500 13px/16px var(--font-ui)", color: "var(--fg-3)",
          textTransform: "uppercase", letterSpacing: 0.06,
          padding: "8px 4px 10px",
        }}>카테고리</div>
        <div style={{
          background: "#fff", borderRadius: 14,
          boxShadow: "inset 0 0 0 0.5px var(--line-1)",
          overflow: "hidden",
          marginBottom: 24,
        }}>
          {categories.map((c,i) => (
            <div key={c.name} onClick={() => setFilter(`cat:${c.name}`)} style={{
              display: "flex", alignItems: "center", padding: "13px 16px",
              borderBottom: i === categories.length-1 ? "none" : "0.5px solid var(--line-1)",
              cursor: "pointer", gap: 12,
            }}>
              <span style={{ width: 10, height: 10, borderRadius: 3, background: c.color, flexShrink: 0 }}/>
              <span style={{ font: "400 16px/22px var(--font-ui)", color: "var(--fg-1)", flex: 1, letterSpacing: -0.32 }}>{c.name}</span>
              <span style={{ font: "400 15px/20px var(--font-ui)", color: "var(--fg-3)", marginRight: 6 }}>{c.count}</span>
              <svg width="7" height="12" viewBox="0 0 8 14" fill="none" stroke="var(--fg-4)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="1 1 7 7 1 13"/></svg>
            </div>
          ))}
        </div>

        {/* 태그 — 태그 클라우드 */}
        <div style={{
          font: "500 13px/16px var(--font-ui)", color: "var(--fg-3)",
          textTransform: "uppercase", letterSpacing: 0.06,
          padding: "0 4px 10px", display: "flex", justifyContent: "space-between", alignItems: "center",
        }}>
          <span style={{ whiteSpace: "nowrap" }}>태그</span>
          <span style={{ textTransform: "none", color: "var(--accent)", letterSpacing: 0, fontSize: 13, whiteSpace: "nowrap" }}>전체</span>
        </div>
        <div style={{
          background: "#fff", borderRadius: 14,
          boxShadow: "inset 0 0 0 0.5px var(--line-1)",
          padding: "14px 14px",
          display: "flex", flexWrap: "wrap", gap: 6,
        }}>
          {tags.map(t => (
            <button key={t.name} onClick={() => setFilter(`tag:${t.name}`)} style={{
              border: 0, background: filter === `tag:${t.name}` ? "var(--accent-soft)" : "var(--paper-100)",
              color: filter === `tag:${t.name}` ? "var(--terracotta-700)" : "var(--fg-2)",
              borderRadius: 999, ...sizeMap[t.size],
              cursor: "pointer", letterSpacing: -0.1,
              display: "inline-flex", alignItems: "center", gap: 4,
              whiteSpace: "nowrap",
            }}>
              <span>#{t.name}</span>
              <span style={{ opacity: 0.5, fontWeight: 400, fontSize: 11 }}>{t.count}</span>
            </button>
          ))}
        </div>

        {/* AI 영역 — 미래 기능 안내 */}
        <div style={{
          marginTop: 24,
          background: "var(--ai-tint-soft)", borderRadius: 14,
          padding: "16px 18px",
        }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 8 }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="var(--ai-tint)"><path d="M12 0l2.5 7.5L22 10l-7.5 2.5L12 20l-2.5-7.5L2 10l7.5-2.5z"/></svg>
            <span style={{ font: "500 12px/16px var(--font-ui)", color: "var(--ai-tint)", letterSpacing: 0.06, textTransform: "uppercase", whiteSpace: "nowrap" }}>곧 추가됩니다</span>
          </div>
          <div style={{ font: "400 15px/22px var(--font-display)", fontStyle: "italic", color: "var(--ink-900)" }}>
            비슷한 메모끼리 자동으로 묶고, 카테고리를 추천해드릴 거예요.
          </div>
        </div>
      </div>

      <ComposeFab onClick={onCompose} />
      <TabBar active={active} onChange={onTabChange} />
    </>
  );
}

Object.assign(window, { BrowseScreen });
