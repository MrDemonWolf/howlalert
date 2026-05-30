import { createFromSource } from "fumadocs-core/search/server";

import { source } from "@/lib/source";

// Static export: emit a prebuilt search index (`staticGET`) the client fetches,
// instead of a live search endpoint. Pairs with `search={{ options: { type:
// "static" } }}` on RootProvider.
export const revalidate = false;

export const { staticGET: GET } = createFromSource(source, {
  // https://docs.orama.com/docs/orama-js/supported-languages
  language: "english",
});
