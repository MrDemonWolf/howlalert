import Link from "next/link";

const features = [
  {
    title: "Crit Bar",
    desc: "Color-coded usage bar — cyan, amber, red — so you know at a glance.",
  },
  {
    title: "Pace Tracking",
    desc: "Are you burning too fast? Pace math tells you if you're in debt, on track, or in reserve.",
  },
  {
    title: "Multi-Mac Sync",
    desc: "Running Claude on multiple Macs? Usage aggregates across all of them automatically.",
  },
  {
    title: "Watch Complications",
    desc: "Circular complication on your wrist. Ring fills, wolf tints. Tap for details.",
  },
  {
    title: '"Claude is Done" Alerts',
    desc: "A haptic tap on your Watch the moment Claude finishes replying. Stop polling your terminal.",
  },
  {
    title: "Dynamic Island",
    desc: "Live usage on iPhone 15 Pro and newer. Compact or expanded — your call.",
  },
];

const steps = [
  { num: "1", title: "Mac watches", desc: "HowlAlert reads Claude Code session files via FSEvents. No hooks, no config." },
  { num: "2", title: "Worker relays", desc: "A Cloudflare Worker sends a push notification through APNs. Zero data stored." },
  { num: "3", title: "Devices alert", desc: "iPhone banner, Watch haptic, Dynamic Island. Wherever you are." },
];

const faqs = [
  { q: "Does HowlAlert read my code?", a: "No. It only reads token counts from JSONL session metadata. Never file contents." },
  { q: "Do I need an account?", a: "No. HowlAlert uses your iCloud for automatic pairing. No login, no sign-up." },
  { q: "What about privacy?", a: "APNs device tokens only. No analytics, no tracking, no third-party data sharing. Your usage data stays in your own iCloud." },
  { q: "Does it work offline?", a: "The Mac menu bar works fully offline. Push notifications require internet. Entitlement caches for 7 days offline." },
];

export default function HomePage() {
  return (
    <main>
      {/* Hero */}
      <section className="flex flex-col items-center justify-center text-center px-6 py-24" style={{ background: "linear-gradient(180deg, #091533 0%, #0c1d45 100%)" }}>
        <div className="text-6xl mb-6">🐺</div>
        <h1 className="text-4xl md:text-5xl font-bold text-white mb-4">
          Know your Claude Code limits.{" "}
          <span style={{ color: "#0FACED" }}>Everywhere.</span>
        </h1>
        <p className="text-lg text-gray-300 max-w-2xl mb-8">
          Real-time usage tracking across all your Macs. Push alerts before you
          hit the wall. A tap on your wrist when Claude finishes replying.
        </p>
        <div className="flex flex-col sm:flex-row gap-4 mb-4">
          <a
            href="#"
            className="inline-flex items-center gap-2 px-6 py-3 rounded-lg text-white font-semibold"
            style={{ backgroundColor: "#0FACED" }}
          >
            Download for macOS
          </a>
          <a
            href="#"
            className="inline-flex items-center gap-2 px-6 py-3 rounded-lg text-white font-semibold border border-gray-500 opacity-60 cursor-not-allowed"
          >
            Get on the App Store
          </a>
        </div>
        <p className="text-sm text-gray-400">
          Requires Apple Silicon &middot; macOS 15 + iOS 17 or later
        </p>
      </section>

      {/* Features */}
      <section className="px-6 py-20 max-w-5xl mx-auto">
        <h2 className="text-3xl font-bold text-center mb-12">Features</h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((f) => (
            <div key={f.title} className="p-6 rounded-xl border">
              <h3 className="text-lg font-semibold mb-2">{f.title}</h3>
              <p className="text-sm text-gray-500 dark:text-gray-400">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Pricing */}
      <section className="px-6 py-20 text-center" style={{ background: "linear-gradient(180deg, transparent 0%, #091533 100%)" }}>
        <h2 className="text-3xl font-bold mb-4">Simple Pricing</h2>
        <p className="text-gray-400 mb-8">macOS companion app is free forever. iOS unlocks with Pro.</p>
        <div className="inline-flex flex-col sm:flex-row gap-6">
          <div className="p-8 rounded-2xl border text-center min-w-[220px]">
            <div className="text-sm text-gray-400 mb-1">Monthly</div>
            <div className="text-4xl font-bold mb-1">$3.99</div>
            <div className="text-sm text-gray-400">per month</div>
          </div>
          <div className="p-8 rounded-2xl border text-center min-w-[220px]" style={{ borderColor: "#0FACED" }}>
            <div className="text-sm mb-1" style={{ color: "#0FACED" }}>Annual — Save 25%</div>
            <div className="text-4xl font-bold mb-1">$35.99</div>
            <div className="text-sm text-gray-400">per year</div>
          </div>
        </div>
        <p className="text-sm text-gray-400 mt-6">7-day free trial &middot; Cancel anytime</p>
      </section>

      {/* How it works */}
      <section className="px-6 py-20 max-w-4xl mx-auto">
        <h2 className="text-3xl font-bold text-center mb-12">How It Works</h2>
        <div className="grid md:grid-cols-3 gap-8">
          {steps.map((s) => (
            <div key={s.num} className="text-center">
              <div
                className="w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-lg mx-auto mb-4"
                style={{ backgroundColor: "#0FACED" }}
              >
                {s.num}
              </div>
              <h3 className="font-semibold mb-2">{s.title}</h3>
              <p className="text-sm text-gray-500 dark:text-gray-400">{s.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* FAQ */}
      <section className="px-6 py-20 max-w-3xl mx-auto">
        <h2 className="text-3xl font-bold text-center mb-12">FAQ</h2>
        <div className="space-y-6">
          {faqs.map((f) => (
            <div key={f.q} className="border-b pb-4">
              <h3 className="font-semibold mb-2">{f.q}</h3>
              <p className="text-sm text-gray-500 dark:text-gray-400">{f.a}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Footer */}
      <footer className="px-6 py-12 text-center text-sm text-gray-400 border-t">
        <div className="flex flex-wrap justify-center gap-6 mb-4">
          <Link href="/legal/privacy" className="hover:underline">Privacy Policy</Link>
          <Link href="/legal/terms" className="hover:underline">Terms of Service</Link>
          <Link href="/legal/subscription-terms" className="hover:underline">Subscription Terms</Link>
          <a href="mailto:support@mrdemonwolf.com" className="hover:underline">Support</a>
          <a href="https://github.com/mrdemonwolf/howlalert" className="hover:underline">GitHub</a>
        </div>
        <p>HowlAlert by MrDemonWolf, Inc. &middot; &copy; 2026</p>
      </footer>
    </main>
  );
}
