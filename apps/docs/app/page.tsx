import Link from "next/link";

export default function HomePage() {
	return (
		<main className="flex min-h-screen flex-col">
			{/* Hero */}
			<section className="flex flex-col items-center justify-center gap-8 px-8 py-24 text-center">
				<div className="flex flex-col gap-4">
					<h1 className="text-6xl font-bold tracking-tight">HowlAlert</h1>
					<p className="text-xl text-muted-foreground max-w-2xl mx-auto">
						Monitor your Claude Code usage and get notified before you hit limits.
						Real-time cost tracking, push notifications, and multi-platform alerts — all private by default.
					</p>
				</div>
				<div className="flex flex-col sm:flex-row items-center gap-4">
					<Link
						href="https://apps.apple.com/us/app/howlalert/id6760729438"
						target="_blank"
						rel="noopener noreferrer"
					>
						{/* App Store badge */}
						<img
							src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"
							alt="Download on the App Store"
							className="h-14"
						/>
					</Link>
					<Link
						href="/docs"
						className="rounded-lg border px-6 py-3 font-medium hover:bg-accent transition-colors"
					>
						Documentation
					</Link>
					<Link
						href="https://github.com/mrdemonwolf/howlalert"
						className="rounded-lg border px-6 py-3 font-medium hover:bg-accent transition-colors"
						target="_blank"
						rel="noopener noreferrer"
					>
						GitHub
					</Link>
				</div>
			</section>

			{/* Features */}
			<section className="bg-muted/40 px-8 py-20">
				<div className="max-w-5xl mx-auto">
					<h2 className="text-3xl font-bold text-center mb-12">Everything you need to stay on budget</h2>
					<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
						<div className="rounded-xl border bg-card p-6 flex flex-col gap-3">
							<div className="text-3xl">⚡</div>
							<h3 className="font-semibold text-lg">Real-time monitoring</h3>
							<p className="text-sm text-muted-foreground">
								FSEvents-based file watcher reads Claude Code's local session data instantly. Zero polling delay, zero cloud dependency.
							</p>
						</div>
						<div className="rounded-xl border bg-card p-6 flex flex-col gap-3">
							<div className="text-3xl">🔔</div>
							<h3 className="font-semibold text-lg">Push notifications</h3>
							<p className="text-sm text-muted-foreground">
								Set daily cost, token, or session thresholds. Get an APNs push to your iPhone or Apple Watch the moment you exceed them.
							</p>
						</div>
						<div className="rounded-xl border bg-card p-6 flex flex-col gap-3">
							<div className="text-3xl">📱</div>
							<h3 className="font-semibold text-lg">Multi-platform</h3>
							<p className="text-sm text-muted-foreground">
								macOS menu bar widget, iOS dashboard, and watchOS complications — stay informed on every device you own.
							</p>
						</div>
						<div className="rounded-xl border bg-card p-6 flex flex-col gap-3">
							<div className="text-3xl">🔒</div>
							<h3 className="font-semibold text-lg">Privacy-first</h3>
							<p className="text-sm text-muted-foreground">
								Usage data never leaves your Mac. The cloud relay only forwards push notification triggers — nothing else is stored.
							</p>
						</div>
					</div>
				</div>
			</section>

			{/* How it works */}
			<section className="px-8 py-20">
				<div className="max-w-3xl mx-auto">
					<h2 className="text-3xl font-bold text-center mb-12">Up and running in minutes</h2>
					<ol className="flex flex-col gap-8">
						<li className="flex gap-6 items-start">
							<span className="flex-shrink-0 w-10 h-10 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold text-lg">1</span>
							<div>
								<h3 className="font-semibold text-lg mb-1">Install the app</h3>
								<p className="text-muted-foreground">Download HowlAlert from the App Store on your Mac and iPhone. The watchOS companion installs automatically via the Watch app.</p>
							</div>
						</li>
						<li className="flex gap-6 items-start">
							<span className="flex-shrink-0 w-10 h-10 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold text-lg">2</span>
							<div>
								<h3 className="font-semibold text-lg mb-1">Configure your thresholds</h3>
								<p className="text-muted-foreground">Set a daily cost limit (e.g. $5), token count, or session count. HowlAlert monitors Claude Code's local data in real time.</p>
							</div>
						</li>
						<li className="flex gap-6 items-start">
							<span className="flex-shrink-0 w-10 h-10 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold text-lg">3</span>
							<div>
								<h3 className="font-semibold text-lg mb-1">Get alerted</h3>
								<p className="text-muted-foreground">The moment you cross a threshold, a push notification fires to all your devices. No surprises at the end of the month.</p>
							</div>
						</li>
					</ol>
				</div>
			</section>

			{/* Platforms */}
			<section className="bg-muted/40 px-8 py-16">
				<div className="max-w-3xl mx-auto text-center">
					<h2 className="text-2xl font-bold mb-6">Platform requirements</h2>
					<div className="flex flex-col sm:flex-row justify-center gap-8 text-muted-foreground">
						<div className="flex flex-col gap-1">
							<span className="text-3xl">🖥</span>
							<span className="font-medium text-foreground">macOS</span>
							<span className="text-sm">macOS 15 Sequoia or later</span>
						</div>
						<div className="flex flex-col gap-1">
							<span className="text-3xl">📱</span>
							<span className="font-medium text-foreground">iOS</span>
							<span className="text-sm">iOS 18 or later</span>
						</div>
						<div className="flex flex-col gap-1">
							<span className="text-3xl">⌚</span>
							<span className="font-medium text-foreground">watchOS</span>
							<span className="text-sm">watchOS 11 or later</span>
						</div>
					</div>
				</div>
			</section>

			{/* Footer */}
			<footer className="border-t px-8 py-8">
				<div className="max-w-5xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-muted-foreground">
					<span>© 2026 MrDemonWolf. All rights reserved.</span>
					<div className="flex gap-6">
						<Link href="/docs/legal/privacy-policy" className="hover:text-foreground transition-colors">Privacy Policy</Link>
						<Link href="/docs/legal/terms-of-service" className="hover:text-foreground transition-colors">Terms of Service</Link>
						<Link href="https://github.com/mrdemonwolf/howlalert" target="_blank" rel="noopener noreferrer" className="hover:text-foreground transition-colors">GitHub</Link>
					</div>
				</div>
			</footer>
		</main>
	);
}
