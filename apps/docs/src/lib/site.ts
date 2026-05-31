export const siteUrl = "https://mrdemonwolf.github.io/howlalert";

/**
 * GitHub Pages serves this project under `/howlalert`. Keep this resolver in
 * sync with `next.config.mjs` so links and raw asset paths agree.
 * Set NEXT_PUBLIC_BASE_PATH="" to opt out (local dev).
 */
export const basePath = (() => {
  const envValue = process.env.NEXT_PUBLIC_BASE_PATH;
  if (envValue === undefined) return "/howlalert";
  if (envValue === "" || envValue === "/") return "";
  let path = envValue;
  try {
    path = new URL(envValue).pathname;
  } catch {
    // not a URL; treat as a path string
  }
  if (!path || path === "/") return "";
  const normalized = path.startsWith("/") ? path : `/${path}`;
  return normalized.endsWith("/") ? normalized.slice(0, -1) : normalized;
})();

/** Prefix a public asset path (e.g. an `<img src>`) with the base path. */
export function asset(path: string): string {
  const clean = path.startsWith("/") ? path : `/${path}`;
  return `${basePath}${clean}`;
}

export function absoluteUrl(path: string): string {
  const clean = path.startsWith("/") ? path : `/${path}`;
  return `${siteUrl}${clean === "/" ? "" : clean}`;
}

export const repo = {
  owner: "mrdemonwolf",
  name: "howlalert",
  url: "https://github.com/mrdemonwolf/howlalert",
  releases: "https://github.com/mrdemonwolf/howlalert/releases/latest",
  discord: "https://mrdwolf.net/discord",
} as const;

/**
 * Single source of truth for the homepage / root SEO + social-card copy.
 * Change the pitch here once and the page metadata, OG image, and Twitter
 * image all update on the next build.
 */
export const homepageSeo = {
  title: "HowlAlert. Watch your Claude Code usage on Mac, iPhone & Watch",
  description:
    "A tiny Mac menu bar app that watches your Claude Code usage and warns you before the 5-hour limit runs out. Local, private, open source. macOS 26+.",
  socialDescription:
    "Know when Claude Code runs out — before it does. A menu bar app that watches your 5-hour window and warns you in time.",
  ogEyebrow: "For Claude Code · macOS 26+",
  ogTitle: "Know when Claude Code runs out.",
  ogAccentWord: "runs out.",
  ogCardDescription:
    "A tiny Mac menu bar app that watches your 5-hour usage window and warns you before you hit the limit.",
  ogChips: ["5-hour window", "Auto-detected limit", "Local & private", "Open source"],
  ogImageAlt:
    "HowlAlert. A macOS menu bar app showing the Claude Code 5-hour usage window with time remaining.",
  keywords: [
    "claude code usage monitor mac",
    "claude code 5 hour limit",
    "claude code usage menu bar app",
    "claude code rate limit warning",
    "claude code usage tracker apple watch",
    "macos menu bar claude usage",
  ],
} as const;
