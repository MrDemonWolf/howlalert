import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

export const users = sqliteTable("users", {
  cloudkitUserId: text("cloudkit_user_id").primaryKey(),
  rcAppUserId: text("rc_app_user_id"),
  entitlementActive: integer("entitlement_active", { mode: "boolean" })
    .notNull()
    .default(false),
  expiresAt: integer("expires_at", { mode: "timestamp" }),
  updatedAt: integer("updated_at", { mode: "timestamp" })
    .notNull()
    .$defaultFn(() => new Date()),
});

export const pushLog = sqliteTable("push_log", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  cloudkitUserId: text("cloudkit_user_id").notNull(),
  kind: text("kind").notNull(), // "threshold" | "done" | "reset"
  sourceDeviceName: text("source_device_name"),
  createdAt: integer("created_at", { mode: "timestamp" })
    .notNull()
    .$defaultFn(() => new Date()),
});
