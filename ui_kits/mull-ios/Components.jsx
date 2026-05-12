// 흘려쓰기 · Find Later — iOS UI kit components
// 토큰은 /colors_and_type.css 의 CSS 변수에서 가져옵니다.

const { useState, useRef, useEffect } = React;

// ─────────────────────────────────────────────────────────────
// 상태 표시줄 (Status Bar) · 44px
// ─────────────────────────────────────────────────────────────
function StatusBar({ tint = "var(--fg-1)" }) {
  return (
    <div style={{
      height: 44, display: "flex", alignItems: "center", justifyContent: "space-between",
      padding: "0 24px", color: tint,
      fontFamily: "var(--font-ui)", fontWeight: 600, fontSize: 17, letterSpacing: -0.4,
      flexShrink: 0,
    }}>
      <span>9:41</span>
      <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
        <svg width="17" height="11" viewBox="0 0 17 11" fill="currentColor"><rect x="0" y="6.5" width="3" height="4" rx="0.5"/><rect x="4.5" y="4.5" width="3" height="6" rx="0.5"/><rect x="9" y="2.5" width="3" height="8" rx="0.5"/><rect x="13.5" y="0.5" width="3" height="10" rx="0.5"/></svg>
        <svg width="16" height="11" viewBox="0 0 17 11" fill="none" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round">
          <path d="M2 4.5C5 1.5 12 1.5 15 4.5"/>
          <path d="M4.5 7C6 5.5 11 5.5 12.5 7"/>
          <path d="M7 9.5c.5-.7 2.5-.7 3 0"/>
        </svg>
        <svg width="27" height="12" viewBox="0 0 27 12" fill="none" stroke="currentColor" strokeWidth="1">
          <rect x="0.5" y="0.5" width="22" height="11" rx="3"/>
          <rect x="2" y="2" width="19" height="8" rx="1.5" fill="currentColor"/>
          <rect x="23.5" y="3.5" width="2" height="5" rx="0.5" fill="currentColor"/>
        </svg>
      </span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 네비게이션 바
// ─────────────────────────────────────────────────────────────
function NavBarLarge({ title, sub, trailing = null }) {
  return (
    <div style={{ padding: "8px 20px 12px", flexShrink: 0 }}>
      {trailing && (
        <div style={{ display: "flex", justifyContent: "flex-end", alignItems: "center", height: 32, gap: 12 }}>
          {trailing}
        </div>
      )}
      <h1 style={{
        margin: "4px 0 0",
        font: "700 32px/38px var(--font-ui)",
        letterSpacing: -0.8,
        color: "var(--fg-1)",
      }}>{title}</h1>
      {sub && (
        <div style={{
          font: "400 15px/20px var(--font-ui)", color: "var(--fg-3)",
          marginTop: 2, letterSpacing: -0.24,
        }}>{sub}</div>
      )}
    </div>
  );
}

function NavBarCompact({ title, leading = null, trailing = null, transparent = false }) {
  return (
    <div style={{
      height: 44, display: "flex", alignItems: "center", padding: "0 12px",
      position: "relative",
      background: transparent ? "transparent" : "rgba(246,242,234,0.82)",
      backdropFilter: transparent ? "none" : "blur(20px)",
      WebkitBackdropFilter: transparent ? "none" : "blur(20px)",
      borderBottom: transparent ? "none" : "0.5px solid var(--line-1)",
      flexShrink: 0,
    }}>
      <div style={{ display: "flex", alignItems: "center", flex: 1 }}>{leading}</div>
      <div style={{
        position: "absolute", left: "50%", top: "50%", transform: "translate(-50%, -50%)",
        font: "600 17px/22px var(--font-ui)", letterSpacing: -0.4, color: "var(--fg-1)",
        maxWidth: "55%", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
      }}>{title}</div>
      <div style={{ display: "flex", alignItems: "center", gap: 12, justifyContent: "flex-end", flex: 1 }}>
        {trailing}
      </div>
    </div>
  );
}

function BackBtn({ label = "뒤로", onClick }) {
  return (
    <button onClick={onClick} style={{
      background: "transparent", border: 0, cursor: "pointer",
      color: "var(--accent)", padding: "8px 4px 8px 0",
      font: "400 17px/22px var(--font-ui)", letterSpacing: -0.4,
      display: "flex", alignItems: "center", gap: 3,
    }}>
      <svg width="12" height="20" viewBox="0 0 12 20" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 2 3 10 9 18"/></svg>
      <span>{label}</span>
    </button>
  );
}

function PlainBtn({ children, onClick, bold = false, color = "var(--accent)" }) {
  return (
    <button onClick={onClick} style={{
      background: "transparent", border: 0, cursor: "pointer",
      color, padding: "4px 6px",
      font: `${bold ? 600 : 400} 17px/22px var(--font-ui)`, letterSpacing: -0.4,
      whiteSpace: "nowrap",
    }}>{children}</button>
  );
}

function IconBtn({ children, onClick, label, color = "var(--fg-1)" }) {
  return (
    <button onClick={onClick} aria-label={label} style={{
      background: "transparent", border: 0, cursor: "pointer",
      color, padding: 4, display: "flex", alignItems: "center", justifyContent: "center",
    }}>{children}</button>
  );
}

// ─────────────────────────────────────────────────────────────
// 탭바
// ─────────────────────────────────────────────────────────────
function TabBar({ active, onChange }) {
  const tabs = [
    { id: "home", label: "최근", icon: (active) => (
      <svg width="26" height="26" viewBox="0 0 24 24" fill={active ? "currentColor" : "none"} stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
        <path d="M5 4h11l4 4v12a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1z"/>
        <path d="M16 4v4h4" fill="none" stroke={active ? "var(--paper-100)" : "currentColor"}/>
      </svg>
    )},
    { id: "browse", label: "탐색", icon: (active) => (
      <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2 : 1.6} strokeLinecap="round" strokeLinejoin="round">
        <rect x="3" y="3" width="7" height="7" rx="1.5"/>
        <rect x="14" y="3" width="7" height="7" rx="1.5"/>
        <rect x="3" y="14" width="7" height="7" rx="1.5"/>
        <rect x="14" y="14" width="7" height="7" rx="1.5"/>
      </svg>
    )},
    { id: "search", label: "검색", icon: (active) => (
      <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2 : 1.6} strokeLinecap="round" strokeLinejoin="round">
        <circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
      </svg>
    )},
  ];
  return (
    <div style={{
      background: "rgba(246,242,234,0.88)",
      backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)",
      borderTop: "0.5px solid var(--line-1)",
      display: "flex", justifyContent: "space-around",
      padding: "8px 0 24px",
      flexShrink: 0,
    }}>
      {tabs.map(t => (
        <button key={t.id} onClick={() => onChange && onChange(t.id)} style={{
          background: "transparent", border: 0, cursor: "pointer",
          display: "flex", flexDirection: "column", alignItems: "center", gap: 3,
          padding: "4px 12px",
          color: active === t.id ? "var(--accent)" : "var(--fg-3)",
          font: "500 10px/13px var(--font-ui)", letterSpacing: 0.06,
          whiteSpace: "nowrap",
        }}>
          {t.icon(active === t.id)}
          <span>{t.label}</span>
        </button>
      ))}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 검색 필드
// ─────────────────────────────────────────────────────────────
function SearchField({ value = "", onChange, onFocus, placeholder = "검색", autoFocus = false }) {
  return (
    <div style={{
      margin: "4px 16px 0",
      background: "var(--paper-200)",
      borderRadius: 10,
      display: "flex", alignItems: "center", gap: 8,
      padding: "8px 10px",
    }}>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--fg-3)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      <input
        value={value}
        onChange={(e) => onChange && onChange(e.target.value)}
        onFocus={onFocus}
        autoFocus={autoFocus}
        placeholder={placeholder}
        style={{
          border: 0, outline: 0, background: "transparent", flex: 1,
          font: "400 17px/22px var(--font-ui)", letterSpacing: -0.4,
          color: "var(--fg-1)",
        }}
      />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 메모 카드 (Note Card)
// 제목 · 미리보기 · 태그 · 카테고리 · 날짜 · AI 상태 표시
// ─────────────────────────────────────────────────────────────
function NoteCard({ note, onClick }) {
  return (
    <div onClick={onClick} style={{
      background: "#fff",
      borderRadius: 14,
      padding: "14px 16px",
      cursor: "pointer",
      boxShadow: "var(--shadow-card)",
      display: "flex", flexDirection: "column", gap: 6,
      position: "relative",
    }}>
      {note.aiPending && <AIDot />}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", gap: 12 }}>
        <div style={{
          font: "600 16px/22px var(--font-ui)", letterSpacing: -0.32,
          color: "var(--fg-1)", flex: 1, minWidth: 0,
          whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
        }}>{note.title}</div>
        <span style={{ font: "400 12px/16px var(--font-ui)", color: "var(--fg-3)", whiteSpace: "nowrap" }}>{note.date}</span>
      </div>
      <div style={{
        font: "400 14px/20px var(--font-ui)", color: "var(--fg-3)",
        letterSpacing: -0.1,
        display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical",
        overflow: "hidden",
      }}>{note.preview}</div>
      {(note.category || (note.tags && note.tags.length > 0)) && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginTop: 4, alignItems: "center" }}>
          {note.category && <CategoryDot label={note.category} />}
          {note.tags && note.tags.map(t => <TagChip key={t} label={t} subtle />)}
        </div>
      )}
    </div>
  );
}

// AI 상태 표시 — 카드 우측 상단의 작은 dot
function AIDot() {
  return (
    <div style={{
      position: "absolute", top: 12, right: 14,
      width: 6, height: 6, borderRadius: "50%",
      background: "var(--ai-tint)",
      boxShadow: "0 0 0 3px var(--ai-tint-soft)",
    }} title="AI 분석 대기 중" />
  );
}

// ─────────────────────────────────────────────────────────────
// Tag / Category UI
// ─────────────────────────────────────────────────────────────
function TagChip({ label, active = false, subtle = false, ai = false, onClick }) {
  let bg, color;
  if (ai) { bg = "var(--ai-tint-soft)"; color = "var(--sage-700)"; }
  else if (active) { bg = "var(--accent-soft)"; color = "var(--terracotta-700)"; }
  else if (subtle) { bg = "var(--paper-200)"; color = "var(--fg-2)"; }
  else { bg = "#fff"; color = "var(--fg-2)"; }
  return (
    <button onClick={onClick} style={{
      background: bg, color, border: 0,
      borderRadius: 999, padding: "3px 9px",
      font: "500 12px/16px var(--font-ui)", letterSpacing: -0.1,
      cursor: onClick ? "pointer" : "default",
      whiteSpace: "nowrap",
      boxShadow: !subtle && !ai && !active ? "inset 0 0 0 0.5px var(--line-1)" : "none",
      display: "inline-flex", alignItems: "center", gap: 4,
    }}>
      {ai && <span style={{ width: 5, height: 5, borderRadius: "50%", background: "var(--ai-tint)" }}/>}
      <span>{label}</span>
    </button>
  );
}

function CategoryDot({ label, color }) {
  const colors = {
    "일/업무": "var(--ios-blue)",
    "아이디어": "var(--accent)",
    "일상": "var(--sage-500)",
    "공부": "var(--ios-indigo)",
    "장보기": "var(--ios-orange)",
    "독서": "var(--terracotta-700)",
  };
  const dot = color || colors[label] || "var(--fg-3)";
  return (
    <span style={{
      display: "inline-flex", alignItems: "center", gap: 5,
      font: "500 12px/16px var(--font-ui)", color: "var(--fg-2)", letterSpacing: -0.1,
      whiteSpace: "nowrap",
    }}>
      <span style={{ width: 7, height: 7, borderRadius: 2, background: dot }}/>
      {label}
    </span>
  );
}

// ─────────────────────────────────────────────────────────────
// FAB — 빠른 메모
// ─────────────────────────────────────────────────────────────
function ComposeFab({ onClick }) {
  return (
    <button onClick={onClick} aria-label="새 메모" style={{
      position: "absolute", right: 18, bottom: 100, zIndex: 10,
      width: 60, height: 60, borderRadius: "50%",
      background: "var(--accent)", color: "#fff",
      border: 0, cursor: "pointer",
      boxShadow: "var(--shadow-floating)",
      display: "flex", alignItems: "center", justifyContent: "center",
      transition: "transform 120ms var(--ease-standard)",
    }}
    onMouseDown={(e) => e.currentTarget.style.transform = "scale(0.96)"}
    onMouseUp={(e) => e.currentTarget.style.transform = "scale(1)"}
    onMouseLeave={(e) => e.currentTarget.style.transform = "scale(1)"}>
      <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 1 1 3 3L7 19l-4 1 1-4z"/>
      </svg>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// 빠른 메모 작성용 키보드 (정적 표현)
// ─────────────────────────────────────────────────────────────
function KoreanKeyboard() {
  const rows = [
    ["ㅂ","ㅈ","ㄷ","ㄱ","ㅅ","ㅛ","ㅕ","ㅑ","ㅐ","ㅔ"],
    ["ㅁ","ㄴ","ㅇ","ㄹ","ㅎ","ㅗ","ㅓ","ㅏ","ㅣ"],
    [],
    [],
  ];
  return (
    <div style={{
      background: "#D4D7DE",
      padding: "6px 3px 8px",
      flexShrink: 0,
    }}>
      {/* row 1 */}
      <div style={{ display: "flex", gap: 5, padding: "0 3px", marginBottom: 11 }}>
        {rows[0].map((k,i) => <Key key={i}>{k}</Key>)}
      </div>
      {/* row 2 */}
      <div style={{ display: "flex", gap: 5, padding: "0 22px", marginBottom: 11 }}>
        {rows[1].map((k,i) => <Key key={i}>{k}</Key>)}
      </div>
      {/* row 3 */}
      <div style={{ display: "flex", gap: 5, padding: "0 3px", marginBottom: 11 }}>
        <Key wide dark>⇧</Key>
        {["ㅋ","ㅌ","ㅊ","ㅍ","ㅠ","ㅜ","ㅡ"].map((k,i) => <Key key={i}>{k}</Key>)}
        <Key wide dark>⌫</Key>
      </div>
      {/* row 4 */}
      <div style={{ display: "flex", gap: 5, padding: "0 3px", marginBottom: 4 }}>
        <Key extra dark>123</Key>
        <Key extra dark>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2a4 4 0 0 0-4 4v6a4 4 0 0 0 8 0V6a4 4 0 0 0-4-4zm-7 10a7 7 0 0 0 14 0h-2a5 5 0 0 1-10 0H5zm6 6.93V21h2v-2.07A8.001 8.001 0 0 0 19 11h-2a6 6 0 0 1-12 0H3a8 8 0 0 0 7 7.93z"/></svg>
        </Key>
        <Key huge>한국어</Key>
        <Key extra return>↵</Key>
      </div>
      {/* home indicator space */}
      <div style={{ height: 8 }} />
    </div>
  );
}
function Key({ children, wide = false, extra = false, huge = false, dark = false, return: isReturn = false }) {
  return (
    <div style={{
      flex: huge ? 4 : extra ? 1.4 : wide ? 1.4 : 1,
      height: 42,
      background: dark ? "#ADB3BD" : "#fff",
      color: isReturn ? "#fff" : "var(--fg-1)",
      borderRadius: 5,
      display: "flex", alignItems: "center", justifyContent: "center",
      font: "400 22px/22px var(--font-ui)",
      boxShadow: "0 1px 0 rgba(0,0,0,0.28)",
      backgroundColor: isReturn ? "var(--accent)" : (dark ? "#ADB3BD" : "#fff"),
    }}>{children}</div>
  );
}

// ─────────────────────────────────────────────────────────────
// Device shell — iPhone
// ─────────────────────────────────────────────────────────────
function Phone({ children, style = {}, scale = 1 }) {
  return (
    <div style={{
      width: 390, height: 844,
      transform: scale === 1 ? undefined : `scale(${scale})`,
      transformOrigin: "top left",
      ...style,
    }}>
      <div style={{
        width: 390, height: 844, borderRadius: 54,
        background: "#1B1A17",
        boxShadow: "0 30px 80px rgba(27,26,23,0.18), 0 0 0 1px rgba(0,0,0,0.04)",
        padding: 11, boxSizing: "border-box",
        fontFamily: "var(--font-ui)",
        WebkitFontSmoothing: "antialiased",
        position: "relative",
      }}>
        <div style={{
          width: "100%", height: "100%", borderRadius: 43, overflow: "hidden",
          background: "var(--bg-app)", position: "relative",
          display: "flex", flexDirection: "column",
        }}>
          {children}
        </div>
        {/* Dynamic Island */}
        <div style={{
          position: "absolute", top: 22, left: "50%", transform: "translateX(-50%)",
          width: 122, height: 36, borderRadius: 999, background: "#0c0b09", zIndex: 100,
        }} />
        {/* Home indicator */}
        <div style={{
          position: "absolute", bottom: 19, left: "50%", transform: "translateX(-50%)",
          width: 134, height: 5, borderRadius: 999, background: "var(--ink-900)", opacity: 0.85, zIndex: 100,
        }} />
      </div>
    </div>
  );
}

// Expose to other Babel scripts
Object.assign(window, {
  StatusBar, NavBarLarge, NavBarCompact, BackBtn, PlainBtn, IconBtn,
  TabBar, SearchField, NoteCard, AIDot, TagChip, CategoryDot,
  ComposeFab, KoreanKeyboard, Phone,
});
