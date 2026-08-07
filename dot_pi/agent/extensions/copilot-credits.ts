import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export const PRICING_URL =
  "https://docs.github.com/api/article/body?pathname=/en/copilot/reference/copilot-billing/models-and-pricing";
export const PRICING_PAGE_URL =
  "https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing";
export const CACHE_PATH = join(homedir(), ".pi", "agent", "copilot-pricing.json");
export const OVERRIDES_PATH = join(
  homedir(),
  ".pi",
  "agent",
  "copilot-pricing-overrides.json",
);
export const PRICING_TTL_MS = 7 * 24 * 60 * 60 * 1000;

export type PricingRate = {
  tier?: string;
  threshold?: string;
  input: number;
  cachedInput: number;
  cacheWrite: number;
  output: number;
};

export type CopilotPricing = Record<string, PricingRate[]>;

type PricingCache = {
  fetchedAt: number;
  source: string;
  rates: CopilotPricing;
};

type CreditOverrides = Record<string, PricingRate[]>;

type PickerModel = {
  id: string;
  name?: string;
  provider: string;
  contextWindow?: number;
  reasoning?: boolean;
};

function cells(line: string): string[] {
  return line
    .trim()
    .replace(/^\|/, "")
    .replace(/\|$/, "")
    .split("|")
    .map((cell) => cell.trim());
}

function normalizeModelName(value: string): string {
  return value
    .replace(/\[\^[^\]]+\]/g, "")
    .replace(/\s*\([^)]*\)/g, "")
    .replace(/\s+/g, " ")
    .trim()
    .toLowerCase()
    .replace(/\s+/g, "-");
}

function parseDollar(value: string | undefined): number | undefined {
  if (!value || /not applicable/i.test(value)) return undefined;
  const match = value.replace(/,/g, "").match(/\$\s*([0-9]+(?:\.[0-9]+)?)/);
  return match ? Number(match[1]) * 100 : undefined;
}

function isSeparatorRow(row: string[]): boolean {
  return row.length > 0 && row.every((cell) => /^:?-{2,}:?$/.test(cell));
}

/** Parse GitHub's markdown pricing tables into AI credits per million tokens. */
export function parseCopilotPricing(markdown: string): CopilotPricing {
  const lines = markdown.split(/\r?\n/);
  const pricing: CopilotPricing = {};

  for (let index = 0; index < lines.length; index += 1) {
    if (!lines[index].trim().startsWith("|")) continue;
    const header = cells(lines[index]).map((cell) => cell.toLowerCase());
    const modelIndex = header.indexOf("model");
    const inputIndex = header.indexOf("input");
    const outputIndex = header.indexOf("output");
    if (modelIndex < 0 || inputIndex < 0 || outputIndex < 0) continue;

    const cachedIndex = header.findIndex((cell) => cell === "cached input");
    const cacheWriteIndex = header.findIndex((cell) => cell === "cache write");
    const tierIndex = header.indexOf("tier");
    const thresholdIndex = header.indexOf("threshold (input tokens)");

    index += 1;
    for (; index < lines.length && lines[index].trim().startsWith("|"); index += 1) {
      const row = cells(lines[index]);
      if (isSeparatorRow(row)) continue;

      const model = normalizeModelName(row[modelIndex] ?? "");
      const input = parseDollar(row[inputIndex]);
      const output = parseDollar(row[outputIndex]);
      if (!model || input === undefined || output === undefined) continue;

      const rate: PricingRate = {
        ...(tierIndex >= 0 && row[tierIndex] ? { tier: row[tierIndex] } : {}),
        ...(thresholdIndex >= 0 && row[thresholdIndex]
          ? { threshold: row[thresholdIndex] }
          : {}),
        input,
        cachedInput: parseDollar(row[cachedIndex]) ?? 0,
        cacheWrite: parseDollar(row[cacheWriteIndex]) ?? 0,
        output,
      };
      (pricing[model] ??= []).push(rate);
    }
    index -= 1;
  }

  return pricing;
}

export function shouldRefreshPricing(
  fetchedAt: number | undefined,
  now = Date.now(),
): boolean {
  return fetchedAt === undefined || now - fetchedAt >= PRICING_TTL_MS;
}

function formatNumber(value: number): string {
  return value.toLocaleString("en-US", { maximumFractionDigits: 3 });
}

export function formatPricingLabel(rates: PricingRate[] | undefined): string {
  if (!rates || rates.length === 0) return "credits ?";

  const labels = rates.map((rate, index) => {
    const tier = rate.tier?.toLowerCase().replace(/\s+context$/, "") ?? "tier";
    const prefix = index === 0 ? "" : `${tier}: `;
    const cacheWrite = rate.cacheWrite > 0 ? `/${formatNumber(rate.cacheWrite)}` : "";
    return `${prefix}${formatNumber(rate.input)}/${formatNumber(rate.cachedInput)}${cacheWrite}/${formatNumber(rate.output)}`;
  });
  return `${labels[0]} credits/M${labels.length > 1 ? ` · ${labels.slice(1).join(" · ")}` : ""}`;
}

function readJson<T>(path: string): T | undefined {
  if (!existsSync(path)) return undefined;
  try {
    return JSON.parse(readFileSync(path, "utf8")) as T;
  } catch (error) {
    console.error(`Failed to read ${path}:`, error);
    return undefined;
  }
}

function readCache(): PricingCache | undefined {
  const cache = readJson<PricingCache>(CACHE_PATH);
  if (!cache || typeof cache.fetchedAt !== "number" || !cache.rates) return undefined;
  return cache;
}

function readOverrides(): CreditOverrides {
  const parsed = readJson<{ models?: CreditOverrides }>(OVERRIDES_PATH);
  return parsed?.models ?? {};
}

async function fetchPricing(): Promise<PricingCache> {
  const response = await fetch(PRICING_URL, {
    headers: { Accept: "text/markdown, text/plain;q=0.9" },
  });
  if (!response.ok) {
    throw new Error(`GitHub pricing request failed with HTTP ${response.status}`);
  }

  const rates = parseCopilotPricing(await response.text());
  if (Object.keys(rates).length === 0) {
    throw new Error("GitHub pricing document contained no recognizable pricing tables");
  }

  const cache: PricingCache = {
    fetchedAt: Date.now(),
    source: PRICING_PAGE_URL,
    rates,
  };
  writeFileSync(CACHE_PATH, `${JSON.stringify(cache, null, 2)}\n`, "utf8");
  return cache;
}

async function getPricing(forceRefresh = false): Promise<{
  cache: PricingCache;
  stale: boolean;
}> {
  const cached = readCache();
  if (!forceRefresh && cached && !shouldRefreshPricing(cached.fetchedAt)) {
    return { cache: cached, stale: false };
  }

  try {
    return { cache: await fetchPricing(), stale: false };
  } catch (error) {
    if (cached) {
      console.error("Using stale Copilot pricing after refresh failure:", error);
      return { cache: cached, stale: true };
    }
    throw error;
  }
}

function lookupRates(
  model: PickerModel,
  pricing: CopilotPricing,
  overrides: CreditOverrides,
): PricingRate[] | undefined {
  const candidates = [model.id, model.name ?? ""]
    .map(normalizeModelName)
    .filter(Boolean);
  for (const candidate of candidates) {
    if (overrides[candidate]) return overrides[candidate];
    if (pricing[candidate]) return pricing[candidate];
  }
  return undefined;
}

function formatContextWindow(tokens: number | undefined): string {
  if (!tokens) return "context ?";
  if (tokens >= 1_000_000) return `${tokens / 1_000_000}M context`;
  return `${Math.round(tokens / 1_000)}K context`;
}

function modelLabel(
  model: PickerModel,
  pricing: CopilotPricing,
  overrides: CreditOverrides,
): string {
  const capabilities = [
    formatPricingLabel(lookupRates(model, pricing, overrides)),
    formatContextWindow(model.contextWindow),
    model.reasoning ? "reasoning" : undefined,
  ].filter(Boolean);
  return `${model.name ?? model.id}  —  ${capabilities.join("  ·  ")}  [${model.id}]`;
}

async function refreshAndNotify(
  forceRefresh: boolean,
  ctx: { ui: { notify(message: string, level: "info" | "warning" | "error"): void } },
): Promise<PricingCache | undefined> {
  try {
    const result = await getPricing(forceRefresh);
    const age = Math.max(0, Date.now() - result.cache.fetchedAt);
    const days = Math.floor(age / (24 * 60 * 60 * 1000));
    const status = result.stale ? "using stale cache" : "up to date";
    ctx.ui.notify(`Copilot pricing ${status} (${days}d old)`, result.stale ? "warning" : "info");
    return result.cache;
  } catch (error) {
    ctx.ui.notify(`Could not load Copilot pricing: ${String(error)}`, "error");
    return undefined;
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("copilot-model", {
    description: "Choose a GitHub Copilot model with AI-credit pricing",
    handler: async (_args, ctx) => {
      const pricingResult = await refreshAndNotify(false, ctx);
      if (!pricingResult) return;

      const allModels = ctx.modelRegistry.getAll() as PickerModel[];
      const copilotModels = allModels.filter(
        (model) => model.provider === "github-copilot",
      );
      if (copilotModels.length === 0) {
        ctx.ui.notify("No GitHub Copilot models are currently available", "warning");
        return;
      }

      const overrides = readOverrides();
      const labels = copilotModels.map((model) =>
        modelLabel(model, pricingResult.rates, overrides),
      );
      const selected = await ctx.ui.select(
        "GitHub Copilot models — AI credits per million tokens (input/cached/output)",
        labels,
      );
      if (!selected) return;

      const selectedIndex = labels.indexOf(selected);
      const model = copilotModels[selectedIndex];
      if (!model) return;

      const success = await pi.setModel(model as never);
      if (success === false) {
        ctx.ui.notify(`Could not select ${model.name ?? model.id}; check /login`, "error");
        return;
      }
      ctx.ui.notify(`Selected ${model.name ?? model.id}`, "info");
    },
  });

  pi.registerCommand("copilot-credits", {
    description: "Refresh or show GitHub Copilot AI-credit pricing",
    handler: async (args, ctx) => {
      if (args.trim() === "refresh") {
        await refreshAndNotify(true, ctx);
        return;
      }

      const result = await refreshAndNotify(false, ctx);
      if (!result) return;
      ctx.ui.notify(
        `Source: ${result.source}\nCache: ${CACHE_PATH}\nOverrides: ${OVERRIDES_PATH}`,
        "info",
      );
    },
  });
}
