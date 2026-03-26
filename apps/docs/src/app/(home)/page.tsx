import Link from "next/link";

export default function HomePage() {
	return (
		<main className="flex min-h-screen flex-col items-center justify-center p-8 text-center">
			<h1 className="mb-4 text-4xl font-bold">HowlAlert</h1>
			<p className="mb-8 max-w-lg text-lg text-gray-600 dark:text-gray-400">
				Claude Code usage monitor &amp; push notification system for Apple
				platforms.
			</p>
			<Link
				href="/docs"
				className="rounded-lg bg-blue-600 px-6 py-3 text-white hover:bg-blue-700"
			>
				Read the Docs
			</Link>
		</main>
	);
}
