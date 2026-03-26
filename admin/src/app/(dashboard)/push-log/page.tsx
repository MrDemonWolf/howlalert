import { Card } from "@/components/ui/card";

export default function PushLogPage() {
	return (
		<div className="space-y-6">
			<h2 className="text-2xl font-semibold text-white">Push Log</h2>

			<Card>
				<div className="overflow-x-auto">
					<table className="w-full text-left text-sm">
						<thead>
							<tr className="border-b border-navy-lighter text-gray-400">
								<th className="pb-3 pr-4 font-medium">Time</th>
								<th className="pb-3 pr-4 font-medium">User</th>
								<th className="pb-3 pr-4 font-medium">Device</th>
								<th className="pb-3 pr-4 font-medium">Title</th>
								<th className="pb-3 font-medium">Status</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td
									colSpan={5}
									className="py-8 text-center text-gray-500"
								>
									No push log entries yet. Push notifications
									will appear here when sent.
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</Card>
		</div>
	);
}
