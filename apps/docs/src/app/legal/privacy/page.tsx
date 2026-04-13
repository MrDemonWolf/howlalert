import type { Metadata } from "next";

export const metadata: Metadata = { title: "Privacy Policy" };

export default function PrivacyPage() {
  return (
    <article className="prose dark:prose-invert max-w-3xl mx-auto px-6 py-16">
      <h1>Privacy Policy</h1>
      <p><em>Last updated: April 12, 2026</em></p>
      <p>
        HowlAlert (&quot;the App&quot;) is operated by MrDemonWolf, Inc.
        (&quot;we&quot;, &quot;us&quot;). This policy describes how we handle
        your data.
      </p>

      <h2>What We Collect</h2>
      <ul>
        <li>
          <strong>APNs Device Token</strong> — a pseudonymous identifier
          assigned by Apple for push notification delivery. Stored in
          Cloudflare KV with a 30-day TTL. Not linked to your identity.
        </li>
        <li>
          <strong>Subscription Status</strong> — RevenueCat provides
          subscription validation events. We store entitlement state
          (active/inactive, expiry date) in Cloudflare D1 keyed by your
          CloudKit user ID (a pseudonymous identifier).
        </li>
      </ul>

      <h2>What We Do NOT Collect</h2>
      <ul>
        <li>Your name, email, or any personally identifiable information</li>
        <li>Your code, prompts, or Claude Code conversation content</li>
        <li>Analytics, crash reports, or device fingerprints</li>
        <li>Location data</li>
      </ul>

      <h2>How Your Data Flows</h2>
      <ol>
        <li>The macOS app reads token counts from Claude Code JSONL session files on your Mac. This data never leaves your device except as aggregate usage numbers.</li>
        <li>Usage snapshots are written to your own iCloud private database (CloudKit). Only devices signed into your Apple ID can access this data.</li>
        <li>When a threshold is crossed, your Mac sends a push request to our Cloudflare Worker with the device token and usage percentage. The Worker forwards it to Apple APNs and discards the request.</li>
      </ol>

      <h2>Third-Party Services</h2>
      <ul>
        <li><strong>Apple CloudKit</strong> — private database for device pairing and usage sync (Apple&apos;s privacy policy applies)</li>
        <li><strong>Apple APNs</strong> — push notification delivery</li>
        <li><strong>RevenueCat</strong> — subscription management and validation</li>
        <li><strong>Cloudflare Workers</strong> — serverless push relay infrastructure</li>
      </ul>

      <h2>Data Retention</h2>
      <p>
        Device tokens expire after 30 days of inactivity. Push logs in D1 are
        deleted after 30 days. Entitlement records persist while your
        subscription is active and are deleted 90 days after expiry.
      </p>

      <h2>Your Rights (GDPR)</h2>
      <p>
        Under GDPR Art. 6(1)(b), we process data necessary for contract
        performance (delivering push notifications you subscribed to). You can
        request data deletion by emailing{" "}
        <a href="mailto:legal@mrdemonwolf.com">legal@mrdemonwolf.com</a>. We
        will delete all records associated with your CloudKit user ID within 30
        days.
      </p>

      <h2>Children</h2>
      <p>HowlAlert is not directed at children under 13.</p>

      <h2>Changes</h2>
      <p>
        We may update this policy. Material changes will be noted in app
        release notes. Continued use constitutes acceptance.
      </p>

      <h2>Contact</h2>
      <p>
        Privacy questions: <a href="mailto:legal@mrdemonwolf.com">legal@mrdemonwolf.com</a>
      </p>
      <p className="text-sm text-gray-400 mt-8">&copy; 2026 MrDemonWolf, Inc.</p>
    </article>
  );
}
