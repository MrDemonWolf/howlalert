import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import type { Env } from "./types";
import { configRoutes } from "./routes/config";
import { pushRoutes } from "./routes/push";
import { pushLogRoutes } from "./routes/push-log";

const app = new Hono<{ Bindings: Env }>();

app.use("*", logger());
app.use("*", cors());

app.get("/status", (c) => c.json({ status: "ok", service: "howlalert-worker" }));

app.route("/", configRoutes);
app.route("/", pushRoutes);
app.route("/", pushLogRoutes);

export default app;
