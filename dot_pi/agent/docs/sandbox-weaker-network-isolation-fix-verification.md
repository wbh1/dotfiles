# Verifying the `enableWeakerNetworkIsolation` Fix

## Background

`~/.pi/agent/extensions/sandbox.json` sets `"enableWeakerNetworkIsolation": true`,
but `extensions/sandbox/index.ts` was silently dropping that field instead of
passing it to `SandboxManager.initialize()`. It only recognized the
similarly-named `enableWeakerNestedSandbox` field.

`enableWeakerNetworkIsolation` grants the sandbox mach-lookup access to
`com.apple.trustd.agent`, which Go's TLS stack needs for certificate
verification. Without it, `gh` CLI commands fail with:

```
tls: failed to verify certificate: x509: OSStatus -26276
```

for *every* host (confirmed against both `bits.linode.com` and
`api.github.com`/`github.com`), even though `curl` verifies the same
certificates fine through the sandbox proxy.

## Fix applied

- `extensions/sandbox/config.ts` (new file): pure config-loading/merge logic,
  now correctly merges `enableWeakerNetworkIsolation` from `sandbox.json`.
- `extensions/sandbox/index.ts`: passes `config.enableWeakerNetworkIsolation`
  into `SandboxManager.initialize(...)`; `/sandbox` command now prints
  `Weaker Network Isolation: enabled/disabled`.
- `tests/sandbox-config.test.ts` (new): unit test asserting the field survives
  `loadConfig`.

**Requires a Pi restart to take effect** — the sandbox profile is built once
at `session_start`; editing config or extension code mid-session does not
change the active profile (see `docs/sandbox-tmp-handoff.md`).

## How to verify after restart

Run these from a **fresh Pi session** in this directory (`~/.pi/agent`), using
the `bash` tool so commands run inside the sandbox.

### 1. Confirm the extension picked up the setting

```
/sandbox
```

Expect a line reading:

```
Weaker Network Isolation: enabled
```

If it says `disabled`, the fix did not take effect — check that
`extensions/sandbox.json` still has `"enableWeakerNetworkIsolation": true`
and that Pi was actually restarted (not just the session resumed).

### 2. Confirm the `gh` TLS failure is gone

```bash
gh api /user 2>&1
```

- **Before the fix:** `Get "https://api.github.com/user": tls: failed to verify certificate: x509: OSStatus -26276`
- **After the fix:** should return either a valid JSON user object, or a
  clean auth error (e.g. `HTTP 401`), but **not** a TLS verification error.

Also test the GitHub Enterprise host specifically:

```bash
GH_HOST=bits.linode.com gh api /user 2>&1
```

Same expectation: no `x509: OSStatus -26276`. It's fine if this returns a 401
or other auth-related error — the token itself may still need
`gh auth refresh -h bits.linode.com`. The goal here is only to confirm the
TLS verification layer succeeds.

### 3. Regression-check the underlying test suite

```bash
cd ~/.pi/agent
node --experimental-strip-types --test tests/*.test.ts
```

Expect all tests passing, including
`loadConfig passes through enableWeakerNetworkIsolation from global config`.

## If it still fails

- Double check `/sandbox` output first — if `enableWeakerNetworkIsolation`
  shows `disabled`, the bug is still in config loading/wiring, not TLS.
- If `/sandbox` shows `enabled` but `gh` still gets `OSStatus -26276`, the
  root cause hypothesis about `trustd.agent` mach-lookup was wrong or
  incomplete — go back to Phase 1 investigation rather than patching further.
- Confirm which `sandbox.json` is actually being read: global
  (`~/.pi/agent/extensions/sandbox.json`) vs. any project-local
  `.pi/sandbox.json` in the test cwd, since project config takes precedence.
