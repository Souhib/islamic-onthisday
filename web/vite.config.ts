import path from "node:path";
import { readFileSync } from "node:fs";
import { TanStackRouterVite } from "@tanstack/router-plugin/vite";
import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

const pkg = JSON.parse(readFileSync(new URL("./package.json", import.meta.url), "utf8")) as {
  version: string;
};

export default defineConfig({
  esbuild: { drop: ["console", "debugger"] },
  define: {
    // Surface the package version to the bundle so `Footer` can show it
    // without anyone having to remember to bump a hardcoded constant.
    "import.meta.env.VITE_APP_VERSION": JSON.stringify(pkg.version),
  },
  plugins: [
    TanStackRouterVite({
      routesDirectory: "./src/routes",
      generatedRouteTree: "./src/routeTree.gen.ts",
      routeFileIgnorePrefix: "-",
      autoCodeSplitting: true,
    }),
    react(),
    tailwindcss(),
  ],
  resolve: {
    alias: { "@": path.resolve(import.meta.dirname, "./src") },
  },
  server: {
    port: 3000,
    host: true,
    proxy: {
      "/api": { target: "http://127.0.0.1:5111", changeOrigin: true },
    },
  },
  build: {
    target: "es2020",
    chunkSizeWarningLimit: 800,
    sourcemap: false,
    rollupOptions: {
      output: {
        // Vendor splitting — keeps each released chunk small enough that
        // editorial copy edits don't bust the cache for React/router code.
        manualChunks(id) {
          if (!id.includes("node_modules")) return;
          if (id.includes("/react/") || id.includes("/react-dom/")) return "react-vendor";
          if (id.includes("@tanstack/react-router") || id.includes("@tanstack/react-query")) return "router-vendor";
          if (id.includes("@radix-ui")) return "radix";
          if (id.includes("i18next")) return "i18n";
        },
      },
    },
  },
});
