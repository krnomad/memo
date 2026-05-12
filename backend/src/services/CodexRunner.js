import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));

export class CodexRunner {
  constructor({
    command = "codex",
    timeoutMs = Number.parseInt(process.env.CODEX_TIMEOUT_MS || "20000", 10),
    cwd = resolve(__dirname, "../sandbox")
  } = {}) {
    this.command = command;
    this.timeoutMs = timeoutMs;
    this.cwd = cwd;
  }

  run(prompt) {
    return new Promise((resolvePromise, reject) => {
      const child = spawn(
        this.command,
        ["exec", "--ephemeral", "--sandbox", "read-only", "--ask-for-approval", "never", prompt],
        {
          cwd: this.cwd,
          shell: false,
          stdio: ["ignore", "pipe", "pipe"]
        }
      );

      let stdout = "";
      let stderr = "";
      let didTimeout = false;
      const timer = setTimeout(() => {
        didTimeout = true;
        child.kill("SIGKILL");
      }, this.timeoutMs);

      child.stdout.setEncoding("utf8");
      child.stderr.setEncoding("utf8");
      child.stdout.on("data", (chunk) => {
        stdout += chunk;
      });
      child.stderr.on("data", (chunk) => {
        stderr += chunk;
      });
      child.on("error", (error) => {
        clearTimeout(timer);
        reject(toRunnerError("codex_unavailable", error.message));
      });
      child.on("close", (code) => {
        clearTimeout(timer);
        if (didTimeout) {
          reject(toRunnerError("timeout", "Codex CLI timed out"));
          return;
        }
        if (code !== 0) {
          reject(toRunnerError("codex_unavailable", stderr || `Codex CLI exited with ${code}`));
          return;
        }
        resolvePromise({ stdout, stderr });
      });
    });
  }
}

export function toRunnerError(code, message) {
  const error = new Error(message);
  error.code = code;
  return error;
}
