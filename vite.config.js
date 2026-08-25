import { defineConfig } from 'vite'
export default defineConfig({ server: { host: '0.0.0.0', allowedHosts: true }, build: { rollupOptions: { input: { index: 'index.html', styleguide: 'styleguide.html', wiki: 'reverse-engineering-wiki.html', toolkit: 'toolkit.html' } } } })
