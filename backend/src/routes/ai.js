import { Router } from "express";
import { analyzeMemo, extractSearchTags } from "../services/MockAIProvider.js";
import { CodexAIProvider } from "../services/CodexAIProvider.js";
import { CodexRunner } from "../services/CodexRunner.js";
import { validateMemoAnalysisResponse } from "../schemas/memoAnalysis.schema.js";
import { validateSearchTagsResponse } from "../schemas/searchTags.schema.js";

export function createAIRouter(config, dependencies = {}) {
  const router = Router();
  const codexProvider =
    dependencies.codexProvider ||
    new CodexAIProvider({
      provider: "codex-cli",
      runner: new CodexRunner({ timeoutMs: config.codexTimeoutMs })
    });

  router.post("/memo/analyze", async (request, response) => {
    const text = request.body?.text;
    if (typeof text !== "string" || text.trim().length === 0) {
      response.status(400).json({ ok: false, error: "bad_request", provider: config.provider });
      return;
    }

    try {
      const result =
        config.provider === "codex-cli"
          ? await codexProvider.analyzeMemo({ text, locale: request.body?.locale || "ko-KR" })
          : analyzeMemo({
              text,
              locale: request.body?.locale || "ko-KR",
              provider: config.provider
            });

      if (!validateMemoAnalysisResponse(result)) {
        response.status(500).json({ ok: false, error: "schema_validation_failed", provider: config.provider });
        return;
      }

      response.json(result);
    } catch (error) {
      sendAIError(response, error, config.provider);
    }
  });

  router.post("/search/extract-tags", async (request, response) => {
    const query = request.body?.query;
    const knownTags = request.body?.knownTags;

    if (typeof query !== "string" || !Array.isArray(knownTags)) {
      response.status(400).json({ ok: false, error: "bad_request", provider: config.provider });
      return;
    }

    try {
      const result =
        config.provider === "codex-cli"
          ? await codexProvider.extractSearchTags({ query, knownTags })
          : extractSearchTags({ query, knownTags, provider: config.provider });

      if (!validateSearchTagsResponse(result, knownTags)) {
        response.status(500).json({ ok: false, error: "schema_validation_failed", provider: config.provider });
        return;
      }

      response.json(result);
    } catch (error) {
      sendAIError(response, error, config.provider);
    }
  });

  return router;
}

function sendAIError(response, error, provider) {
  const code = error.code || "codex_unavailable";
  const status = code === "timeout" ? 504 : code === "schema_validation_failed" || code === "invalid_json" ? 502 : 503;
  response.status(status).json({ ok: false, error: code, provider });
}
