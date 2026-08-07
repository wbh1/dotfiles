# Copilot credit picker

This extension adds two commands:

- `/copilot-model` — choose a GitHub Copilot model and see AI-credit rates per million tokens for input, cached input, cache write (when applicable), and output.
- `/copilot-credits` — show cache/source status.
- `/copilot-credits refresh` — force an immediate pricing refresh.

The extension intentionally leaves Pi's dollar-denominated `model.cost` metadata unchanged. GitHub's current billing page says **1 AI credit = $0.01 USD** and publishes prices per million tokens; the picker converts those dollar prices into credits by multiplying by 100.

## Weekly refresh behavior

On each `/copilot-model` or `/copilot-credits` invocation:

1. Read `~/.pi/agent/copilot-pricing.json`.
2. Reuse it while it is less than seven days old.
3. Fetch fresh Markdown pricing after seven days.
4. If GitHub is unavailable, use the stale cache and show a warning.
5. If no cache exists and fetching fails, show an error instead of guessing.

The fetched source is GitHub's machine-readable documentation endpoint:

<https://docs.github.com/api/article/body?pathname=/en/copilot/reference/copilot-billing/models-and-pricing>

The human-facing source page is:

<https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing>

## Local overrides

For emergency corrections or organization-specific policy, use:

`~/.pi/agent/copilot-pricing-overrides.json`

Values are already in AI credits per million tokens:

```json
{
  "models": {
    "gpt-5.3-codex": [
      {
        "tier": "Default",
        "input": 175,
        "cachedInput": 17.5,
        "cacheWrite": 0,
        "output": 1400
      }
    ]
  }
}
```

Overrides are optional and take precedence over fetched rates. Unknown models display `credits ?` rather than using stale guesses.
