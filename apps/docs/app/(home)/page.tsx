import Link from "next/link";
import {
	Zap,
	Bell,
	Smartphone,
	Shield,
	Activity,
	Lock,
	Globe,
} from "lucide-react";

export default function HomePage() {
	return (
		<main className="flex flex-col">
			{/* Hero */}
			<section className="relative flex flex-col items-center justify-center gap-8 px-8 py-32 text-center overflow-hidden">
				<div className="hero-glow" />
				<div className="relative z-10 flex flex-col gap-4">
					<h1 className="text-5xl sm:text-7xl font-bold tracking-tight">
						<span className="gradient-text">Stay on Budget</span>
					</h1>
					<p className="text-lg sm:text-xl text-fd-muted-foreground max-w-2xl mx-auto">
						Monitor your Claude Code usage in real time. Get push
						notifications before you hit your spending limits —
						across macOS, iOS, and watchOS.
					</p>
				</div>
				<div className="relative z-10 flex flex-col sm:flex-row items-center gap-4">
					<Link
						href="https://apps.apple.com/us/app/howlalert/id6760729438"
						target="_blank"
						rel="noopener noreferrer"
					>
						<img
							src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"
							alt="Download on the App Store"
							className="h-14"
						/>
					</Link>
					<Link
						href="/docs"
						className="rounded-lg border border-fd-border px-6 py-3 font-medium hover:bg-fd-accent transition-colors"
					>
						Documentation
					</Link>
				</div>
			</section>

			{/* Features */}
			<section className="px-8 py-20">
				<div className="max-w-5xl mx-auto">
					<h2 className="text-3xl font-bold text-center mb-12">
						Everything you need to stay on budget
					</h2>
					<div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
						<div className="feature-card">
							<div className="flex h-12 w-12 items-center justify-center rounded-lg bg-amber-500/10">
								<Zap className="h-6 w-6 text-amber-500" />
							</div>
							<h3 className="font-semibold text-lg">
								Real-time monitoring
							</h3>
							<p className="text-sm text-fd-muted-foreground">
								FSEvents-based file watcher reads Claude
								Code&apos;s local session data instantly. Zero
								polling delay, zero cloud dependency.
							</p>
						</div>
						<div className="feature-card">
							<div className="flex h-12 w-12 items-center justify-center rounded-lg bg-orange-500/10">
								<Bell className="h-6 w-6 text-orange-500" />
							</div>
							<h3 className="font-semibold text-lg">
								Push notifications
							</h3>
							<p className="text-sm text-fd-muted-foreground">
								Set daily cost, token, or session thresholds.
								Get an APNs push to your iPhone or Apple Watch
								the moment you exceed them.
							</p>
						</div>
						<div className="feature-card">
							<div className="flex h-12 w-12 items-center justify-center rounded-lg bg-emerald-500/10">
								<Smartphone className="h-6 w-6 text-emerald-500" />
							</div>
							<h3 className="font-semibold text-lg">
								Multi-platform
							</h3>
							<p className="text-sm text-fd-muted-foreground">
								macOS menu bar widget, iOS dashboard, and
								watchOS complications — stay informed on every
								device you own.
							</p>
						</div>
						<div className="feature-card">
							<div className="flex h-12 w-12 items-center justify-center rounded-lg bg-violet-500/10">
								<Shield className="h-6 w-6 text-violet-500" />
							</div>
							<h3 className="font-semibold text-lg">
								Privacy-first
							</h3>
							<p className="text-sm text-fd-muted-foreground">
								Usage data never leaves your Mac. The cloud
								relay only forwards push notification triggers —
								nothing else is stored.
							</p>
						</div>
					</div>
				</div>
			</section>

			{/* Get Started */}
			<section className="bg-fd-muted/40 px-8 py-20">
				<div className="max-w-3xl mx-auto">
					<h2 className="text-3xl font-bold text-center mb-12">
						Get started in 3 steps
					</h2>
					<ol className="flex flex-col gap-8">
						<li className="flex gap-6 items-start">
							<span className="flex-shrink-0 w-10 h-10 rounded-full bg-fd-primary text-fd-primary-foreground flex items-center justify-center font-bold text-lg">
								1
							</span>
							<div>
								<h3 className="font-semibold text-lg mb-1">
									Install the app
								</h3>
								<p className="text-fd-muted-foreground">
									Download HowlAlert from the App Store on
									your Mac and iPhone. The watchOS companion
									installs automatically via the Watch app.
								</p>
							</div>
						</li>
						<li className="flex gap-6 items-start">
							<span className="flex-shrink-0 w-10 h-10 rounded-full bg-fd-primary text-fd-primary-foreground flex items-center justify-center font-bold text-lg">
								2
							</span>
							<div>
								<h3 className="font-semibold text-lg mb-1">
									Configure your thresholds
								</h3>
								<p className="text-fd-muted-foreground">
									Set a daily cost limit (e.g. $5), token
									count, or session count. HowlAlert monitors
									Claude Code&apos;s local data in real time.
								</p>
							</div>
						</li>
						<li className="flex gap-6 items-start">
							<span className="flex-shrink-0 w-10 h-10 rounded-full bg-fd-primary text-fd-primary-foreground flex items-center justify-center font-bold text-lg">
								3
							</span>
							<div>
								<h3 className="font-semibold text-lg mb-1">
									Get alerted
								</h3>
								<p className="text-fd-muted-foreground">
									The moment you cross a threshold, a push
									notification fires to all your devices. No
									surprises at the end of the month.
								</p>
							</div>
						</li>
					</ol>
				</div>
			</section>

			{/* Why HowlAlert */}
			<section className="px-8 py-20">
				<div className="max-w-5xl mx-auto">
					<h2 className="text-3xl font-bold text-center mb-12">
						Why HowlAlert
					</h2>
					<div className="grid grid-cols-1 sm:grid-cols-3 gap-8 text-center">
						<div className="flex flex-col items-center gap-3">
							<div className="flex h-14 w-14 items-center justify-center rounded-full bg-amber-500/10">
								<Activity className="h-7 w-7 text-amber-500" />
							</div>
							<h3 className="font-semibold text-lg">
								Zero Polling Delay
							</h3>
							<p className="text-sm text-fd-muted-foreground max-w-xs">
								Native FSEvents integration means your usage
								data updates the instant Claude Code writes it.
								No intervals, no lag.
							</p>
						</div>
						<div className="flex flex-col items-center gap-3">
							<div className="flex h-14 w-14 items-center justify-center rounded-full bg-orange-500/10">
								<Lock className="h-7 w-7 text-orange-500" />
							</div>
							<h3 className="font-semibold text-lg">
								Privacy by Design
							</h3>
							<p className="text-sm text-fd-muted-foreground max-w-xs">
								All processing happens on-device. The only data
								that leaves your Mac is the push notification
								trigger — no usage details, no telemetry.
							</p>
						</div>
						<div className="flex flex-col items-center gap-3">
							<div className="flex h-14 w-14 items-center justify-center rounded-full bg-emerald-500/10">
								<Globe className="h-7 w-7 text-emerald-500" />
							</div>
							<h3 className="font-semibold text-lg">
								Every Device
							</h3>
							<p className="text-sm text-fd-muted-foreground max-w-xs">
								macOS menu bar, iOS app, and watchOS
								complications. One threshold config, alerts
								everywhere.
							</p>
						</div>
					</div>
				</div>
			</section>
		</main>
	);
}
