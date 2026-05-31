"use client";

import { Check, Copy } from "lucide-react";
import { useState } from "react";

export function CopyButton({ value, label }: { value: string; label: string }) {
  const [copied, setCopied] = useState(false);

  return (
    <button
      type="button"
      onClick={() => {
        navigator.clipboard.writeText(value).then(() => {
          setCopied(true);
          setTimeout(() => setCopied(false), 1800);
        });
      }}
      className="ha-pill"
      style={{ cursor: "pointer" }}
      aria-label={label}
    >
      {copied ? (
        <Check className="w-3.5 h-3.5" style={{ color: "var(--state-fresh)" }} />
      ) : (
        <Copy className="w-3.5 h-3.5" />
      )}
      {copied ? "Copied" : label}
    </button>
  );
}
