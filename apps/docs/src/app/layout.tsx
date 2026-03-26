import { RootProvider } from "fumadocs-ui/provider";
import "fumadocs-ui/style.css";
import type { ReactNode } from "react";
import type { Metadata } from "next";

export const metadata: Metadata = {
	title: {
		template: "%s | HowlAlert Docs",
		default: "HowlAlert Docs",
	},
	description:
		"Documentation for HowlAlert — Claude Code usage monitor & push notification system for Apple platforms.",
};

export default function RootLayout({ children }: { children: ReactNode }) {
	return (
		<html lang="en" suppressHydrationWarning>
			<body>
				<RootProvider>{children}</RootProvider>
			</body>
		</html>
	);
}
