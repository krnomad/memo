import express from "express";
import cors from "cors";
import { fileURLToPath } from "node:url";
import { loadConfig } from "./config.js";
import { createHealthRouter } from "./routes/health.js";
import { createAIRouter } from "./routes/ai.js";

export function createApp(config = loadConfig(), dependencies = {}) {
  const app = express();

  app.use(cors({ origin: true }));
  app.use(express.json({ limit: config.requestBodyLimit }));
  app.use(createHealthRouter(config));
  app.use("/api/ai", createAIRouter(config, dependencies));

  app.use((error, _request, response, next) => {
    if (!error) {
      next();
      return;
    }

    if (error.type === "entity.too.large") {
      response.status(413).json({ ok: false, error: "request_too_large", provider: config.provider });
      return;
    }

    if (error instanceof SyntaxError && "body" in error) {
      response.status(400).json({ ok: false, error: "bad_request", provider: config.provider });
      return;
    }

    response.status(500).json({ ok: false, error: "internal_error", provider: config.provider });
  });

  return app;
}

export function startServer(config = loadConfig()) {
  const app = createApp(config);
  return app.listen(config.port, config.host, () => {
    console.log(`find-later-ai-backend listening on ${config.host}:${config.port}`);
  });
}

const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  startServer();
}
