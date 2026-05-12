export function loadConfig(env = process.env) {
  return {
    host: env.HOST || "0.0.0.0",
    port: Number.parseInt(env.PORT || "8989", 10),
    provider: env.AI_PROVIDER || "mock",
    codexTimeoutMs: Number.parseInt(env.CODEX_TIMEOUT_MS || "20000", 10),
    requestBodyLimit: env.REQUEST_BODY_LIMIT || "16kb",
    version: "0.1.0"
  };
}
