import { defineConfig } from "vitest/config";
import path from "path";
import { fileURLToPath } from "url";

// Config propia del repo — sin esto, Vitest sube directorios y encuentra
// el vitest.config.ts de otro proyecto en "TAAW V8 ANTIGRAVITY/".
const dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  test: {
    environment: "node",
  },
  resolve: {
    alias: {
      "@": path.resolve(dirname, "./src"),
    },
  },
});
