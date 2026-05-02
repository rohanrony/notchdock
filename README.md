# Notchlet

Notchlet is a modular productivity overlay for macOS designed to transform the hardware notch area into a functional, premium "Dynamic Island." It provides persistent, glanceable access to critical professional workflows—meetings, clipboard history, timers, and AI—without requiring users to switch focus from their active windows.

## Features

Notchlet is built around a plugin-based "module" architecture. The v1 MVP includes five core modules:

- 📅 **Calendar**: Syncs with local calendars to display your next meeting countdown and offers a one-click "Join" button for Zoom, Google Meet, or Teams.
- 📋 **Clipboard Stack**: Monitors system copy events and maintains a transient history of the last 10 items for quick restoration.
- ⏱️ **Focus Timer**: A simplified Pomodoro-style countdown timer with presets for 15, 25, and 50 minutes.
- 🎵 **Media Hub**: Interfaces with macOS `NowPlaying` APIs to control system-wide audio (Spotify, Apple Music, Browser).
- ✨ **Claude Quick-Chat**: A dedicated, perfectly round pill-shaped input field for immediate queries to the Claude API.

## Design Aesthetic

Notchlet features a deeply integrated, hardware-like aesthetic:
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

### Prerequisites
- macOS 14.0+ (Sonoma or later recommended)
- Xcode 15+

### Build and Run
Because Notchlet runs as a headless background process, running it from the terminal via the provided build script is recommended:

```bash
# Compile and run the app
./build-and-run.sh
```

*(Note: If you run multiple instances from Xcode during development, you may need to force-quit old `notchlet` background processes via Activity Monitor since they will not appear in the Dock).*

## Documentation

Full architectural decisions, design system tokens, and monetization roadmaps can be found in the `notchlet/docs/` directory.
