/**
 * Local LLM context window extension
 *
 * Fetches the local llama.cpp server's /v1/models endpoint at startup,
 * reads each model's `meta.n_ctx`, and re-registers the configured
 * provider with the real context window. This fills in the context size
 * in pi's main footer, and the value is shared with context-tokens.ts
 * (second footer) via ./store.ts.
 */

import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { CONFIG_DIR_NAME, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { setContextWindow } from "./store";

const MODELS_URL = process.env.PI_LOCAL_LLM_MODELS_URL ?? "http://192.168.68.111:1234/v1/models";
const PROVIDER_ID = "rofedl-llm";

interface LlamaCppModelEntry {
	id: string;
	meta?: { n_ctx?: number };
}

interface LlamaCppModelsResponse {
	data?: LlamaCppModelEntry[];
}

interface LocalModelDef {
	id: string;
	[name: string]: unknown;
}

export default async function (pi: ExtensionAPI) {
	// 1. Fetch the live model list from the local server.
	let payload: LlamaCppModelsResponse;
	try {
		const response = await fetch(MODELS_URL, { signal: AbortSignal.timeout(5000) });
		if (!response.ok) throw new Error(`HTTP ${response.status}`);
		payload = (await response.json()) as LlamaCppModelsResponse;
	} catch (err) {
		console.error(`[local-ctx] could not fetch ${MODELS_URL}:`, err instanceof Error ? err.message : err);
		return;
	}

	// 2. Collect n_ctx per model id.
	const nCtxById = new Map<string, number>();
	for (const model of payload.data ?? []) {
		const nCtx = model.meta?.n_ctx;
		if (typeof nCtx === "number" && nCtx > 0) nCtxById.set(model.id, nCtx);
	}
	if (nCtxById.size === 0) {
		console.error("[local-ctx] no models with meta.n_ctx reported by server");
		return;
	}

	// 3. Load the provider config from models.json so we preserve all
	//    existing fields (name, reasoning, thinkingLevelMap, ...) and only
	//    add the discovered contextWindow.
	let providerConfig: { baseUrl?: string; api?: string; apiKey?: string; models?: LocalModelDef[] };
	try {
		const modelsJsonPath = join(homedir(), CONFIG_DIR_NAME, "agent", "models.json");
		const modelsJson = JSON.parse(readFileSync(modelsJsonPath, "utf8"));
		providerConfig = modelsJson.providers?.[PROVIDER_ID];
		if (!providerConfig) throw new Error(`provider "${PROVIDER_ID}" not found in models.json`);
	} catch (err) {
		console.error("[local-ctx] could not load provider config:", err instanceof Error ? err.message : err);
		return;
	}

	// 4. Re-register the provider with context windows filled in.
	//
	// NOTE: extension-provided models (via pi.registerProvider) do NOT go through
	// pi's modelFromJson() defaulting, so we must carry cost/maxTokens/contextWindow
	// forward explicitly. Dropping `cost` leaves model.cost === undefined, which
	// crashes calculateCost() ("reading 'tiers'") on every assistant message_end.
	const models = (providerConfig.models ?? []).map((model) => {
		const nCtx = nCtxById.get(model.id);
		return {
			...model,
			cost: model.cost ?? { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
			contextWindow: nCtx ?? model.contextWindow ?? 128000,
			maxTokens: model.maxTokens ?? nCtx ?? 16384,
		};
	});

	pi.registerProvider(PROVIDER_ID, {
		baseUrl: providerConfig.baseUrl,
		apiKey: providerConfig.apiKey,
		api: providerConfig.api,
		models,
	});

	// 5. Share the values with the second-footer extension.
	for (const [id, nCtx] of nCtxById) setContextWindow(id, nCtx);
}
