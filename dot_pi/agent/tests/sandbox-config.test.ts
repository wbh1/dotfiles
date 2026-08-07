import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { loadConfig } from "../extensions/sandbox/config.ts";

test("loadConfig passes through enableWeakerNetworkIsolation from global config", () => {
  const agentDir = mkdtempSync(join(tmpdir(), "pi-agent-dir-"));
  const cwd = mkdtempSync(join(tmpdir(), "pi-cwd-"));

  try {
    const extensionsDir = join(agentDir, "extensions");
    mkdirSync(extensionsDir, { recursive: true });
    writeFileSync(
      join(extensionsDir, "sandbox.json"),
      JSON.stringify({ enableWeakerNetworkIsolation: true }),
    );

    const config = loadConfig(cwd, agentDir, ".pi");

    assert.equal(config.enableWeakerNetworkIsolation, true);
  } finally {
    rmSync(agentDir, { recursive: true, force: true });
    rmSync(cwd, { recursive: true, force: true });
  }
});
