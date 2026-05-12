const CATEGORIES = ["업무", "개인", "아이디어", "문제해결", "학습", "쇼핑", "기타"];
const CATEGORY_KEYWORDS = [
  ["문제해결", ["블루스크린", "오류", "고장", "원인", "해결", "문제"]],
  ["아이디어", ["아이디어", "MVP", "기획", "컨셉", "메모앱"]],
  ["개인", ["부모님", "주말", "가족", "자동차", "공기압"]],
  ["학습", ["공부", "학습", "읽기", "강의"]],
  ["쇼핑", ["구매", "쇼핑", "주문", "가격"]],
  ["업무", ["견적", "회의", "전화", "연락", "Growise", "프로젝트"]]
];
const TAG_CANDIDATES = [
  "철수", "Growise", "견적", "연락", "노트북", "블루스크린", "윈도우",
  "AI", "메모앱", "MVP", "가족", "자동차", "공기압", "고장", "문제해결"
];

export function analyzeMemo({ text, provider = "mock" }) {
  const category = inferCategory(text);
  const tags = unique([
    ...TAG_CANDIDATES.filter((tag) => includesLoose(text, tag)),
    category
  ]).slice(0, 8);

  return {
    title: makeTitle(text),
    category,
    tags: tags.length >= 3 ? tags : unique([...tags, ...fallbackTags(text)]).slice(0, 8),
    entities: {
      people: includesLoose(text, "철수") ? ["철수"] : [],
      projects: includesLoose(text, "Growise") ? ["Growise"] : [],
      dates: includesLoose(text, "내일") ? ["내일"] : []
    },
    importance: /내일|견적|전화|확인|해야/.test(text) ? "medium" : "low",
    isTask: /해야|확인|전화|찾아보기|보기|뵙고/.test(text),
    confidence: 0.78,
    provider
  };
}

export function extractSearchTags({ query, knownTags, provider = "mock" }) {
  const normalizedKnownTags = unique(knownTags.filter((tag) => typeof tag === "string" && tag.trim().length > 0));
  const queryTags = unique([
    ...TAG_CANDIDATES.filter((tag) => includesLoose(query, tag)),
    ...fallbackTags(query)
  ]).slice(0, 8);
  const matchedTags = normalizedKnownTags.filter((tag) =>
    queryTags.some((queryTag) => includesLoose(tag, queryTag) || includesLoose(queryTag, tag) || areRelated(queryTag, tag))
  );

  return {
    queryTags,
    matchedTags,
    categoryHints: CATEGORIES.filter((category) => includesLoose(query, category) || matchedTags.includes(category)),
    confidence: matchedTags.length > 0 ? 0.76 : 0.42,
    provider
  };
}

function inferCategory(text) {
  for (const [category, keywords] of CATEGORY_KEYWORDS) {
    if (keywords.some((keyword) => includesLoose(text, keyword))) return category;
  }
  return "기타";
}

function makeTitle(text) {
  return text.trim().replace(/\s+/g, " ").slice(0, 32);
}

function fallbackTags(text) {
  return text
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .split(/\s+/)
    .filter((word) => word.length >= 2)
    .slice(0, 4);
}

function areRelated(left, right) {
  const groups = [
    ["고장", "블루스크린", "윈도우", "노트북", "문제해결"],
    ["견적", "Growise", "연락", "업무"],
    ["가족", "부모님", "개인"],
    ["AI", "메모앱", "MVP", "아이디어"]
  ];
  return groups.some((group) => group.includes(left) && group.includes(right));
}

function includesLoose(text, keyword) {
  return normalize(text).includes(normalize(keyword));
}

function normalize(value) {
  return String(value).toLowerCase().replace(/\s+/g, "");
}

function unique(values) {
  return [...new Set(values.map((value) => String(value).trim()).filter(Boolean))];
}
