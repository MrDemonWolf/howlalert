import type { BaseLayoutProps } from "fumadocs-ui/layouts/shared";
import { appName, gitConfig } from "./shared";

export function baseOptions(): BaseLayoutProps {
  return {
    nav: {
      title: appName,
    },
    githubUrl: `https://github.com/${gitConfig.user}/${gitConfig.repo}`,
    links: [
      { text: "Docs", url: "/docs" },
      { text: "Privacy", url: "/legal/privacy" },
      { text: "Terms", url: "/legal/terms" },
    ],
  };
}
