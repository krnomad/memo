import { Router } from "express";

export function createHealthRouter(config) {
  const router = Router();

  router.get("/health", (_request, response) => {
    response.json({
      ok: true,
      service: "find-later-ai-backend",
      provider: config.provider,
      version: config.version
    });
  });

  return router;
}
