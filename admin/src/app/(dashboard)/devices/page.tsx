import { Card } from "@/components/ui/card";

export default function DevicesPage() {
	return (
		<div className="space-y-6">
			<h2 className="text-2xl font-semibold text-white">Devices</h2>

			<Card>
				<div className="space-y-4">
					<div className="overflow-x-auto">
						<table className="w-full text-left text-sm">
							<thead>
								<tr className="border-b border-navy-lighter text-gray-400">
									<th className="pb-3 pr-4 font-medium">Platform</th>
									<th className="pb-3 pr-4 font-medium">User</th>
									<th className="pb-3 pr-4 font-medium">App Version</th>
									<th className="pb-3 pr-4 font-medium">Registered</th>
									<th className="pb-3 font-medium">Last Seen</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td
										colSpan={5}
										className="py-8 text-center text-gray-500"
									>
										No devices registered yet. Devices will
										appear here when users install the app.
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</Card>
		</div>
	);
}
