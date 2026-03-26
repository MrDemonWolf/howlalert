"use client";

import useSWR from "swr";
import { getPushLog } from "@/lib/api";
import type { PushLogEntry } from "@/types";

export function usePushLog(polling = false) {
	return useSWR<PushLogEntry[]>("push-log", getPushLog, {
		refreshInterval: polling ? 5_000 : 0,
		revalidateOnFocus: true,
	});
}
