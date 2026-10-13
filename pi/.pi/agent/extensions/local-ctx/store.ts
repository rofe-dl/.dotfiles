/**
 * Shared store for context windows discovered from the local LLM server.
 * Written by local-ctx/index.ts at startup, read by context-tokens.ts.
 */

const windows = new Map<string, number>();

export function setContextWindow(modelId: string, nCtx: number) {
	windows.set(modelId, nCtx);
}

export function getContextWindow(modelId: string | undefined): number | undefined {
	if (!modelId) return undefined;
	return windows.get(modelId);
}
