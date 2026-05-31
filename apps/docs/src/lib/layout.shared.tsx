import type { BaseLayoutProps } from "fumadocs-ui/layouts/shared";

import { appName, gitConfig } from "./shared";
import { asset } from "./site";

export function baseOptions(): BaseLayoutProps {
  return {
    nav: {
      title: (
        <span className="inline-flex items-center gap-2">
          <img
            src={asset("/howlalert-wolf-brand.svg")}
            alt=""
            width={26}
            height={26}
            aria-hidden="true"
          />
          <span className="ha-display font-semibold text-[1.05rem] ha-text-1">
            {appName}
          </span>
        </span>
      ),
    },
    links: [
      { text: "Docs", url: "/docs" },
      { text: "Download", url: "/download" },
    ],
    githubUrl: `https://github.com/${gitConfig.user}/${gitConfig.repo}`,
  };
}
