import test from "node:test";
import assert from "node:assert/strict";
import { extractJsonObject, JsonExtractionError, requireSchema } from "../src/services/JsonExtractor.js";

test("extractJsonObject parses fenced JSON", () => {
  const result = extractJsonObject("```json\n{\"title\":\"메모\"}\n```");
  assert.deepEqual(result, { title: "메모" });
});

test("extractJsonObject parses first JSON object from mixed output", () => {
  const result = extractJsonObject("설명\n{\"ok\":true,\"nested\":{\"count\":1}}\nextra");
  assert.deepEqual(result, { ok: true, nested: { count: 1 } });
});

test("extractJsonObject rejects invalid output", () => {
  assert.throws(() => extractJsonObject("no json here"), JsonExtractionError);
});

test("requireSchema rejects mismatched JSON", () => {
  assert.throws(() => requireSchema({ ok: false }, (value) => value.ok === true), {
    code: "schema_validation_failed"
  });
});
