"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
	{ href: "/", label: "Overview" },
	{ href: "/config", label: "Config" },
	{ href: "/push-log", label: "Push Log" },
	{ href: "/devices", label: "Devices" },
];

export function Sidebar() {
	const pathname = usePathname();

	return (
		<aside className="flex h-full w-60 flex-col border-r border-navy-lighter bg-navy">
			<div className="flex items-center gap-2 px-6 py-5">
				<div className="flex h-8 w-8 items-center justify-center rounded-lg bg-cyan/15 text-cyan text-lg font-bold">
					W
				</div>
				<span className="text-lg font-semibold text-white">
					HowlAlert
				</span>
			</div>
			<nav className="flex flex-1 flex-col gap-1 px-3 py-2">
				{navItems.map((item) => {
					const isActive =
						pathname === item.href ||
						(item.href !== "/" && pathname.startsWith(item.href));
					return (
						<Link
							key={item.href}
							href={item.href}
							className={`rounded-lg px-3 py-2 text-sm font-medium transition-colors ${
								isActive
									? "bg-navy-lighter text-cyan"
									: "text-gray-400 hover:bg-navy-light hover:text-white"
							}`}
						>
							{item.label}
						</Link>
					);
				})}
			</nav>
		</aside>
	);
}
