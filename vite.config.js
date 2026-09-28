import { resolve, relative, extname } from 'path'
import { readdirSync, statSync } from 'fs'
import { defineConfig } from 'vite'

function getHtmlEntries(dir, baseDir = dir) {
  const entries = {}
  const items = readdirSync(dir)
  for (const item of items) {
    if (item === 'node_modules' || item === 'dist' || item === 'public' || item.startsWith('.')) continue
    const fullPath = resolve(dir, item)
    const stat = statSync(fullPath)
    if (stat.isDirectory()) {
      Object.assign(entries, getHtmlEntries(fullPath, baseDir))
    } else if (extname(item) === '.html') {
      const rel = relative(baseDir, fullPath).replace(/\.html$/, '').replace(/[\/\\]/g, '_')
      const key = rel === 'index' ? 'main' : rel
      entries[key] = fullPath
    }
  }
  return entries
}

export default defineConfig({
  build: {
    rollupOptions: {
      input: getHtmlEntries(__dirname),
    },
  },
})
