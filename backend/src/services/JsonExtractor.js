export class JsonExtractionError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}

export function extractJsonObject(rawOutput) {
  const trimmed = String(rawOutput || "").trim();
  if (!trimmed) {
    throw new JsonExtractionError("invalid_json", "Empty Codex output");
  }

  const withoutFence = stripCodeFence(trimmed);
  const jsonText = firstJsonObject(withoutFence);
  if (!jsonText) {
    throw new JsonExtractionError("invalid_json", "No JSON object found");
  }

  try {
    return JSON.parse(jsonText);
  } catch (error) {
    throw new JsonExtractionError("invalid_json", error.message);
  }
}

export function requireSchema(value, validate) {
  if (!validate(value)) {
    throw new JsonExtractionError("schema_validation_failed", "JSON did not match schema");
  }
  return value;
}

function stripCodeFence(value) {
  const fenceMatch = value.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
  return fenceMatch ? fenceMatch[1].trim() : value;
}

function firstJsonObject(value) {
  const start = value.indexOf("{");
  if (start < 0) return null;

  let depth = 0;
  let inString = false;
  let escaped = false;

  for (let index = start; index < value.length; index += 1) {
    const char = value[index];
    if (escaped) {
      escaped = false;
      continue;
    }
    if (char === "\\") {
      escaped = true;
      continue;
    }
    if (char === "\"") {
      inString = !inString;
      continue;
    }
    if (inString) continue;

    if (char === "{") depth += 1;
    if (char === "}") depth -= 1;
    if (depth === 0) return value.slice(start, index + 1);
  }

  return null;
}
