import test from "node:test";
import assert from "node:assert/strict";
import { createApp } from "../src/server.js";
import { withTestServer } from "./helpers.js";

test("POST /api/ai/memo/analyze returns mock memo metadata", async () => {
  await withTestServer(createApp(), async (baseURL) => {
    const response = await fetch(`${baseURL}/api/ai/memo/analyze`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        text: "내일 철수한테 전화하고 Growise 견적 다시 봐야함",
        locale: "ko-KR"
      })
    });
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.category, "업무");
    assert.ok(body.tags.includes("Growise"));
    assert.ok(body.tags.includes("견적"));
    assert.deepEqual(body.entities.people, ["철수"]);
    assert.equal(body.provider, "mock");
  });
});

test("POST /api/ai/search/extract-tags only matches known tags", async () => {
  await withTestServer(createApp(), async (baseURL) => {
    const knownTags = ["노트북", "블루스크린", "윈도우", "문제해결", "Growise", "견적"];
    const response = await fetch(`${baseURL}/api/ai/search/extract-tags`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        query: "지난번 노트북 고장 관련해서 적어둔 거",
        knownTags
      })
    });
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.ok(body.queryTags.includes("노트북"));
    assert.ok(body.matchedTags.includes("노트북"));
    assert.ok(body.matchedTags.includes("블루스크린"));
    assert.ok(body.matchedTags.every((tag) => knownTags.includes(tag)));
  });
});

test("POST endpoints reject invalid request bodies", async () => {
  await withTestServer(createApp(), async (baseURL) => {
    const response = await fetch(`${baseURL}/api/ai/memo/analyze`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ text: "" })
    });
    const body = await response.json();

    assert.equal(response.status, 400);
    assert.equal(body.ok, false);
    assert.equal(body.error, "bad_request");
  });
});
