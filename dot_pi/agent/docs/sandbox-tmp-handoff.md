# Sandbox `/tmp` Write Testing Handoff

## Objective

Verify whether adding the canonical macOS temp-directory path fixes the sandbox denial for arbitrary files under `/tmp`.

## Changes already made

The sandbox runtime dependency was upgraded:

- Package: `@anthropic-ai/sandbox-runtime`
- Previous version: `0.0.26`
- Current version: `0.0.70`
- Files:
  - `/Users/whegedus/.pi/agent/extensions/sandbox/package.json`
  - `/Users/whegedus/.pi/agent/extensions/sandbox/package-lock.json`

The global sandbox config was changed at:

```text
/Users/whegedus/.pi/agent/extensions/sandbox.json
```

Current write paths include:

```json
"allowWrite": [
  ".",
  "/tmp",
  "/private/tmp"
]
```

No other config changes were made.

## Why this was changed

On macOS, `/tmp` is a symlink to `/private/tmp`:

```text
/tmp -> private/tmp
```

Before the config change, these tests showed:

- `/tmp/foo` — denied
- `/private/tmp/foo` — denied
- `/tmp/claude/foo` — allowed

Inspection of sandbox-runtime 0.0.70 showed that it normalizes `/tmp` to `/tmp` but considers the exact resolution `/tmp -> /private/tmp` outside its symlink boundary. Paths below `/tmp`, such as `/tmp/claude`, are handled differently. Adding `/private/tmp` explicitly is intended to make the Seatbelt write rule match the canonical path.

## Important restart requirement

The running Pi process has already initialized its sandbox profile. Restart Pi before testing; editing `sandbox.json` does not update the active profile.

## Tests to run after restarting Pi

Use the Pi `bash` tool or an equivalent command that definitely runs inside the configured sandbox:

```bash
set +e
base="/tmp/pi-sandbox-tmp-test-$$"

for d in "$base" "$base/nested" "/private/tmp/pi-sandbox-canonical-$$"; do
  echo "== $d =="
  mkdir -p "$d"
  echo "mkdir exit=$?"
  printf 'sandbox test\n' > "$d/probe.txt"
  echo "write exit=$?"
  test -f "$d/probe.txt" && echo "file exists"
done

rm -rf "$base" "/private/tmp/pi-sandbox-canonical-$$"
```

Also test the existing dedicated runtime directory:

```bash
mkdir -p /tmp/claude/pi-sandbox-test-$$
printf 'ok\n' > /tmp/claude/pi-sandbox-test-$$/probe.txt
cat /tmp/claude/pi-sandbox-test-$$/probe.txt
rm -rf /tmp/claude/pi-sandbox-test-$$
```

## Expected outcomes

Success means all of these work:

- Creating `/tmp/pi-sandbox-tmp-test-$$`
- Writing `/tmp/pi-sandbox-tmp-test-$$/probe.txt`
- Creating and writing a random directory under `/private/tmp`
- Existing `/tmp/claude` test continues to work

If `/tmp` still fails but `/private/tmp` succeeds, the config change partially confirmed the canonical-path diagnosis. If both fail, inspect the generated Seatbelt profile or check for an additional enclosing sandbox.

## Additional diagnostic information

The shell environment has shown:

```text
SANDBOX_RUNTIME=1
TMPDIR=/tmp/claude
```

A direct nested `SandboxManager.initialize()` test could not complete because the surrounding execution environment denied creation of the runtime Unix socket:

```text
listen EPERM: operation not permitted /tmp/claude/srt-mux-....sock
```

That may indicate an additional environment-level restriction, but it should be distinguished from the Pi extension configuration.

## Files to inspect if testing still fails

- `/Users/whegedus/.pi/agent/extensions/sandbox.json`
- `/Users/whegedus/.pi/agent/extensions/sandbox/index.ts`
- `/Users/whegedus/.pi/agent/extensions/sandbox/node_modules/@anthropic-ai/sandbox-runtime/dist/sandbox/sandbox-utils.js`
- `/Users/whegedus/.pi/agent/extensions/sandbox/node_modules/@anthropic-ai/sandbox-runtime/dist/sandbox/macos-sandbox-utils.js`
- `/Users/whegedus/.pi/agent/extensions/sandbox/node_modules/@anthropic-ai/sandbox-runtime/dist/sandbox/sandbox-manager.js`

## Current status

- Runtime upgraded to 0.0.70: complete
- `/private/tmp` added to config: complete
- Pi restart: pending
- Post-restart filesystem tests: pending
