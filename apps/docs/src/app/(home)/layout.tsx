import Link from "next/link";
import { HomeLayout } from "fumadocs-ui/layouts/home";

import { baseOptions } from "@/lib/layout.shared";
import { repo } from "@/lib/site";

export default function Layout({ children }: LayoutProps<"/">) {
  const currentYear = new Date().getFullYear();
  return (
    <HomeLayout {...baseOptions()}>
      {children}
      <footer
        className="ha-font ha-bg-base"
        style={{ borderTop: "1px solid var(--hairline)" }}
      >
        <div className="mx-auto max-w-6xl px-6 py-10">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
            <p className="text-sm ha-text-2">
              &copy; {currentYear} HowlAlert by{" "}
              <a
                href="https://www.mrdemonwolf.com"
                target="_blank"
                rel="noopener noreferrer"
                className="ha-text-1 hover:underline"
                style={{ textUnderlineOffset: 3 }}
              >
                MrDemonWolf, Inc.
              </a>
            </p>
            <nav className="flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-sm ha-text-2">
              <Link href="/docs" className="hover:ha-text-1 transition-colors">
                Docs
              </Link>
              <Link
                href="/docs/legal/privacy"
                className="hover:ha-text-1 transition-colors"
              >
                Privacy
              </Link>
              <Link
                href="/docs/legal/eula"
                className="hover:ha-text-1 transition-colors"
              >
                EULA
              </Link>
              <a
                href={repo.url}
                target="_blank"
                rel="noopener noreferrer"
                className="hover:ha-text-1 transition-colors"
              >
                GitHub
              </a>
              <a
                href={repo.discord}
                target="_blank"
                rel="noopener noreferrer"
                className="hover:ha-text-1 transition-colors"
              >
                Discord
              </a>
            </nav>
          </div>

          {/* Non-affiliation disclaimer — kept prominent, not buried, because the
              site uses a Claude-warm palette. See COMPLIANCE.md (trademark). */}
          <div
            className="mt-8 pt-6 text-sm leading-relaxed ha-text-2"
            style={{ borderTop: "1px solid var(--hairline)" }}
          >
            <p>
              HowlAlert is an independent, open-source project. It is{" "}
              <strong className="ha-text-1">
                not affiliated with, endorsed by, or sponsored by Anthropic
              </strong>
              . &ldquo;Claude&rdquo; and &ldquo;Claude Code&rdquo; are trademarks
              of Anthropic, PBC. HowlAlert reads your local Claude Code usage
              files on your own Mac and does not connect to Anthropic&rsquo;s
              services.
            </p>
          </div>
        </div>
      </footer>
    </HomeLayout>
  );
}
