import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default async function (pi: ExtensionAPI) {
  let payload: {
    data: Array<{
      id: string;
      name?: string;
      context_window?: number;
      max_tokens?: number;
    }>;
  };

  try {
    const response = await fetch("https://inference.labs.ai.linode.com/v1/models", { signal: AbortSignal.timeout(5000)});
    if (!response.ok) {
      throw new Error(`unexpected status ${response.status}`);
    }
    payload = await response.json();
  } catch (error) {
    const message = `linode-inference: failed to connect to Linode Inference API, extension disabled: ${
      error instanceof Error ? error.message : String(error)
    }`;
    console.warn(message);
    pi.on("session_start", async (_event, ctx) => {
      if (ctx.hasUI) ctx.ui.notify(message, "warning");
    });
    return;
  }

  pi.registerProvider("linode-inference", {
    baseUrl: "https://inference.labs.ai.linode.com/v1",
    // apiKey: "$LOCAL_OPENAI_API_KEY",
    apiKey: "!op read 'op://Employee/Linode Inference API Key/password'",
    api: "openai-completions",
    models: payload.data.map((model) => ({
      id: model.id,
      name: model.name ?? model.id,
      reasoning: false,
      input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow: model.context_window ?? 128000,
      maxTokens: model.max_tokens ?? 4096,
    })),
  });
}
