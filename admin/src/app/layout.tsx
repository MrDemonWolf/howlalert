import type { Metadata } from "next";
import "@/styles/globals.css";

export const metadata: Metadata = {
	title: "HowlAlert Admin",
	description: "HowlAlert Admin Dashboard",
};

export default function RootLayout({
	children,
}: {
	children: React.ReactNode;
}) {
	return (
		<html lang="en" className="dark">
			<body
				className="min-h-screen bg-navy text-white antialiased"
				style={{
					fontFamily:
						'-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
				}}
			>
				{children}
			</body>
		</html>
	);
}
