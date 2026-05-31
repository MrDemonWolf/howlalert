import { Activity } from "lucide-react";

/**
 * Static product visual for the hero — a mock of the HowlAlert menu-bar
 * popover. Purely presentational so it renders under static export with no
 * client JS. The numbers are illustrative, not live.
 */
export function UsageGauge() {
  const used = 84; // percent of the 5-hour window consumed (warn band)

  return (
    <div
      className="ha-glass ha-font"
      style={{ width: "min(92vw, 360px)", padding: "1.25rem" }}
      role="img"
      aria-label="HowlAlert menu bar popover: 84% of the 5-hour window used, runs out in 47 minutes."
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <span
            className="inline-flex items-center justify-center"
            style={{
              width: "1.7rem",
              height: "1.7rem",
              borderRadius: "8px",
              backgroundColor: "var(--brand-50)",
              color: "var(--brand-500)",
            }}
          >
            <Activity className="w-4 h-4" aria-hidden="true" />
          </span>
          <span className="ha-text-1 font-semibold text-sm">HowlAlert</span>
        </div>
        <span className="inline-flex items-center gap-1.5 text-xs ha-text-2">
          <span
            className="inline-block w-2 h-2 rounded-full"
            style={{ backgroundColor: "var(--state-warn)" }}
          />
          Watching
        </span>
      </div>

      {/* Primary stat */}
      <div className="flex items-end justify-between mb-1">
        <span
          className="ha-display"
          style={{ fontSize: "2.6rem", lineHeight: 1, color: "var(--txt-1)" }}
        >
          84<span style={{ fontSize: "1.4rem", color: "var(--txt-2)" }}>%</span>
        </span>
        <span
          className="text-sm font-semibold"
          style={{ color: "var(--state-warn)" }}
        >
          Runs out in 47m
        </span>
      </div>
      <p className="text-xs ha-text-2 mb-3">5-hour window · resets 3:20 PM</p>

      {/* Progress bar */}
      <div
        style={{
          height: "10px",
          borderRadius: "999px",
          backgroundColor: "var(--bg-surface)",
          overflow: "hidden",
        }}
      >
        <div
          className="ha-pulse-ring"
          style={{
            width: `${used}%`,
            height: "100%",
            borderRadius: "999px",
            background:
              "linear-gradient(90deg, var(--brand-500), var(--state-warn))",
          }}
        />
      </div>

      {/* Used vs reserve — what you've spent and what's left */}
      <div className="mt-3 grid grid-cols-2 gap-2">
        <div
          style={{
            borderRadius: "10px",
            padding: "0.5rem 0.7rem",
            backgroundColor: "var(--bg-surface)",
          }}
        >
          <p className="text-[0.65rem] uppercase tracking-wide ha-text-2">Used</p>
          <p className="text-sm font-semibold ha-text-1">84% · 4h 13m</p>
        </div>
        <div
          style={{
            borderRadius: "10px",
            padding: "0.5rem 0.7rem",
            backgroundColor: "var(--brand-50)",
          }}
        >
          <p className="text-[0.65rem] uppercase tracking-wide ha-text-2">Reserve</p>
          <p className="text-sm font-semibold" style={{ color: "var(--brand-600)" }}>
            16% · 47m
          </p>
        </div>
      </div>

      {/* Per-model footnote */}
      <div
        className="mt-3 pt-3 flex items-center justify-between text-xs"
        style={{ borderTop: "1px solid var(--hairline)" }}
      >
        <span className="ha-text-2">Limit auto-detected · P90</span>
        <span className="ha-mono ha-text-1">Sonnet · Opus</span>
      </div>
    </div>
  );
}
