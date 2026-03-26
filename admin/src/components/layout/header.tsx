import { Badge } from "@/components/ui/badge";

export function Header() {
	return (
		<header className="flex h-14 items-center justify-between border-b border-navy-lighter bg-navy px-6">
			<h1 className="text-sm font-medium text-gray-400">
				Admin Dashboard
			</h1>
			<div className="flex items-center gap-3">
				<Badge variant="cyan">1x Multiplier</Badge>
			</div>
		</header>
	);
}
