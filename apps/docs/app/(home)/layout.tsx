import type { ReactNode } from "react";
import { HomeLayout } from "fumadocs-ui/layouts/home";
import { baseOptions } from "@/lib/layout.shared";
import Link from "next/link";

export default function Layout({ children }: { children: ReactNode }) {
	return (
		<HomeLayout {...baseOptions()}>
			{children}
			<footer className="border-t px-8 py-8 mt-auto">
				<div className="max-w-5xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-fd-muted-foreground">
					<span>&copy; 2026 MrDemonWolf. All rights reserved.</span>
					<div className="flex gap-6">
						<Link
							href="/docs/legal/privacy-policy"
							className="hover:text-fd-foreground transition-colors"
						>
							Privacy Policy
						</Link>
						<Link
							href="/docs/legal/terms-of-service"
							className="hover:text-fd-foreground transition-colors"
						>
							Terms of Service
						</Link>
						<Link
							href="https://github.com/mrdemonwolf/howlalert"
							target="_blank"
							rel="noopener noreferrer"
							className="hover:text-fd-foreground transition-colors"
						>
							GitHub
						</Link>
					</div>
				</div>
			</footer>
		</HomeLayout>
	);
}
