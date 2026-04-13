import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import type { Bindings } from "./lib/bindings";

import health from "./routes/health";
import register from "./routes/register";
import push from "./routes/push";
import entitlement from "./routes/entitlement";
import admin from "./routes/admin";

const app = new Hono<{ Bindings: Bindings }>();

app.use(logger());
app.use(
  "/*",
  cors({
    origin: "*",
    allowMethods: ["GET", "POST", "OPTIONS"],
  })
);

app.route("/", health);
app.route("/", register);
app.route("/", push);
app.route("/", entitlement);
app.route("/", admin);

export default app;
