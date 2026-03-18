import type { BaseLayoutProps } from "fumadocs-ui/layouts/shared";

export function baseOptions(): BaseLayoutProps {
	return {
		nav: {
			title: "HowlAlert",
			url: "/",
			transparentMode: "top",
		},
		githubUrl: "https://github.com/mrdemonwolf/howlalert",
		links: [
			{ text: "Docs", url: "/docs" },
			{
				text: "App Store",
				url: "https://apps.apple.com/us/app/howlalert/id6760729438",
			},
		],
	};
}
