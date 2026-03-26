import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export default function OverviewPage() {
	return (
		<div className="space-y-6">
			<h2 className="text-2xl font-semibold text-white">Overview</h2>
			<div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
				<Card>
					<div className="space-y-2">
						<p className="text-sm text-gray-400">
							Multiplier Status
						</p>
						<div className="flex items-center gap-2">
							<span className="text-3xl font-bold text-white">
								1x
							</span>
							<Badge variant="green">Active</Badge>
						</div>
						<p className="text-xs text-gray-500">
							Standard rate limiting applied
						</p>
					</div>
				</Card>

				<Card>
					<div className="space-y-2">
						<p className="text-sm text-gray-400">
							Crit Bar Preview
						</p>
						<div className="space-y-1.5">
							<div className="flex items-center gap-2 text-xs">
								<span className="h-2 w-2 rounded-full bg-green" />
								<span className="text-gray-400">Normal</span>
								<span className="text-gray-500">0-60%</span>
							</div>
							<div className="flex items-center gap-2 text-xs">
								<span className="h-2 w-2 rounded-full bg-amber" />
								<span className="text-gray-400">Warning</span>
								<span className="text-gray-500">60-85%</span>
							</div>
							<div className="flex items-center gap-2 text-xs">
								<span className="h-2 w-2 rounded-full bg-red" />
								<span className="text-gray-400">Critical</span>
								<span className="text-gray-500">85-100%</span>
							</div>
						</div>
					</div>
				</Card>

				<Card>
					<div className="space-y-2">
						<p className="text-sm text-gray-400">
							Push Count Today
						</p>
						<span className="text-3xl font-bold text-white">
							0
						</span>
						<p className="text-xs text-gray-500">
							No push notifications sent today
						</p>
					</div>
				</Card>
			</div>
		</div>
	);
}
