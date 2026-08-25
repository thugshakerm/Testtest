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

- `styleguide.html` — main style-guide document and interactive laboratories
- `reverse-engineering-wiki.html` — alternate knowledge-base reader
- `src/styles/` — page styles
- `src/scripts/` — application logic and embedded research indexes
- `assets/images/` — deduplicated local revival images
- `assets/manifest.json` — provenance and UI/client categorization
- `scripts/check.mjs` — project integrity check
