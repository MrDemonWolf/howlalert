import { Hono } from "hono";
import type { Bindings } from "../lib/bindings";

const app = new Hono<{ Bindings: Bindings }>();

app.get("/health", (c) => {
  return c.json({ ok: true, version: "2.0.0" });
});

export default app;
