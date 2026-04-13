import { z } from "zod";

export const registerSchema = z.object({
  deviceToken: z.string().min(1),
  cloudkitUserId: z.string().min(1),
  deviceName: z.string().min(1),
  platform: z.enum(["ios", "watchos"]),
});

export const pushSchema = z.object({
  deviceToken: z.string().min(1),
  cloudkitUserId: z.string().min(1),
  sourceDeviceName: z.string().min(1),
  usage: z.number().nonnegative(),
  pace: z.number(),
  windowEnd: z.string().datetime(),
  kind: z.enum(["threshold", "done", "reset"]),
});

export const entitlementSyncSchema = z.object({
  api_version: z.string().optional(),
  event: z.object({
    type: z.string(),
    app_user_id: z.string(),
    entitlement_ids: z.array(z.string()).optional(),
    expiration_at_ms: z.number().optional(),
    product_id: z.string().optional(),
  }),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type PushInput = z.infer<typeof pushSchema>;
export type EntitlementSyncInput = z.infer<typeof entitlementSyncSchema>;
