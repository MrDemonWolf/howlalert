import type { Metadata } from "next";

export const metadata: Metadata = { title: "Terms of Service" };

export default function TermsPage() {
  return (
    <article className="prose dark:prose-invert max-w-3xl mx-auto px-6 py-16">
      <h1>Terms of Service</h1>
      <p><em>Last updated: April 12, 2026</em></p>

      <h2>Agreement</h2>
      <p>
        By using HowlAlert (&quot;the App&quot;), you agree to these terms. The
        App is provided by MrDemonWolf, Inc. (&quot;we&quot;, &quot;us&quot;).
      </p>

      <h2>Description</h2>
      <p>
        HowlAlert monitors Claude Code token usage on macOS and delivers push
        notifications to iOS and watchOS devices. The macOS app is free. The iOS
        app requires a paid subscription.
      </p>

      <h2>Acceptable Use</h2>
      <ul>
        <li>Use the App only for its intended purpose: monitoring your own Claude Code usage.</li>
        <li>Do not reverse-engineer, decompile, or tamper with the App.</li>
        <li>Do not use the App to violate Anthropic&apos;s terms of service.</li>
      </ul>

      <h2>Intellectual Property</h2>
      <p>
        HowlAlert, the wolf logo, and associated branding are trademarks of
        MrDemonWolf, Inc. The App&apos;s source code is licensed under MIT.
      </p>

      <h2>Disclaimer</h2>
      <p>
        THE APP IS PROVIDED &quot;AS IS&quot; WITHOUT WARRANTY OF ANY KIND. We
        do not guarantee the accuracy of token usage estimates. Anthropic may
        change rate limits, JSONL formats, or API behavior at any time. We are
        not affiliated with Anthropic.
      </p>

      <h2>Limitation of Liability</h2>
      <p>
        To the maximum extent permitted by law, MrDemonWolf, Inc. shall not be
        liable for any indirect, incidental, or consequential damages arising
        from use of the App.
      </p>

      <h2>Termination</h2>
      <p>
        We may suspend or terminate access if you violate these terms. You may
        stop using the App at any time by uninstalling it and canceling your
        subscription.
      </p>

      <h2>Governing Law</h2>
      <p>
        These terms are governed by the laws of the State of Wisconsin, USA.
      </p>

      <h2>Contact</h2>
      <p>
        Legal questions: <a href="mailto:legal@mrdemonwolf.com">legal@mrdemonwolf.com</a>
      </p>
      <p className="text-sm text-gray-400 mt-8">&copy; 2026 MrDemonWolf, Inc.</p>
    </article>
  );
}
