import type { ReactElement, ReactNode } from "react";

// ── Palette (Claude-warm, light) ──────────────────────────────
const BG = "#FAF9F5";
const BG_RAISED = "#FFFFFF";
const SURFACE = "#F0EEE6";
const HAIRLINE = "#E4DFD4";
const BRAND = "#D97757"; // coral
const BRAND_HI = "#C15F3C"; // darker coral — text/accent on cream
const WARN = "#E0922F";
const TXT_1 = "#1F1E1D";
const TXT_2 = "#6B6862";

/** Lucide "activity" pulse line, white, as a data URI for the wordmark glyph. */
const PULSE_GLYPH = `data:image/svg+xml;utf8,${encodeURIComponent(
  `<svg xmlns='http://www.w3.org/2000/svg' width='30' height='30' viewBox='0 0 24 24' fill='none' stroke='%23ffffff' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round'><path d='M22 12h-4l-3 9L9 3l-3 9H2'/></svg>`,
)}`;

/** Subtle dot-grid texture (warm). */
const DOT_GRID = `url("data:image/svg+xml;utf8,${encodeURIComponent(
  `<svg xmlns='http://www.w3.org/2000/svg' width='40' height='40'><circle cx='1' cy='1' r='1' fill='%231F1E1D' fill-opacity='0.04'/></svg>`,
)}")`;

function Wordmark(): ReactElement {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          width: 44,
          height: 44,
          borderRadius: 12,
          background: BRAND,
          boxShadow: `0 10px 24px -8px ${BRAND}99`,
        }}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={PULSE_GLYPH} width={26} height={26} alt="" />
      </div>
      <div
        style={{
          display: "flex",
          fontFamily: "Bricolage Grotesque",
          fontSize: 36,
          fontWeight: 600,
          color: TXT_1,
          letterSpacing: -1,
        }}
      >
        HowlAlert
      </div>
    </div>
  );
}

function Frame({ tag, children }: { tag: string; children: ReactNode }): ReactElement {
  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        background: BG,
        position: "relative",
        fontFamily: "Geist",
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: `linear-gradient(160deg, ${BG_RAISED} 0%, ${BG} 55%)`,
          display: "flex",
        }}
      />
      <div style={{ position: "absolute", inset: 0, backgroundImage: DOT_GRID, backgroundRepeat: "repeat", display: "flex" }} />
      <div
        style={{
          position: "absolute",
          top: -320,
          left: -280,
          width: 920,
          height: 920,
          background: `radial-gradient(circle, ${BRAND}33 0%, ${BRAND}00 55%)`,
          display: "flex",
        }}
      />
      <div
        style={{
          position: "absolute",
          bottom: -360,
          right: -220,
          width: 860,
          height: 860,
          background: `radial-gradient(circle, ${WARN}26 0%, ${WARN}00 58%)`,
          display: "flex",
        }}
      />
      <div style={{ position: "absolute", inset: 22, border: `1px solid ${HAIRLINE}`, borderRadius: 30, display: "flex" }} />

      <div
        style={{
          position: "relative",
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          padding: "56px 64px 0",
        }}
      >
        <Wordmark />
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 10,
            fontFamily: "Geist Mono",
            fontSize: 16,
            color: TXT_2,
            letterSpacing: 0.4,
          }}
        >
          <div style={{ display: "flex", width: 7, height: 7, borderRadius: 999, background: BRAND }} />
          <span style={{ display: "flex" }}>{tag}</span>
        </div>
      </div>

      <div style={{ position: "relative", display: "flex", flex: 1, padding: "40px 64px 56px" }}>{children}</div>
    </div>
  );
}

function Eyebrow({ text }: { text: string }): ReactElement {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        alignSelf: "flex-start",
        gap: 12,
        padding: "9px 20px 9px 15px",
        borderRadius: 999,
        background: `${BRAND}1F`,
        border: `1px solid ${BRAND}55`,
        color: BRAND_HI,
        fontSize: 21,
        fontWeight: 500,
        letterSpacing: -0.2,
      }}
    >
      <div style={{ display: "flex", width: 10, height: 10, borderRadius: 999, background: BRAND }} />
      <span style={{ display: "flex" }}>{text}</span>
    </div>
  );
}

/** Usage-gauge proof tile — mirrors the live menu-bar popover. */
function GaugeTile(): ReactElement {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        width: 372,
        gap: 20,
        padding: 28,
        borderRadius: 26,
        background: BG_RAISED,
        border: `1px solid ${HAIRLINE}`,
        boxShadow: "0 30px 80px -34px rgba(60,40,20,0.45)",
      }}
    >
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              width: 34,
              height: 34,
              borderRadius: 9,
              background: `${BRAND}24`,
            }}
          >
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={`data:image/svg+xml;utf8,${encodeURIComponent(
                `<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='%23D97757' stroke-width='2.2' stroke-linecap='round' stroke-linejoin='round'><path d='M22 12h-4l-3 9L9 3l-3 9H2'/></svg>`,
              )}`}
              width={20}
              height={20}
              alt=""
            />
          </div>
          <span style={{ display: "flex", fontSize: 20, fontWeight: 600, color: TXT_1 }}>HowlAlert</span>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 8, fontSize: 16, color: TXT_2 }}>
          <div style={{ display: "flex", width: 9, height: 9, borderRadius: 999, background: WARN }} />
          <span style={{ display: "flex" }}>Watching</span>
        </div>
      </div>

      <div style={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between" }}>
        <div style={{ display: "flex", alignItems: "flex-end", fontFamily: "Bricolage Grotesque", color: TXT_1 }}>
          <span style={{ display: "flex", fontSize: 64, fontWeight: 600, lineHeight: 1 }}>84</span>
          <span style={{ display: "flex", fontSize: 30, color: TXT_2, marginBottom: 6 }}>%</span>
        </div>
        <span style={{ display: "flex", fontSize: 19, fontWeight: 600, color: WARN }}>Runs out in 47m</span>
      </div>
      <span style={{ display: "flex", fontSize: 15, color: TXT_2, marginTop: -8 }}>5-hour window · resets 3:20 PM</span>

      <div style={{ display: "flex", height: 12, borderRadius: 999, background: SURFACE }}>
        <div style={{ display: "flex", width: "84%", height: 12, borderRadius: 999, background: `linear-gradient(90deg, ${BRAND}, ${WARN})` }} />
      </div>

      <div style={{ display: "flex", height: 1, background: HAIRLINE }} />
      <div style={{ display: "flex", justifyContent: "space-between", fontSize: 15, color: TXT_2 }}>
        <span style={{ display: "flex" }}>Limit auto-detected · P90</span>
        <span style={{ display: "flex", fontFamily: "Geist Mono", color: TXT_1 }}>Sonnet · Opus</span>
      </div>
    </div>
  );
}

function splitAccent(title: string, accentWord?: string): [string, string, string] {
  if (!accentWord) return [title, "", ""];
  const idx = title.toLowerCase().indexOf(accentWord.toLowerCase());
  if (idx === -1) return [title, "", ""];
  return [title.slice(0, idx), title.slice(idx, idx + accentWord.length), title.slice(idx + accentWord.length)];
}

export interface OgCardProps {
  title: string;
  description?: string;
  eyebrow?: string;
  chips?: string[];
  accentWord?: string;
}

export function OgCard({ title, description, eyebrow, chips, accentWord }: OgCardProps): ReactElement {
  const [before, accent, after] = splitAccent(title, accentWord);

  return (
    <Frame tag="macOS · local · open source">
      <div style={{ display: "flex", width: "100%", justifyContent: "space-between", alignItems: "center", gap: 56 }}>
        <div style={{ display: "flex", flexDirection: "column", flex: 1, justifyContent: "center" }}>
          {eyebrow ? <Eyebrow text={eyebrow} /> : null}

          <div
            style={{
              display: "flex",
              flexWrap: "wrap",
              marginTop: eyebrow ? 24 : 0,
              fontFamily: "Bricolage Grotesque",
              fontSize: 62,
              lineHeight: 1.05,
              color: TXT_1,
              fontWeight: 600,
              letterSpacing: -1.3,
              maxWidth: 580,
            }}
          >
            <span style={{ display: "flex" }}>{before}</span>
            {accent ? <span style={{ display: "flex", color: BRAND_HI, fontWeight: 600 }}>{accent}</span> : null}
            {after ? <span style={{ display: "flex" }}>{after}</span> : null}
          </div>

          {description ? (
            <div style={{ display: "flex", marginTop: 22, fontSize: 24, lineHeight: 1.35, color: TXT_2, letterSpacing: -0.3, maxWidth: 560 }}>
              {description}
            </div>
          ) : null}

          {chips && chips.length > 0 ? (
            <div style={{ display: "flex", gap: 10, flexWrap: "wrap", marginTop: 26, maxWidth: 600 }}>
              {chips.slice(0, 3).map((c) => (
                <div
                  key={c}
                  style={{
                    display: "flex",
                    padding: "8px 18px",
                    borderRadius: 999,
                    background: SURFACE,
                    border: `1px solid ${HAIRLINE}`,
                    color: TXT_1,
                    fontSize: 20,
                    fontWeight: 500,
                    letterSpacing: -0.2,
                  }}
                >
                  {c}
                </div>
              ))}
            </div>
          ) : null}
        </div>

        <GaugeTile />
      </div>
    </Frame>
  );
}

export const OG_SIZE = { width: 1200, height: 630 } as const;
export const OG_CONTENT_TYPE = "image/png" as const;

async function loadFont(
  family: string,
  weights: number[],
): Promise<{ name: string; data: ArrayBuffer; weight: number; style: "normal" | "italic" }[]> {
  const results: { name: string; data: ArrayBuffer; weight: number; style: "normal" | "italic" }[] = [];
  for (const weight of weights) {
    const url = `https://fonts.googleapis.com/css2?family=${family.replace(/ /g, "+")}:wght@${weight}&display=swap`;
    const css = await fetch(url, { headers: { "User-Agent": "Mozilla/5.0" } }).then((r) => r.text());
    const match = css.match(/src:\s*url\(([^)]+)\)\s*format\('(?:truetype|woff2?)'\)/);
    if (!match) continue;
    const fontData = await fetch(match[1]).then((r) => r.arrayBuffer());
    results.push({ name: family, data: fontData, weight, style: "normal" });
  }
  return results;
}

export async function loadOgFonts() {
  const [display, body, mono] = await Promise.all([
    loadFont("Bricolage Grotesque", [600]),
    loadFont("Geist", [400, 500]),
    loadFont("Geist Mono", [400]),
  ]);
  return [...display, ...body, ...mono];
}
