#!/usr/bin/env node
// scripts/appcast-append.mjs
//
// Appends a Sparkle <item> entry to distribution/appcast.xml. The release
// workflow calls this with the DMG, version, and EdDSA signature. We use the
// DOM directly so the existing file (and any prior entries) is preserved.

import { readFileSync, writeFileSync, statSync } from "node:fs";
import { argv } from "node:process";

function arg(flag, fallback) {
  const i = argv.indexOf(flag);
  if (i === -1) return fallback;
  return argv[i + 1];
}

const version = arg("--version");
const dmg = arg("--dmg");
const signature = arg("--signature");
const appcast = arg("--appcast");

if (!version || !dmg || !signature || !appcast) {
  console.error("usage: appcast-append.mjs --version X --dmg path --signature SIG --appcast path");
  process.exit(2);
}

const length = statSync(dmg).size;
const fileName = dmg.split("/").pop();
const url = `https://github.com/mrdemonwolf/howlalert/releases/download/v${version}/${fileName}`;
const pubDate = new Date().toUTCString();

const item = `    <item>
      <title>HowlAlert ${version}</title>
      <pubDate>${pubDate}</pubDate>
      <sparkle:version>${version}</sparkle:version>
      <sparkle:shortVersionString>${version}</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>26.0</sparkle:minimumSystemVersion>
      <enclosure
        url="${url}"
        sparkle:edSignature="${signature}"
        length="${length}"
        type="application/octet-stream" />
    </item>
`;

const original = readFileSync(appcast, "utf8");
const updated = original.replace(
  /<!-- Release workflow appends <item> entries per build\. -->/,
  `<!-- Release workflow appends <item> entries per build. -->\n${item}`
);
writeFileSync(appcast, updated);
console.log(`appended item for ${version} → ${appcast}`);
