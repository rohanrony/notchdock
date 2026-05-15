# NotchDock Product Specification: v1.0

## 1. Executive Summary
NotchDock is a modular productivity overlay for macOS designed to transform the hardware notch area into a functional "Dynamic Island." It provides persistent, glanceable access to critical professional workflows—meetings, snippets, timers, and tasks—without requiring users to switch focus from their active windows.

## 2. Core User Experience (The "Surface")
The primary interface is a **floating, 3D-inspired solid surface** anchored to the top-center of the primary display, mirroring the physical notch dimensions.
- **Idle State**: A slim, high-contrast bar displaying minimal status tokens (e.g., "3m to next meeting" or a playback icon).
- **Active State (Expansion)**: Upon hover, the surface expands vertically and dynamically horizontally to reveal active modules. The expansion is **symmetric** around the physical notch.
- **Minimized State (Menu Bar Icon)**: A native macOS `NSStatusItem` that appears in the system menu bar when the notch surface is hidden.
    - **Visuals**: A custom icon depicting a filled notch inside a rounded square border.
    - **Interaction**: Left-clicking the icon opens a native menu with "Restore to Normal View", "Settings", and "Quit" options.
- **Interaction Model**: Mouse-driven expansion with a **Pinning** system to lock the notch open. 
    - **Minimize Button**: A dedicated button in the expanded notch view to instantly collapse the app into the menu bar icon.
    - **Keyboard Shortcuts**: System-wide toggles for quick access.
- **Visuals**: Full support for dark mode (solid #0C0C0C) with deep, multi-layered 3D drop shadows. The icon bar is perfectly balanced around the notch with a tight 4pt spacing margin.

## 3. Product Goals
1. **Zero-Friction Access**: Reduce "context-switching fatigue" for common micro-tasks.
2. **Modular Architecture**: A plugin-based system where features are self-contained "NotchDocks" that can be toggled via settings.
3. **Native Feel**: Implementation must follow Apple’s Human Interface Guidelines (HIG) for corner radii and animation curves.
4. **Performance First**: Maintain a "silent" footprint (<1% CPU idle) to ensure professional workloads are unaffected.

## 4. Feature Scope (v1 MVP)
To maintain a tight feedback loop, the first release implements four core modules (with others in experimental status):

### 4.1. Meeting Navigator (Calendar)
- **Function**: Syncs with local calendars (via EventKit) to identify the immediate next event.
- **UI**: Displays a countdown. A "Join" button appears 10 minutes before the start, launching Zoom/Meet/Teams links directly.

### 4.2. Quick Access
- **Function**: Maintains a transient history of snippets and notes for quick retrieval and insertion.
- **UI**: A vertical list within the expanded notch. Clicking an item restores it to the system clipboard for immediate pasting. Includes editable headings.

### 4.3. Timer
- **Function**: A simplified countdown timer with quick presets and custom entry.
- **UI**: Integrated progress display. Sends a system notification and plays a sound upon completion.

### 4.4. Music
- **Function**: Interfaces with Apple Music and Spotify via osascript subprocesses.
- **UI**: Displays track info, album art (with dynamic color extraction), and minimalist Play/Pause/Skip controls.

### 4.5. ToDo List
- **Function**: A lightweight task manager for tracking immediate to-dos.
- **UI**: Interactive checklist with in-place task creation and persistence.

### 4.6. Future Extensions (Roadmap)
- **Status**: Features like Slack, Messages, and Mail are planned for future releases.

## 5. Technical Requirements
- **Core Stack**: Swift 6, SwiftUI, and AppKit.
- **Window Management**: `NSPanel` transparent overlay. The app runs as a headless background agent (`LSUIElement`) using an `NSApplicationDelegateAdaptor`, meaning it has no Dock icon or menu bar presence outside of the Notch itself.
- **Persistence**: Local JSON store or UserDefaults for settings, todos, and snippets.
- **APIs**: `EventKit` (Calendar), `osascript` (Music/Spotify control).

## 6. Non-Goals
- **No Cloud Sync**: Version 1 data remains strictly local to the device.
- **No Automation Engine**: NotchDock will not execute complex scripts or system-wide macros in v1.
- **No Marketplace**: All extensions for v1 are bundled with the core app; no external plugin loading.
- **No Window Snapping**: NotchDock is an overlay, not a window manager or "Magnet" competitor.

## 7. Success Criteria
- **Boot Performance**: App is interactive within 500ms of launch.
- **Reliability**: Zero interference with macOS "Mission Control" or Fullscreen app transitions.
- **Visual Fidelity**: Corner radii must perfectly match the hardware notch of 14" and 16" MacBook Pro models.
