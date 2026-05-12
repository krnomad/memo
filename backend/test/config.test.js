import test from "node:test";
import assert from "node:assert/strict";
import { loadConfig } from "../src/config.js";

test("loadConfig switches backend provider and diagnostics values from env", () => {
  const config = loadConfig({
    HOST: "127.0.0.1",
    PORT: "9999",
    AI_PROVIDER: "codex-cli",
    CODEX_TIMEOUT_MS: "1234",
    REQUEST_BODY_LIMIT: "8kb"
  });

  assert.equal(config.host, "127.0.0.1");
  assert.equal(config.port, 9999);
  assert.equal(config.provider, "codex-cli");
  assert.equal(config.codexTimeoutMs, 1234);
  assert.equal(config.requestBodyLimit, "8kb");
});
