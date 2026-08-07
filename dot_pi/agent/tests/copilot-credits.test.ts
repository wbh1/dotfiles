import assert from "node:assert/strict";
import test from "node:test";
import {
  formatPricingLabel,
  parseCopilotPricing,
  shouldRefreshPricing,
} from "../extensions/copilot-credits.ts";

test("parses current GitHub markdown pricing into AI credits per million tokens", () => {
  const pricing = parseCopilotPricing(`
| Model | Tier | Input | Cached input | Cache write | Output |
| --- | --- | ---: | ---: | ---: | ---: |
| GPT-5.3-Codex | Default | $1.75 | $0.175 | Not applicable | $14.00 |
| GPT-5.4 | Long context | $5.00 | $0.50 | Not applicable | $22.50 |
`);

  assert.deepEqual(pricing["gpt-5.3-codex"], [
    { tier: "Default", input: 175, cachedInput: 17.5, cacheWrite: 0, output: 1400 },
  ]);
  assert.deepEqual(pricing["gpt-5.4"], [
    { tier: "Long context", input: 500, cachedInput: 50, cacheWrite: 0, output: 2250 },
  ]);
});

test("ignores non-pricing tables and footnote markers", () => {
  const pricing = parseCopilotPricing(`
### Provider
| Model | Release status | Category | Input | Cached input | Output |
| --- | --- | --- | ---: | ---: | ---: |
| Claude Sonnet 5[^promo] | GA | Versatile | $2.00 | $0.20 | $10.00 |

| Name | Value |
| --- | --- |
| unrelated | $99 |
`);

  assert.deepEqual(pricing["claude-sonnet-5"], [
    { input: 200, cachedInput: 20, cacheWrite: 0, output: 1000 },
  ]);
  assert.equal(pricing.unrelated, undefined);
});

test("refreshes only when the seven-day TTL has elapsed", () => {
  const week = 7 * 24 * 60 * 60 * 1000;
  assert.equal(shouldRefreshPricing(undefined, 10_000), true);
  assert.equal(shouldRefreshPricing(10_000, 10_000 + week - 1), false);
  assert.equal(shouldRefreshPricing(10_000, 10_000 + week), true);
});

test("formats a model's default and long-context credit rates", () => {
  assert.equal(
    formatPricingLabel([
      { tier: "Default", input: 175, cachedInput: 17.5, cacheWrite: 0, output: 1400 },
      { tier: "Long context", input: 500, cachedInput: 50, cacheWrite: 0, output: 2250 },
    ]),
    "175/17.5/1,400 credits/M · long: 500/50/2,250",
  );
});
