const CATEGORIES = new Set(["업무", "개인", "아이디어", "문제해결", "학습", "쇼핑", "기타"]);
const IMPORTANCE = new Set(["low", "medium", "high"]);

export function validateMemoAnalysisResponse(value) {
  return Boolean(
    value &&
      typeof value.title === "string" &&
      CATEGORIES.has(value.category) &&
      Array.isArray(value.tags) &&
      value.tags.every((tag) => typeof tag === "string") &&
      value.entities &&
      Array.isArray(value.entities.people) &&
      Array.isArray(value.entities.projects) &&
      Array.isArray(value.entities.dates) &&
      IMPORTANCE.has(value.importance) &&
      typeof value.isTask === "boolean" &&
      typeof value.confidence === "number" &&
      value.confidence >= 0 &&
      value.confidence <= 1 &&
      typeof value.provider === "string"
  );
}
