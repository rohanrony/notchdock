# NotchDock: End-User & Usage Guide

NotchDock is a premium, modular productivity overlay for macOS designed to transform the hardware notch area of your MacBook Pro (or the top-center edge of any display) into a functional, glanceable "Dynamic Island." 

By turning a static design element into a hub of active workflows, NotchDock gives you instant, distraction-free access to your calendar, tasks, focus timers, music playback, snippets, sports scores, and stock portfolios—all without forcing you to switch focus from your active windows.

![Sports Widget Demo](notchdock/marketing.assets/SportsWidget.gif)

![NotchDock Demo](https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997)

---

## 🎥 Video Demo & Overview

To see NotchDock in action, watch our short demonstration video:

[**Watch the NotchDock Demo Video**](https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997)

---

## 🚀 Setup Assistant (First-Launch Guide)

When you open NotchDock for the first time, the **Setup Assistant** launches automatically to help you get configured:
* **System Permissions Checklist**: Easily grant access for Calendars & Reminders and AppleScript Automation (Music controls) in one place.
* **Keychain Storage Authorization**: Prompts and authorizes secure local database storage for the ToDo List and Quick Access widgets.
* **Interactive Widget Guides**: A built-in directory where you can read usage tips, features, and settings for each of the 7 core widgets.
* **Interaction Tips**: Explains how to trigger hover-expansion, lock the panel open using the Pin button, or minimize the app to the macOS Menu Bar.

> [!TIP]
> You can manually relaunch this onboarding wizard at any time. Click the **Gear icon ⚙️** in the expanded panel to open Settings, select **General**, and click the **"Launch Guide..."** button under the **System** card.

---

## 🕹️ How NotchDock Works

NotchDock resides at the top of your display and behaves like an integrated hardware element. It operates in three main states:

### 1. Idle / Compact State
* **Glanceable Status**: When you are working, NotchDock stays out of your way, displaying a slim bar around your screen's notch with minimal status tokens (e.g., meeting countdowns, active focus timers, live scores, or stock quotes).
* **Live App Rotation**: If you have multiple "live-tracking" widgets enabled (such as Sports Scores or Stocks), NotchDock will automatically rotate between them in the compact view every **15 seconds** so you can monitor updates hands-free.

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
* **What it does**: Tracks your upcoming events and reminders, displaying countdown timers to meetings.
* **Compact View**: Displays the title of the next event and a countdown timer (e.g., `Meeting in 15m`).
* **Expanded View**:
  * **3-Column Layout**: A premium, vertically-aligned horizontal split-pane:
    - **Month Grid**: A complete, interactive monthly calendar. Highlighted today indicator and small event dot indicators below each date. Navigation chevrons for shifting months and a quick shortcut to launch the macOS Calendar app.
    - **Schedule List**: A unified list of all events and reminders for the selected day. Includes Apple Calendar-style check toggles for Scheduled Reminders, allowing you to mark them complete directly with automatic syncing back to the system Reminders store.
    - **Details Pane**: Displays full details of the selected event or reminder, including description, notes, time, location (with a map pin icon), and completion status.
  * **One-Click Join**: A "Join Meeting" button appears automatically **10 minutes before** any online meeting (supporting Zoom, Google Meet, Microsoft Teams, and Webex) in the Details Pane, launching the video link instantly.
* **Key Settings**:
  * Select which specific calendars and reminder lists are visible.
  * Adjust the **Show in Minimized Notch** threshold (from 5 minutes to 120 minutes) to control how early upcoming events appear.
  * Set the ongoing transition threshold.

---

### 2. 📋 ToDo List
A lightweight, friction-free checklist designed for immediate, high-priority tasks, organized into category folders.
* **What it does**: Helps you capture, categorize, and complete tasks during your workday.
* **Compact View**: Displays a checklist icon and an animated remaining task count badge for the active folder.
* **Expanded View**:
  * **Multiple Folders (Sub-Tabs)**: Group tasks into custom folders (e.g., "Work", "Personal") toggled via horizontal scrollable tabs in the header.
  * **Drag-and-Drop Reordering**: Drag and drop folder tabs in the header to reorder them, or drag individual task cards inside a folder to reorder the checklist.
  * **Add Tasks**: Inline task creation at the bottom of the list.
  * **Interactive Checklist**: Mark tasks complete with checkbox checkmarks, with animated scaling pulse feedback and strikethrough styling upon completion.
  * **Hover Actions**: Move your mouse over any task to reveal delete (`xmark.circle.fill`) and reorder handle controls.
* **Key Settings**: Manage folders directly from settings (set active picker, add, delete, rename, and drag-and-drop to reorder them). All data is saved securely using JSON Keychain persistence.

---

### 3. ⏱️ Focus Timer (Pomodoro)
A focus companion designed to structure work sessions using Pomodoro techniques or custom counts.
* **What it does**: Tracks work blocks, Pomodoro sessions, and custom durations.
* **Compact View**: Displays a timer icon and a ticking remaining countdown (e.g. `14:59`) only when the timer is running, and stays silent when idle.
* **Expanded View**:
  * **Custom Duration Inputs**: Two-digit fields for minutes and seconds with automatic cursor tabbing when stopped.
  * **Interactive Slider**: A premium Apple-style capsule slider allows you to drag to set your baseline duration (1 to 60 minutes) when stopped, with smooth hover and drag animations.
  * **Remaining Progress Bar**: When running, the slider circular thumb hides and the bar acts as a clean, non-interactive visual progress display indicating the remaining percentage of the session.
  * **Focus Presets & Controls**: Quick-launch buttons for standard presets (15, 25, or 50 minutes) alongside Play/Pause and Reset controls.
* **Smart Nudges & Blinking Alarms**: Slides open to notify at key remaining-time checkpoints. Upon reaching zero, it plays a double chime, auto-expands the notch, locks navigation controls, and blinks at a 1Hz frequency until acknowledged by hovering over the panel.

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

![Stocks Widget Demo](notchdock/marketing.assets/StocksWidget.gif)

* **What it does**: Monitors market movements, trends, and fundamental metrics.
* **Compact View**: Displays your pinned stock ticker symbol, live price, and daily change percentage (e.g., `AAPL $184.22 (+1.45%)`). Rotates between multiple pinned tickers and animates with a rolling stock-board effect.
* **Expanded View**:
  * **Multiple Watchlists**: Organize assets into up to 10 watchlists with user-editable names, displayed as clean backgroundless tabs with a prominent active pill selector.
  * **Timeframe Selector**: Filter historical data using a dropdown menu in the header (1D, 5D, 1M, 3M, 6M, 1Y, 5Y, Max).
  * **Gradient Sparklines**: Visual sparkline charts of daily trend performance with a fading gradient. Supports **Interactive Scrubbing/Hovering**: hovering over a sparkline renders a vertical scrub line, overlays a pulsing dot on the trend line, and displays a glassmorphic floating price tooltip at the cursor position.
  * **Drag-and-Drop Reordering**: Hold and drag stock cards (via far-left handles that fade in on hover) or watchlist tabs to reorder them in real-time.
  * **Market Data & Fundamentals**: Shows detailed daily metrics (Open, High, Low, Volume) and fundamental stats (Market Cap, static EPS, and dynamically recalculated P/E Ratio).
  * **Pin Ticker**: Pin any asset to display it in the compact notch using a simple bookmark toggle icon.
* **Key Settings**: Toggle display outside standard US market hours (9:30 AM to 4:00 PM ET), adjust live matches/stock rotation interval (5 to 300 seconds), manage watchlists (add, delete, rename), query and add custom symbols via Yahoo autocomplete search, and reorder watchlists/tickers via drag-and-drop lists.

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
