"use client";

import useSWR from "swr";
import { getConfig } from "@/lib/api";
import type { LimitConfig } from "@/types";

export function useConfig() {
	return useSWR<LimitConfig>("config", getConfig, {
		refreshInterval: 30_000,
		revalidateOnFocus: true,
	});
}
