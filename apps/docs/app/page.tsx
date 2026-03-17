import Link from "next/link";

export default function HomePage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-8 p-8">
      <div className="text-center">
        <h1 className="text-5xl font-bold mb-4">HowlAlert</h1>
        <p className="text-xl text-muted-foreground max-w-xl">
          Monitor your Claude Code usage and get notified before you hit limits.
        </p>
      </div>
      <div className="flex gap-4">
        <Link
          href="/docs"
          className="rounded-lg bg-primary px-6 py-3 text-primary-foreground font-medium hover:bg-primary/90 transition-colors"
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
    </main>
  );
}
