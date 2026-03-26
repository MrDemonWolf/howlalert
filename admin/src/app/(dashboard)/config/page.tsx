"use client";

import { useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";

export default function ConfigPage() {
	const [multiplier, setMultiplier] = useState<"1x" | "2x" | "custom">("1x");
	const [customValue, setCustomValue] = useState("");

	return (
		<div className="space-y-6">
			<h2 className="text-2xl font-semibold text-white">Config</h2>

			<Card>
				<div className="space-y-4">
					<div>
						<h3 className="text-sm font-medium text-gray-400">
							Multiplier
						</h3>
						<p className="mt-1 text-xs text-gray-500">
							Adjust the alert threshold multiplier
						</p>
					</div>

					<div className="flex gap-2">
						<Button
							variant={multiplier === "1x" ? "primary" : "ghost"}
							onClick={() => setMultiplier("1x")}
						>
							1x
						</Button>
						<Button
							variant={multiplier === "2x" ? "primary" : "ghost"}
							onClick={() => setMultiplier("2x")}
						>
							2x
						</Button>
						<Button
							variant={multiplier === "custom" ? "primary" : "ghost"}
							onClick={() => setMultiplier("custom")}
						>
							Custom
						</Button>
					</div>

					{multiplier === "custom" && (
						<div className="max-w-xs">
							<Input
								type="number"
								placeholder="Enter multiplier value"
								value={customValue}
								onChange={(e) => setCustomValue(e.target.value)}
								min="0.1"
								step="0.1"
							/>
						</div>
					)}

					<div className="flex items-center gap-2">
						<Badge variant="cyan">
							Current: {multiplier === "custom" ? (customValue || "...") : multiplier}
						</Badge>
					</div>

					<div className="border-t border-navy-lighter pt-4">
						<Button>Save Config</Button>
					</div>
				</div>
			</Card>
		</div>
	);
}
