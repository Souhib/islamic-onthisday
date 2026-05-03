/// <reference types="vite/client" />

// Augment ImportMeta with the env vars we inject ourselves so TypeScript
// stops needing the per-callsite cast. `VITE_API_URL` is read by the
// generated client setup; `VITE_APP_VERSION` is injected from
// `package.json` at build time (see vite.config.ts `define`).
interface ImportMetaEnv {
  readonly VITE_API_URL?: string;
  readonly VITE_APP_VERSION?: string;
  readonly VITE_SENTRY_DSN?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
