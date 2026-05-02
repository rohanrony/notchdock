# Notchlet Product Specification: v1.0

## 1. Executive Summary
Notchlet is a modular productivity overlay for macOS designed to transform the hardware notch area into a functional "Dynamic Island." It provides persistent, glanceable access to critical professional workflows—meetings, clipboard history, timers, and AI—without requiring users to switch focus from their active windows.

## 2. Core User Experience (The "Surface")
The primary interface is a **floating, 3D-inspired solid surface** anchored to the top-center of the primary display, mirroring the physical notch dimensions.
- **Idle State**: A slim, high-contrast bar displaying minimal status tokens (e.g., "3m to next meeting" or a playback icon).
- **Active State (Expansion)**: Upon hover, the surface expands vertically and dynamically horizontally to reveal active modules. The expansion is **symmetric** around the physical notch.
- **Interaction Model**: Mouse-driven expansion with a **Pinning** system to lock the notch open. Keyboard shortcuts provide quick-action toggles.
- **Visuals**: Full support for dark mode (solid #0C0C0C) with deep, multi-layered 3D drop shadows. The icon bar is perfectly balanced around the notch with a tight 4pt spacing margin.

## 3. Product Goals
1. **Zero-Friction Access**: Reduce "context-switching fatigue" for common micro-tasks.
2. **Modular Architecture**: A plugin-based system where features are self-contained "Notchlets" that can be toggled via settings.
3. **Native Feel**: Implementation must follow Apple’s Human Interface Guidelines (HIG) for corner radii and animation curves.
4. **Performance First**: Maintain a "silent" footprint (<1% CPU idle) to ensure professional workloads are unaffected.

## 4. Feature Scope (v1 MVP)
To maintain a tight feedback loop, the first release implements five core modules:

### 4.1. Meeting Navigator
- **Function**: Syncs with local calendars (via System APIs or `.ics` polling) to identify the immediate next event.
- **UI**: Displays a countdown. A "Join" button appears 2 minutes before the start, launching Zoom/Meet/Teams links directly.

### 4.2. Clipboard Stack
- **Function**: Monitors system copy events and maintains a transient history of the last 10 items (text and links only).
- **UI**: A vertical list within the expanded notch. Clicking an item restores it to the system clipboard for immediate pasting.

### 4.3. Focus Timer
- **Function**: A simplified Pomodoro-style countdown timer.
- **UI**: Integrated progress ring around the notch perimeter. Sends a system notification and haptic feedback (if supported) upon completion.

### 4.4. Media Hub
- **Function**: Interfaces with macOS `NowPlaying` APIs to control system-wide audio (Spotify, Apple Music, Browser).
- **UI**: Displays track info, album art, and minimalist Play/Pause/Skip controls.

### 4.5. Claude Quick-Chat
- **Function**: A dedicated input field for immediate queries to the Claude API.
- **UI**: Inline text entry. Responses are displayed in a compact, scrollable markdown view within the notch area.

## 5. Technical Requirements
- **Core Stack**: Swift 6, SwiftUI, and AppKit.
- **Window Management**: `NSPanel` transparent overlay. The app runs as a headless background agent (`LSUIElement`) using an `NSApplicationDelegateAdaptor`, meaning it has no Dock icon or menu bar presence outside of the Notch itself.
- **Persistence**: SwiftData or local JSON store for settings and clipboard history.
- **APIs**: Claude API (user-provided key), `EventKit` (Calendar), `MediaRemote` (System-wide music control).

## 6. Non-Goals
- **No Cloud Sync**: Version 1 data remains strictly local to the device.
- **No Automation Engine**: Notchlet will not execute complex scripts or system-wide macros in v1.
- **No Marketplace**: All extensions for v1 are bundled with the core app; no external plugin loading.
- **No Window Snapping**: Notchlet is an overlay, not a window manager or "Magnet" competitor.

## 7. Success Criteria
- **Boot Performance**: App is interactive within 500ms of launch.
- **Reliability**: Zero interference with macOS "Mission Control" or Fullscreen app transitions.
- **Visual Fidelity**: Corner radii must perfectly match the hardware notch of 14" and 16" MacBook Pro models.
