# ORC Design and Research Atlas

A structured Vite project containing the revival design style guide, a redesigned Roblox Reverse Engineering Wiki reader, a client/RCCService compatibility registry, and a content-addressed revival image archive.

## Development

```bash
npm install
npm run dev
```

## Validation and production build

```bash
npm run check
npm run build
npm run preview
```

### Structure

- `/` (`index.html`) — creator-focused landing page
- `/toolkit` — local RCC/SOAP workbench and project planner
- `/viewer` — VS Code-style local HTML editor and live preview
- `/styleguide` — main style-guide document and interactive laboratories
- `/wiki` — alternate knowledge-base reader
- `src/styles/` — shared page styles
- `src/scripts/` — application logic and embedded research indexes
- `assets/images/` — deduplicated local revival images
- `assets/manifest.json` — provenance and UI/client categorization
- `scripts/check.mjs` — project integrity check
