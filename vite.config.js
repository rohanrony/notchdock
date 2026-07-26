import { resolve } from 'path'
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        privacy: resolve(__dirname, 'privacy.html'),
        sports: resolve(__dirname, 'features/mac-sports-tracker.html'),
        stocks: resolve(__dirname, 'features/mac-stock-portfolio.html'),
        pomodoro: resolve(__dirname, 'features/mac-pomodoro-notes.html'),
        media: resolve(__dirname, 'features/mac-media-controller.html'),
        silentNotch: resolve(__dirname, 'features/silent-notch-notifications.html'),
        clipboard: resolve(__dirname, 'features/mac-clipboard-manager.html'),
      },
    },
  },
})
