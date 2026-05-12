import { CodexRunner } from "./CodexRunner.js";
import { buildMemoAnalysisPrompt, buildMemoRepairPrompt } from "./MemoPromptBuilder.js";
import { buildSearchRepairPrompt, buildSearchTagsPrompt } from "./SearchPromptBuilder.js";
import { extractJsonObject, requireSchema } from "./JsonExtractor.js";
import { validateMemoAnalysisResponse } from "../schemas/memoAnalysis.schema.js";
import { validateSearchTagsResponse } from "../schemas/searchTags.schema.js";

export class CodexAIProvider {
  constructor({ runner = new CodexRunner(), provider = "codex-cli" } = {}) {
    this.runner = runner;
    this.provider = provider;
  }

  async analyzeMemo({ text }) {
    return this.runWithJsonRetry({
      prompt: buildMemoAnalysisPrompt(text),
      repairPrompt: buildMemoRepairPrompt,
      decorate: (value) => ({ ...value, provider: this.provider }),
      validate: validateMemoAnalysisResponse
    });
  }

  async extractSearchTags({ query, knownTags }) {
    return this.runWithJsonRetry({
      prompt: buildSearchTagsPrompt(query, knownTags),
      repairPrompt: (rawOutput) => buildSearchRepairPrompt(rawOutput, knownTags),
      decorate: (value) => ({
        ...value,
        matchedTags: Array.isArray(value.matchedTags)
          ? value.matchedTags.filter((tag) => knownTags.includes(tag))
          : value.matchedTags,
        provider: this.provider
      }),
      validate: (value) => validateSearchTagsResponse(value, knownTags)
    });
  }

  async runWithJsonRetry({ prompt, repairPrompt, decorate, validate }) {
    try {
      return await this.runOnce({ prompt, decorate, validate });
    } catch (error) {
      if (error.code !== "invalid_json") throw error;
      const repaired = await this.runner.run(repairPrompt(error.rawOutput || ""));
      const value = decorate(extractJsonObject(repaired.stdout));
      return requireSchema(value, validate);
    }
  }

  async runOnce({ prompt, decorate, validate }) {
    const output = await this.runner.run(prompt);
    try {
      const value = decorate(extractJsonObject(output.stdout));
      return requireSchema(value, validate);
    } catch (error) {
      error.rawOutput = output.stdout;
      throw error;
    }
  }
}
