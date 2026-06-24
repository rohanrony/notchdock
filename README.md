# NotchDock

NotchDock is a modular productivity overlay for macOS designed to transform the hardware notch area into a functional, premium "Dynamic Island." It provides persistent, glanceable access to critical professional workflows—meetings, clipboard history, timers, and AI—without requiring users to switch focus from their active windows.

## 🎥 Video Demo

<a href="https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997" target="_blank" rel="noopener noreferrer">
  <img width="1280" height="720" alt="Recording at 2026-05-03 15 52 07-Edited" src="https://github.com/user-attachments/assets/e8f6dde9-9de8-49ca-848b-c10028591064" />
</a>

<a href="https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997" target="_blank" rel="noopener noreferrer">
  <img width="550" height="283" alt="image" src="https://github.com/user-attachments/assets/385cb90d-a7c8-4047-85c1-5baebd2cb302" />
</a>

[NotchDock Demo Video](https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997)

## Features

NotchDock is built around a plugin-based "module" architecture. The v1 MVP includes seven core modules:

- 📅 **Calendar**: Syncs with local calendars to display your next meeting countdown and offers a one-click "Join" button for Zoom, Google Meet, or Teams.
- 📋 **ToDo List**: A lightweight task manager for tracking immediate, high-priority to-dos.
- ⏱️ **Focus Timer**: A simplified Pomodoro-style countdown timer with presets for 15, 25, and 50 minutes.
- 🎵 **Music Module**: Hardened Apple Music and Spotify integration via secure, sandboxed AppleScript IPC.
- 🗒️ **Quick Access**: A streamlined utility for storing and copying frequently used text snippets.
- 🏀 **Sports scores**: Tracks live game scores and scheduling updates for favorite teams and leagues (including FIFA World Cup 2026 and UEFA Champions League) with custom score notifications and compact view pinning.
- 📈 **Stocks Tracker**: Tracks real-time stock prices, indices, and cryptocurrencies with custom watchlists, gradient sparkline charts, and detailed daily/fundamental statistics.

## Security & Privacy

NotchDock is designed with a **privacy-first, local-only** architecture:

- **App Sandbox**: Runs in a highly restricted macOS Sandbox, ensuring it only has access to the specific resources you authorize.
- **Local-First**: Your data never leaves your machine. We do not use any cloud backends for module storage or synchronization.
- **Keychain Security**: All sensitive user data and tokens are stored in the macOS Keychain, not in plain text or standard configuration files.
- **Privacy-Aware Logging**: Uses native `os.log` with private formatting to ensure sensitive information never appears in system logs.
- **Hardened IPC**: Communicates with external apps (like Music/Spotify) via sanitized, in-process automation to prevent script injection.

## Design Aesthetic

NotchDock features a deeply integrated, hardware-like aesthetic:
- **Solid 3D Surfaces**: Uses a deep `#1B1B1B` background with multi-layered drop shadows to create a floating 3D effect without relying on heavy glassmorphism.
- **Dynamic Horizontal Layout**: The tray dynamically stretches horizontally based on content, using a central spacer guaranteeing it always clears the physical MacBook notch.
- **Ultra-Compact**: Internal module padding and redundant headlines are stripped away to create a flawlessly tight vertical footprint.
- **Native Typography**: Exclusively uses the macOS San Francisco system font.

## Technical Stack

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Window Management**: AppKit (`NSPanel`)
- **Architecture**: Runs as a headless background agent (`LSUIElement`) via `NSApplicationDelegateAdaptor`. It has no Dock icon or menu bar presence outside of the Notch overlay itself.

## Getting Started

## Prerequisites
- macOS 14.0+ (Sonoma or later recommended)
- Xcode 15+

### Build and Run
Because NotchDock runs as a headless background process, running it from the terminal via the provided build script is recommended:

```bash
# Compile and run the app
./build-and-run.sh
```

*(Note: If you run multiple instances from Xcode during development, you may need to force-quit old `notchdock` background processes via Activity Monitor since they will not appear in the Dock).*

### Packaging as a DMG
To package NotchDock as a styled distribution disk image (`NotchDock.dmg`):

1. Install `create-dmg` via Homebrew:
   ```bash
   brew install create-dmg
   ```
2. Run the packaging script from the repository root:
   ```bash
   ./package.sh
   ```

*(Note: Under macOS, processes spawned programmatically by IDEs or IDE agents run under sandboxing constraints that block disk volume mounting. If you encounter sandbox permission errors, run `./package.sh` from a native macOS Terminal or iTerm2 application).*

## Documentation

Full architectural decisions, design system tokens, and monetization roadmaps can be found in the `notchdock/docs/` directory.
