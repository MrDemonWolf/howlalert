"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import { verifyAuth } from "@/lib/api";
import { login } from "@/lib/auth";

export default function LoginPage() {
	const [token, setToken] = useState("");
	const [error, setError] = useState("");
	const [loading, setLoading] = useState(false);
	const router = useRouter();

	async function handleSubmit(e: React.FormEvent) {
		e.preventDefault();
		setError("");
		setLoading(true);

		try {
			const valid = await verifyAuth(token);
			if (valid) {
				login(token);
				router.push("/dashboard");
			} else {
				setError("Invalid token. Please try again.");
			}
		} catch {
			setError("Failed to verify token. Is the worker running?");
		} finally {
			setLoading(false);
		}
	}

	return (
		<div className="flex min-h-screen items-center justify-center p-4">
			<Card className="w-full max-w-sm">
				<div className="mb-6 text-center">
					<div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-cyan/15 text-cyan text-2xl font-bold">
						W
					</div>
					<h1 className="text-xl font-semibold text-white">
						HowlAlert Admin
					</h1>
					<p className="mt-1 text-sm text-gray-400">
						Enter your admin token to continue
					</p>
				</div>
				<form onSubmit={handleSubmit} className="space-y-4">
					<Input
						type="password"
						placeholder="Admin token"
						value={token}
						onChange={(e) => setToken(e.target.value)}
						required
					/>
					{error && (
						<p className="text-sm text-red">{error}</p>
					)}
					<Button
						type="submit"
						disabled={loading || !token}
						className="w-full"
					>
						{loading ? "Verifying..." : "Sign In"}
					</Button>
				</form>
			</Card>
		</div>
	);
}
