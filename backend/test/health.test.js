import test from "node:test";
import assert from "node:assert/strict";
import { createApp } from "../src/server.js";
import { withTestServer } from "./helpers.js";

test("GET /health returns service metadata", async () => {
  await withTestServer(createApp(), async (baseURL) => {
    const response = await fetch(`${baseURL}/health`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.ok, true);
    assert.equal(body.service, "find-later-ai-backend");
    assert.equal(body.provider, "mock");
    assert.equal(body.version, "0.1.0");
  });
});
