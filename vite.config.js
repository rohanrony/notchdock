import { resolve } from 'path'
import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        privacy: resolve(__dirname, 'privacy.html'),
        whyNotchdock: resolve(__dirname, 'why-notchdock.html'),
        compare: resolve(__dirname, 'compare/mac-notch-apps.html'),
        sports: resolve(__dirname, 'features/mac-sports-tracker.html'),
        stocks: resolve(__dirname, 'features/mac-stock-portfolio.html'),
        pomodoro: resolve(__dirname, 'features/mac-pomodoro-notes.html'),
        media: resolve(__dirname, 'features/mac-media-controller.html'),
        silentNotch: resolve(__dirname, 'features/silent-notch-notifications.html'),
        clipboard: resolve(__dirname, 'features/mac-clipboard-manager.html'),
        eplScores: resolve(__dirname, 'use-cases/epl-mac-scores.html'),
        sp500Widget: resolve(__dirname, 'use-cases/sp500-mac-widget.html'),
        discreetWork: resolve(__dirname, 'use-cases/discreet-work-updates-mac.html'),
        blog: resolve(__dirname, 'blog/index.html'),
        blogIntelligentNotifications: resolve(__dirname, 'blog/intelligent-mac-notifications-live-updates.html'),
        blogDynamicIsland: resolve(__dirname, 'blog/macbook-notch-dynamic-island-live-sports-stocks.html'),
        blogNotificationFatigue: resolve(__dirname, 'blog/how-to-fix-mac-notification-fatigue.html'),
        blogManCityManUtd: resolve(__dirname, 'blog/manchester-city-vs-manchester-united-live-score-tracker-mac.html'),
        blogTrackCpiOilSp500: resolve(__dirname, 'blog/track-cpi-oil-prices-sp500-market-indexes-live-mac.html'),
        blogUpcomingCpiImpact: resolve(__dirname, 'blog/upcoming-cpi-inflation-data-market-impact-live-mac-tracker.html'),
      },
    },
  },
})
