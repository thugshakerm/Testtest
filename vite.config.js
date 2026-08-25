import { defineConfig } from 'vite'
import { readFileSync, existsSync } from 'node:fs'
import { resolve } from 'node:path'

const cleanRoutes = ['/toolkit', '/styleguide', '/wiki', '/viewer']

function sourceCompatibleRoutes() {
  return {
    name: 'source-compatible-routes-and-css',
    enforce: 'pre',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        const requestPath = (req.url || '').split('?')[0]
        if (requestPath.startsWith('/src/styles/') && requestPath.endsWith('.css')) {
          const file = resolve(process.cwd(), requestPath.slice(1))
          if (existsSync(file)) {
            res.statusCode = 200
            res.setHeader('Content-Type', 'text/css; charset=utf-8')
            res.setHeader('Cache-Control', 'no-store')
            return res.end(readFileSync(file))
          }
        }
        if (cleanRoutes.includes(requestPath)) {
          res.statusCode = 302
          res.setHeader('Location', `${requestPath}/`)
          return res.end()
        }
        next()
      })
    },
    configurePreviewServer(server) {
      server.middlewares.use((req, res, next) => {
        const requestPath = (req.url || '').split('?')[0]
        if (cleanRoutes.includes(requestPath)) {
          res.statusCode = 302
          res.setHeader('Location', `${requestPath}/`)
          return res.end()
        }
        next()
      })
    }
  }
}

export default defineConfig({
  plugins: [sourceCompatibleRoutes()],
  server: { host: '0.0.0.0', allowedHosts: true },
  build: {
    rollupOptions: {
      input: {
        index: 'index.html',
        styleguide: 'styleguide/index.html',
        wiki: 'wiki/index.html',
        toolkit: 'toolkit/index.html',
        viewer: 'viewer/index.html'
      }
    }
  }
})
