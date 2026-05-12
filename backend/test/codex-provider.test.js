import test from "node:test";
import assert from "node:assert/strict";
import { CodexAIProvider } from "../src/services/CodexAIProvider.js";
import { createApp } from "../src/server.js";
import { withTestServer } from "./helpers.js";

test("CodexAIProvider retries once after invalid JSON", async () => {
  const runner = new FakeRunner([
    { stdout: "메모 분석 결과입니다." },
    {
      stdout: JSON.stringify({
        title: "Growise 견적 확인",
        category: "업무",
        tags: ["철수", "Growise", "견적"],
        entities: { people: ["철수"], projects: ["Growise"], dates: ["내일"] },
        importance: "medium",
        isTask: true,
        confidence: 0.82
      })
    }
  ]);
  const provider = new CodexAIProvider({ runner });

  const result = await provider.analyzeMemo({ text: "내일 철수한테 전화하고 Growise 견적 다시 봐야함" });

  assert.equal(runner.prompts.length, 2);
  assert.equal(result.provider, "codex-cli");
  assert.equal(result.category, "업무");
});

test("CodexAIProvider filters unknown matchedTags", async () => {
  const runner = new FakeRunner([
    {
      stdout: JSON.stringify({
        queryTags: ["노트북", "고장"],
        matchedTags: ["노트북", "없는태그"],
        categoryHints: ["문제해결"],
        confidence: 0.7
      })
    }
  ]);
  const provider = new CodexAIProvider({ runner });

  const result = await provider.extractSearchTags({
    query: "노트북 고장",
    knownTags: ["노트북", "블루스크린"]
  });

  assert.deepEqual(result.matchedTags, ["노트북"]);
});

test("codex-cli route converts timeout into error response", async () => {
  const timeoutError = new Error("timeout");
  timeoutError.code = "timeout";
  const codexProvider = {
    analyzeMemo: async () => {
      throw timeoutError;
    }
  };

  await withTestServer(createApp({ provider: "codex-cli", requestBodyLimit: "16kb", version: "0.1.0" }, { codexProvider }), async (baseURL) => {
    const response = await fetch(`${baseURL}/api/ai/memo/analyze`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ text: "메모" })
    });
    const body = await response.json();

    assert.equal(response.status, 504);
    assert.equal(body.ok, false);
    assert.equal(body.error, "timeout");
    assert.equal(body.provider, "codex-cli");
  });
});

class FakeRunner {
  constructor(outputs) {
    this.outputs = outputs;
    this.prompts = [];
  }

  async run(prompt) {
    this.prompts.push(prompt);
    const output = this.outputs.shift();
    if (!output) throw new Error("No fake output left");
    return output;
  }
}
