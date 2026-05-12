// 빠른 메모 작성 화면 — 앱의 가장 중요한 화면
// 1~2탭 안에 도달 · 큰 입력 영역 · 하단 메타 영역 · 한국어 키보드
function ComposeScreen({ onClose }) {
  const [text, setText] = useState("");
  const [tags, setTags] = useState([]);
  const [tagDraft, setTagDraft] = useState("");
  const [category, setCategory] = useState(null);
  const [showCatPicker, setShowCatPicker] = useState(false);

  const charCount = text.length;
  const placeholder = "생각나는 걸 아무거나 적어보세요";

  const cats = [
    { name: "아이디어", color: "var(--accent)" },
    { name: "일/업무",  color: "var(--ios-blue)" },
    { name: "일상",      color: "var(--sage-500)" },
    { name: "공부",      color: "var(--ios-indigo)" },
    { name: "장보기",    color: "var(--ios-orange)" },
    { name: "독서",      color: "var(--terracotta-700)" },
  ];

  // AI 태그 추천 (MVP — 동작 안 함, UI만)
  const aiSuggestions = ["메타", "생각"];

  const addTag = (t) => {
    if (t && !tags.includes(t)) setTags([...tags, t]);
    setTagDraft("");
  };

  return (
    <>
      <StatusBar />
      <NavBarCompact
        transparent
        leading={<PlainBtn onClick={onClose}>취소</PlainBtn>}
        trailing={
          <PlainBtn bold onClick={onClose} color={text ? "var(--accent)" : "var(--fg-4)"}>
            저장
          </PlainBtn>
        }
      />

      {/* 메모 입력 영역 — 크고 비어 있고 부담 없는 */}
      <div style={{ flex: 1, padding: "8px 22px 0", display: "flex", flexDirection: "column", minHeight: 0 }}>
        <textarea
          autoFocus
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder={placeholder}
          style={{
            flex: 1,
            border: 0, outline: 0, resize: "none", background: "transparent",
            font: "400 19px/30px var(--font-ui)",
            letterSpacing: -0.3, color: "var(--fg-1)",
            caretColor: "var(--accent)",
            paddingTop: 8,
          }}
        />

        {/* 글자 수 — 굳이 잘 보이지 않아야 함 */}
        <div style={{
          font: "400 11px/14px var(--font-mono)", color: "var(--fg-4)",
          textAlign: "right", padding: "4px 0 8px",
        }}>{charCount}자</div>

        {/* 메타 영역 — 카테고리, 태그 */}
        <div style={{
          borderTop: "0.5px solid var(--line-1)",
          padding: "10px 0 12px",
          display: "flex", flexDirection: "column", gap: 8,
        }}>
          {/* 카테고리 행 */}
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <span style={{ font: "400 13px/18px var(--font-ui)", color: "var(--fg-3)", width: 48 }}>카테고리</span>
            <button onClick={() => setShowCatPicker(!showCatPicker)} style={{
              border: 0, background: "transparent", cursor: "pointer", padding: 0,
              display: "flex", alignItems: "center", gap: 4,
            }}>
              {category ? <CategoryDot label={category} /> :
                <span style={{ font: "400 13px/18px var(--font-ui)", color: "var(--fg-4)" }}>선택 안 함</span>}
              <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="var(--fg-3)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
            </button>
          </div>

          {showCatPicker && (
            <div style={{ display: "flex", flexWrap: "wrap", gap: 6, paddingLeft: 56 }}>
              {cats.map(c => (
                <button key={c.name} onClick={() => { setCategory(c.name); setShowCatPicker(false); }} style={{
                  border: 0, cursor: "pointer", background: "var(--paper-200)",
                  borderRadius: 999, padding: "4px 10px",
                  font: "500 12px/16px var(--font-ui)", color: "var(--fg-2)",
                  display: "inline-flex", alignItems: "center", gap: 5,
                }}>
                  <span style={{ width: 7, height: 7, borderRadius: 2, background: c.color }}/>
                  {c.name}
                </button>
              ))}
            </div>
          )}

          {/* 태그 행 */}
          <div style={{ display: "flex", alignItems: "center", gap: 6, flexWrap: "wrap" }}>
            <span style={{ font: "400 13px/18px var(--font-ui)", color: "var(--fg-3)", width: 48 }}>태그</span>
            {tags.map(t => (
              <TagChip key={t} label={t} active onClick={() => setTags(tags.filter(x => x !== t))} />
            ))}
            <input
              value={tagDraft}
              onChange={(e) => setTagDraft(e.target.value)}
              onKeyDown={(e) => { if (e.key === "Enter" || e.key === " " || e.key === ",") { e.preventDefault(); addTag(tagDraft.trim()); } }}
              placeholder={tags.length ? "" : "추가"}
              style={{
                border: 0, outline: 0, background: "transparent",
                font: "500 12px/16px var(--font-ui)", color: "var(--fg-2)",
                padding: "3px 0", flex: 1, minWidth: 60,
              }}
            />
          </div>

          {/* AI 태그 추천 — 미래 기능, 비활성 안내 */}
          {tagDraft === "" && tags.length === 0 && (
            <div style={{ display: "flex", alignItems: "center", gap: 6, paddingLeft: 56, marginTop: -2 }}>
              <svg width="11" height="11" viewBox="0 0 24 24" fill="var(--ai-tint)"><path d="M12 0l2.5 7.5L22 10l-7.5 2.5L12 20l-2.5-7.5L2 10l7.5-2.5z"/></svg>
              <span style={{ font: "400 12px/16px var(--font-ui)", color: "var(--ai-tint)" }}>곧 AI가 태그를 추천해줍니다</span>
            </div>
          )}
        </div>
      </div>

      <KoreanKeyboard />
    </>
  );
}

Object.assign(window, { ComposeScreen });
