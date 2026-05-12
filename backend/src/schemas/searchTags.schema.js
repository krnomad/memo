export function validateSearchTagsResponse(value, knownTags = []) {
  const known = new Set(knownTags);
  return Boolean(
    value &&
      Array.isArray(value.queryTags) &&
      value.queryTags.every((tag) => typeof tag === "string") &&
      Array.isArray(value.matchedTags) &&
      value.matchedTags.every((tag) => typeof tag === "string" && known.has(tag)) &&
      Array.isArray(value.categoryHints) &&
      value.categoryHints.every((category) => typeof category === "string") &&
      typeof value.confidence === "number" &&
      value.confidence >= 0 &&
      value.confidence <= 1 &&
      typeof value.provider === "string"
  );
}
