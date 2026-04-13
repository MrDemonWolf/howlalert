import type { Metadata } from "next";

export const metadata: Metadata = { title: "Subscription Terms" };

export default function SubscriptionTermsPage() {
  return (
    <article className="prose dark:prose-invert max-w-3xl mx-auto px-6 py-16">
      <h1>Subscription Terms</h1>
      <p><em>Last updated: April 12, 2026</em></p>

      <h2>Plans</h2>
      <ul>
        <li><strong>HowlAlert Pro Monthly</strong> — $3.99/month with a 7-day free trial</li>
        <li><strong>HowlAlert Pro Annual</strong> — $35.99/year with a 7-day free trial (save 25%)</li>
      </ul>

      <h2>Free Trial</h2>
      <p>
        Both plans include a 7-day free trial. You will not be charged during the
        trial period. If you do not cancel before the trial ends, your
        subscription will automatically convert to a paid subscription.
      </p>

      <h2>Payment</h2>
      <p>
        Payment will be charged to your Apple ID account at confirmation of
        purchase. Subscription automatically renews unless it is cancelled at
        least 24 hours before the end of the current period. Your account will
        be charged for renewal within 24 hours prior to the end of the current
        period.
      </p>

      <h2>Managing Your Subscription</h2>
      <p>
        You can manage or cancel your subscription at any time in your
        device&apos;s Settings &gt; Apple ID &gt; Subscriptions. Cancellation
        takes effect at the end of the current billing period.
      </p>

      <h2>What You Get</h2>
      <p>HowlAlert Pro unlocks:</p>
      <ul>
        <li>Push notifications (threshold alerts, &quot;Claude is done&quot;)</li>
        <li>Pace math and runout estimates</li>
        <li>Apple Watch complications and haptic alerts</li>
        <li>Dynamic Island Live Activity</li>
        <li>Multi-Mac usage aggregation</li>
        <li>macOS companion app features (menu bar popover, preferences)</li>
      </ul>

      <h2>Without a Subscription</h2>
      <p>
        The macOS app shows a read-only token count in the menu bar. All other
        features require an active Pro subscription on your iPhone.
      </p>

      <h2>Refunds</h2>
      <p>
        Refunds are handled by Apple per their{" "}
        <a href="https://support.apple.com/en-us/HT204084" target="_blank" rel="noopener noreferrer">
          refund policy
        </a>.
      </p>

      <h2>Contact</h2>
      <p>
        Billing questions: <a href="mailto:support@mrdemonwolf.com">support@mrdemonwolf.com</a>
      </p>
      <p className="text-sm text-gray-400 mt-8">&copy; 2026 MrDemonWolf, Inc.</p>
    </article>
  );
}
