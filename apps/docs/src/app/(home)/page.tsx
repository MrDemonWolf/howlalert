import Link from "next/link";

export default function HomePage() {
  return (
    <main className="min-h-screen bg-[#091533] text-white">
      {/* Hero */}
      <section className="flex flex-col items-center justify-center px-4 py-24 text-center">
        <div className="mb-4 inline-block rounded-full bg-[#0FACED]/20 px-4 py-1 text-sm font-medium text-[#0FACED]">
          Claude Code Usage Monitor
        </div>
        <h1 className="mb-6 text-5xl font-bold tracking-tight md:text-6xl">
          Never hit your <span className="text-[#0FACED]">Claude limit</span> mid-session
        </h1>
        <p className="mb-10 max-w-2xl text-lg text-gray-400">
          HowlAlert watches your Claude Code token usage in real-time and sends push notifications
          to your iPhone and Apple Watch before you run out.
        </p>
        <div className="flex gap-4">
          <a
            href="https://apps.apple.com"
            className="rounded-lg bg-[#0FACED] px-6 py-3 font-semibold text-[#091533] transition hover:opacity-90"
          >
            Download on iOS
          </a>
          <Link
            href="/docs"
            className="rounded-lg border border-[#0FACED]/40 px-6 py-3 font-semibold text-[#0FACED] transition hover:bg-[#0FACED]/10"
          >
            Read Docs
          </Link>
        </div>
      </section>

      {/* Features */}
      <section className="px-4 py-16">
        <div className="mx-auto max-w-5xl">
          <h2 className="mb-12 text-center text-3xl font-bold">How it works</h2>
          <div className="grid gap-8 md:grid-cols-3">
            {[
              {
                icon: "⚡",
                title: "Real-time monitoring",
                desc: "macOS app watches Claude's session files via FSEvents — zero latency, no polling.",
              },
              {
                icon: "🔔",
                title: "Push notifications",
                desc: "Get alerted on iPhone and Apple Watch when you hit 75% and 90% of your plan limit.",
              },
              {
                icon: "🔒",
                title: "Privacy first",
                desc: "No accounts, no servers storing your data. Tokens stay local. Push relay is stateless.",
              },
            ].map((f) => (
              <div key={f.title} className="rounded-xl border border-white/10 bg-white/5 p-6">
                <div className="mb-3 text-3xl">{f.icon}</div>
                <h3 className="mb-2 text-lg font-semibold">{f.title}</h3>
                <p className="text-gray-400">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section className="px-4 py-16">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="mb-4 text-3xl font-bold">Simple pricing</h2>
          <p className="mb-10 text-gray-400">1-week free trial, cancel anytime.</p>
          <div className="grid gap-6 md:grid-cols-2">
            <div className="rounded-xl border border-white/10 bg-white/5 p-8">
              <div className="mb-2 text-2xl font-bold">$3.99 <span className="text-base font-normal text-gray-400">/ month</span></div>
              <p className="text-gray-400">Monthly subscription</p>
            </div>
            <div className="rounded-xl border border-[#0FACED]/40 bg-[#0FACED]/10 p-8">
              <div className="mb-2 text-2xl font-bold text-[#0FACED]">$35.99 <span className="text-base font-normal text-gray-400">/ year</span></div>
              <p className="text-gray-400">Annual — save 25%</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-white/10 px-4 py-8 text-center text-sm text-gray-500">
        <div className="flex justify-center gap-6">
          <Link href="/docs/legal/privacy-policy" className="hover:text-white">Privacy Policy</Link>
          <Link href="/docs/legal/terms-of-service" className="hover:text-white">Terms of Service</Link>
          <Link href="/docs" className="hover:text-white">Docs</Link>
        </div>
        <p className="mt-4">© {new Date().getFullYear()} MrDemonWolf. All rights reserved.</p>
      </footer>
    </main>
  );
}
