import { Hono } from "hono";

const VERSION = "0.0.0";

type Bindings = Record<string, never>;

const app = new Hono<{ Bindings: Bindings }>();

app.get("/health", (c) => c.json({ status: "ok", version: VERSION }));

app.get("/", (c) => c.text("HowlAlert worker — see /health"));

export default app;
