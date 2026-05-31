import { ImageResponse } from "next/og";

import { homepageSeo } from "@/lib/site";
import { OG_CONTENT_TYPE, OG_SIZE, OgCard, loadOgFonts } from "./og/_components/og-card";

export const alt = homepageSeo.ogImageAlt;
export const size = OG_SIZE;
export const contentType = OG_CONTENT_TYPE;
export const dynamic = "force-static";
export const revalidate = false;

export default async function Image() {
  const fonts = await loadOgFonts();
  return new ImageResponse(
    (
      <OgCard
        eyebrow={homepageSeo.ogEyebrow}
        title={homepageSeo.ogTitle}
        accentWord={homepageSeo.ogAccentWord}
        description={homepageSeo.ogCardDescription}
        chips={[...homepageSeo.ogChips]}
      />
    ),
    {
      ...size,
      fonts: fonts.map((f) => ({
        name: f.name,
        data: f.data,
        weight: f.weight as 400 | 500 | 600,
        style: f.style,
      })),
    },
  );
}
