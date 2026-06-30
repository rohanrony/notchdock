# NotchDock: End-User & Usage Guide

NotchDock is a premium, modular productivity overlay for macOS designed to transform the hardware notch area of your MacBook Pro (or the top-center edge of any display) into a functional, glanceable "Dynamic Island." 

By turning a static design element into a hub of active workflows, NotchDock gives you instant, distraction-free access to your calendar, tasks, focus timers, music playback, snippets, sports scores, and stock portfolios—all without forcing you to switch focus from your active windows.

![Sports Module Demo](notchdock/marketing.assets/SportsModule.gif)

![NotchDock Demo](https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997)

---

## 🎥 Video Demo & Overview

To see NotchDock in action, watch our short demonstration video:

[**Watch the NotchDock Demo Video**](https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997)

---

## 🕹️ How NotchDock Works

NotchDock resides at the top of your display and behaves like an integrated hardware element. It operates in three main states:

### 1. Idle / Compact State
* **Glanceable Status**: When you are working, NotchDock stays out of your way, displaying a slim bar around your screen's notch with minimal status tokens (e.g., meeting countdowns, active focus timers, live scores, or stock quotes).
* **Live App Rotation**: If you have multiple "live-tracking" modules enabled (such as Sports Scores or Stocks), NotchDock will automatically rotate between them in the compact view every **15 seconds** so you can monitor updates hands-free.

### 2. Hover to Expand
* **Natural Gestures**: Simply move your cursor over the compact notch area. To prevent accidental triggers while browsing or using screen menus, the activation zone is restricted strictly to the width of the physical notch.
* **Expanded View**: Upon hover, the tray smoothly expands downward and horizontally to reveal the active app's interface and the control bar.

### 3. Expanded Tray Controls
When NotchDock is expanded, the top bar of the tray gives you access to core controls:
* **App Switcher**: Icons for all enabled apps are displayed on the left and right sides of the notch. Click an icon to switch the active view.
* **Pin Open**: Click the **Pin** icon 📌 (which glows warm amber when active) to lock the tray open. This keeps NotchDock expanded even when you move your cursor away, allowing you to monitor active tasks or sports games.
* **Minimize to Menu Bar (Icon View)**: Click the **Minimize** icon ↘️↖️ to completely hide the notch overlay and convert it into a tiny icon in your macOS Menu Bar. Click the Menu Bar icon to restore it to the screen overlay at any time.
* **Settings**: Click the **Gear** icon ⚙️ to open the settings panel.
* **Drag-and-Drop Reordering**: Customize your App Switcher layout by holding and dragging any app icon to a new spot in the top bar. Your custom layout is saved automatically.

---

## 📅 Usage Guide: The 7 Core Apps

NotchDock comes preloaded with seven modular apps. You can enable, disable, and order them to fit your workflow.

### 1. 📅 Meeting Navigator (Calendar & Reminders)
Synchronizes directly with your local macOS Calendars and Reminders to keep your schedule at the front of your mind.
* **What it does**: Tracks your upcoming events and displays a countdown timer to your next meeting.
* **Compact View**: Displays the title of the next event and a countdown timer (e.g., `Meeting in 15m`).
* **Expanded View**:
  * **Interactive Grid**: A complete monthly calendar view. Tapping a day displays the scheduled events for that day.
  * **Event Card**: Detailed view of your next event, including title, location, notes, and exact time.
  * **One-Click Join**: A "Join Meeting" button appears automatically **10 minutes before** any online meeting (supporting Zoom, Google Meet, and Microsoft Teams), launching the video link instantly.
  * **Upcoming Schedule**: A scrollable column displaying upcoming calendar events and pending reminder lists.
* **Key Settings**:
  * Select which specific calendars and reminder lists are visible.
  * Adjust the **Show in Minimized Notch** threshold (from 5 minutes to 120 minutes) to control how early upcoming events appear.

---

### 2. 📋 ToDo List
A lightweight, friction-free checklist designed for immediate, high-priority tasks.
* **What it does**: Helps you capture and cross off tasks during your workday without opening heavy task managers.
* **Compact View**: Remains silent unless prioritized, letting you focus on your current screen.
* **Expanded View**:
  * **Add Tasks**: Simply type a task in the entry box and hit **Enter** or tap **Add**.
  * **Interactive Checklist**: Mark tasks complete with checkboxes or swipe/click to remove them. All entries are persisted locally.

---

### 3. ⏱️ Focus Timer (Pomodoro)
A focus companion designed to structure work sessions using Pomodoro techniques or custom counts.
* **What it does**: Tracks work blocks and provides notifications when focus intervals end.
* **Compact View**: Shows a countdown of your active focus session (e.g., `Focus: 24:15`).
* **Expanded View**:
  * **Focus Presets**: Start standard sessions instantly with 15, 25, or 50-minute presets.
  * **Controls**: Pause, resume, or cancel active timers at any time.
* **Smart Nudges**: When a timer is running, NotchDock will briefly slide open at key milestones (like 5 minutes remaining) to keep you aware of your time. When the timer finishes, a native notification triggers and an alarm chime plays.

---

### 4. 🎵 Music Controller
A playback dashboard that connects securely with Spotify and Apple Music via local automation.
* **What it does**: Displays currently playing tracks and lets you control your music from the notch.
* **Compact View**: Displays a clean, dynamic music visualizer wave next to the album artwork when music is playing.
* **Expanded View**:
  * **Track Metadata**: Displays track name, artist, and full high-resolution album artwork.
  * **Adaptive Accent Styling**: The interface background dynamically shifts color to match the dominant theme of the current song's album art.
  * **Playback Controls**: Play/pause, skip forward, skip backward, and seek through the song using an interactive playback slider.
  * **Quick Launch**: Tap the app icon (Apple Music logo or Spotify icon) in the corner to bring the active player application to the front.
* **Key Settings**: Toggle whether music info is displayed in the compact notch state.

---

### 5. 🏀 Sports Scores
Pulls live, real-time sports updates client-side using public scoreboard data.
* **What it does**: Keeps you updated on active matches and schedules for your favorite leagues and teams.
* **Compact View**: Pins a live game's score directly to the notch (e.g., `BOS 104 - 101 MIA | 4th`).
* **Expanded View**:
  * **Scores & Schedule**: Shows matchups, live scores, quarter/half status, team records, and logos.
  * **Detailed Stats**: Hover over any match card to open a temporary statistics overlay showing team stats and period-by-period linescore grids.
  * **Pin Game**: Tap a game to lock it to the compact view.
* **Live Update Nudges**: When a team scores in a pinned game, NotchDock automatically slides open for 5 seconds to show you the updated score, then collapses back into place.
* **Key Settings**: Enable/disable specific leagues (e.g., NBA, NFL, UEFA Champions League, Premier League) and search/add favorite teams to track.

---

### 6. 📈 Stocks Tracker
Real-time tracking of stock prices, indices, and cryptocurrency portfolios.

![Stocks Module Demo](notchdock/marketing.assets/StocksModule.gif)

* **What it does**: Monitors market movements and daily trends.
* **Compact View**: Displays your pinned stock ticker symbol, live price, and daily change percentage (e.g., `AAPL $184.22 (+1.45%)`).
* **Expanded View**:
  * **Multiple Watchlists**: Organize assets into custom watchlists (Tech, Indices, Crypto, Custom) with editable names.
  * **Gradient Sparklines**: Displays a visual mini-chart of daily performance trends.
  * **Market Data**: Provides detailed daily metrics (Open, High, Low, Volume) and fundamental stats (Market Cap, P/E, EPS).
  * **Pin Ticker**: Pin any asset to display it in the compact notch.
* **Key Settings**: Toggle display outside standard market hours, rename watchlists, and search/add tickers to lists.

---

### 7. 🗒️ Quick Access (Snippets)
A utility for storing and copying your most frequently used text snippets.

![Quick Access Demo](https://github.com/user-attachments/assets/385cb90d-a7c8-4047-85c1-5baebd2cb302)

* **What it does**: Holds template messages, email signatures, code snippets, or common URLs for instant clipboard access.
* **Compact View**: Remains silent until expanded.
* **Expanded View**:
  * Displays a list of custom snippets with editable headings.
  * Tap any snippet to copy it instantly to your macOS clipboard, ready to paste anywhere.

---

## ⚙️ App Settings & Customization

Click the **Gear** icon in the expanded NotchDock panel to open the settings window:

* **General**: Enable or disable specific apps. Check or change the global ordering list.
* **Launch at Login**: Enable this to ensure NotchDock starts automatically whenever you turn on your Mac.
* **Minimize to Icon View**: Toggles whether the notch overlay is enabled or if NotchDock runs purely inside the macOS Menu Bar.
* **App Settings**: Configure visible calendars, leagues, stock watchlists, and music sources on a per-app basis.

---

## 🔒 Privacy, Security & Permissions

NotchDock is designed with a strict **privacy-first, local-only architecture**:
* **Sandbox Security**: Runs inside a restricted macOS Sandbox, meaning it cannot access files, networks, or system resources unless you explicitly grant access.
* **No Cloud Storage**: None of your data, calendar events, tasks, notes, watchlists, or keychain credentials ever leave your machine.
* **No Telemetry**: NotchDock does not track your behavior, log your usage, or send diagnostic metrics back to any server.

### Required Permissions
To operate fully, macOS will ask you to authorize the following:
1. **Accessibility**: Required for NotchDock to detect window layouts, menu bar configurations, and correctly overlay the tray around the physical notch.
2. **Calendars & Reminders**: Required for the Meeting Navigator app to sync and fetch local schedules.
3. **Automation (AppleScript)**: Required for the Music Controller app to control Apple Music and Spotify.
4. **Notifications**: Required to trigger alerts for focus timer completions or upcoming calendar events.

---

## 🛠️ Troubleshooting & Diagnostics

### Re-triggering System Permissions
If you accidentally denied permission to an app (such as Calendar or Music):
1. Open your Mac's **System Settings** ➡️ **Privacy & Security**.
2. Locate the corresponding section (e.g., **Calendars**, **Automation**, or **Accessibility**).
3. Enable the switch next to **NotchDock**.
4. Restart NotchDock.

### Logs & Diagnostics
If you experience any issues or need to debug:
1. Open NotchDock **Settings** ➡️ **Support**.
2. Under **Diagnostics & Logs**, you can view the live log entries.
3. Use the **Copy Logs** or **Export Logs** buttons to save or share your diagnostics safely (sensitive credentials and private details are automatically sanitized out of all logs).
4. Tap **Quit NotchDock** in General Settings to completely stop the application if you need to perform a clean restart.
