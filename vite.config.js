import { defineConfig } from 'vite'

const cleanRoutes = ['/toolkit', '/styleguide', '/wiki']

export default defineConfig({
  plugins: [{
    name: 'extensionless-directory-routes',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        const path = (req.url || '').split('?')[0]
        if (cleanRoutes.includes(path)) {
          res.statusCode = 302
          res.setHeader('Location', `${path}/${(req.url || '').includes('?') ? `?${(req.url || '').split('?')[1]}` : ''}`)
          return res.end()
        }
        next()
      })
    },
    configurePreviewServer(server) {
      server.middlewares.use((req, res, next) => {
        const path = (req.url || '').split('?')[0]
        if (cleanRoutes.includes(path)) {
          res.statusCode = 302
          res.setHeader('Location', `${path}/`)
          return res.end()
        }
        next()
      })
    }
  }],
  server: { host: '0.0.0.0', allowedHosts: true },
  build: {
    rollupOptions: {
      input: {
        index: 'index.html',
        styleguide: 'styleguide/index.html',
        wiki: 'wiki/index.html',
        toolkit: 'toolkit/index.html'
      }
    }
  }
})
