# NotchDock

NotchDock is a modular productivity overlay for macOS designed to transform the hardware notch area into a functional, premium "Dynamic Island." It provides persistent, glanceable access to critical professional workflows—meetings, clipboard history, timers, and AI—without requiring users to switch focus from their active windows.

## Features

NotchDock is built around a plugin-based "module" architecture. The v1 MVP includes five core modules:

- 📅 **Calendar**: Syncs with local calendars to display your next meeting countdown and offers a one-click "Join" button for Zoom, Google Meet, or Teams.
- 📋 **ToDo / QuickAccess**: A secure, Keychain-backed snippet manager and task list for rapid data entry and retrieval.
- ⏱️ **Focus Timer**: A simplified Pomodoro-style countdown timer with presets for 15, 25, and 50 minutes.
- 🎵 **Music Module**: Hardened Apple Music and Spotify integration via secure, sandboxed AppleScript IPC.
- 🗒️ **Quick Access**: A streamlined utility for storing and copying frequently used text snippets.

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

### Prerequisites
- macOS 14.0+ (Sonoma or later recommended)
- Xcode 15+

### Build and Run
Because NotchDock runs as a headless background process, running it from the terminal via the provided build script is recommended:

```bash
# Compile and run the app
./build-and-run.sh
```

*(Note: If you run multiple instances from Xcode during development, you may need to force-quit old `notchdock` background processes via Activity Monitor since they will not appear in the Dock).*

## Documentation

Full architectural decisions, design system tokens, and monetization roadmaps can be found in the `notchdock/docs/` directory.
