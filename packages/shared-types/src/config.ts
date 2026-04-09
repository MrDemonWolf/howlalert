export interface LimitConfig {
  /** Token limit for the current billing period */
  planLimit: number;
  /** Fraction of limit at which warning notifications are sent (0–1) */
  warningThreshold: number;
  /** Fraction of limit at which critical notifications are sent (0–1) */
  criticalThreshold: number;
}

export interface PromoConfig {
  /** Promo multiplier applied to the plan limit (e.g. 5 for 5x promo) */
  multiplier: number;
  /** ISO 8601 expiry date for the promo period */
  expiresAt: string;
}

export interface PlanLimits {
  /** Base token limit without any promo */
  base: number;
  /** Effective limit after applying promo multiplier */
  effective: number;
  promo?: PromoConfig;
}

export interface RemoteConfig {
  limits: LimitConfig;
  promo?: PromoConfig;
  /** Override effective plan limit (admin use only) */
  planLimitOverride?: number;
  updatedAt: string;
}
