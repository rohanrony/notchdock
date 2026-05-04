# NotchDock Demo + Product Requirements Document (PRD)

---

## 🎥 Video Demo
<a href="https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997" target="_blank" rel="noopener noreferrer">
  <img width="1280" height="720" alt="Recording at 2026-05-03 15 52 07-Edited" src="https://github.com/user-attachments/assets/e8f6dde9-9de8-49ca-848b-c10028591064" />
</a>

<a href="https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997" target="_blank" rel="noopener noreferrer">
  <img width="550" height="283" alt="image" src="https://github.com/user-attachments/assets/385cb90d-a7c8-4047-85c1-5baebd2cb302" />
</a>

[NotchDock Demo Video](https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997)




---

## 📦 Download

[**Download NotchDock DMG**](https://github.com/rohanrony/notchdock/releases)


---

## 1. Product Overview

### 1.1 Executive Summary
**NotchDock** is a modular productivity overlay for macOS designed to transform the hardware notch area into a functional "Dynamic Island." It provides persistent, glanceable access to critical professional workflows—meetings, snippets, timers, and tasks—without requiring users to switch focus from their active windows.

### 1.2 Vision
To bridge the gap between hardware and software by turning a static design element (the notch) into an interactive, premium productivity hub that feels like a native extension of macOS.

---

## 2. Target Audience
- **Professional Power Users**: Developers, designers, and managers who need high-frequency, low-friction access to micro-tasks.
- **MacBook Pro Users**: Specifically those with notched displays (14" and 16" models) seeking to utilize that screen real estate.
- **Privacy-Conscious Users**: Individuals who prefer local-only tools over cloud-based productivity suites.

---

## 3. Core Features (The Modules)

### 3.1 Meeting Navigator (Calendar)
- **Function**: Syncs with local calendars (via EventKit) to identify the immediate next event.
- **Key Capability**: Displays a countdown timer. A "Join" button appears 10 minutes before the start, launching Zoom/Meet/Teams links directly.

### 3.2 Quick Access (Snippets)
- **Function**: Maintains a transient history of snippets and notes for quick retrieval.
- **Key Capability**: A streamlined utility for storing and copying frequently used text snippets with editable headings.

### 3.3 ToDo List
- **Function**: A lightweight task manager for tracking immediate, high-priority to-dos.
- **Key Capability**: Interactive checklist with in-place task creation and persistence.

### 3.4 Music Controller
- **Function**: Interfaces with Apple Music and Spotify via secure, sandboxed AppleScript IPC.
- **Key Capability**: Displays track info, album art, and minimalist playback controls.

### 3.5 Timer
- **Function**: A simplified countdown timer for focus sessions (Pomodoro-style).
- **Key Capability**: Integrated progress display with system notifications upon completion.

---

## 4. User Experience & Design

### 4.1 The "Surface" Interaction Model
- **Idle State**: A slim, high-contrast bar displaying minimal status tokens.
- **Active State**: Upon hover, the surface expands vertically and dynamically horizontally to reveal active modules.
- **Symmetric Expansion**: The UI expands perfectly around the physical hardware notch.
- **Pinning**: A system to lock the notch in an open state for persistent monitoring.

### 4.2 Aesthetic Principles
- **3D Solid Surfaces**: Uses a deep `#0C0C0C` background with multi-layered drop shadows to create a floating 3D effect.
- **Hardware Integration**: Corner radii are precision-tuned to match the physical MacBook notch.
- **Native Typography**: Exclusively uses the Apple San Francisco system font for a seamless integration with macOS.

---

## 5. Privacy & Security
- **Local-Only Architecture**: Your data never leaves your machine. No cloud backends or remote synchronization.
- **App Sandbox**: Runs in a highly restricted environment, accessing only authorized system resources (Calendar, Music).
- **Keychain Security**: Sensitive data and tokens are stored in the macOS Keychain.
- **Hardened IPC**: Communicates with external apps via sanitized, in-process automation.

---

## 6. Technical Stack
- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Window Management**: AppKit (`NSPanel`)
- **System Integration**: EventKit, AppleScript IPC
- **Distribution**: Headless background agent (`LSUIElement`)

---

## 7. Roadmap (Upcoming Features)

### 7.1 Core System & UX Enhancements
- **Dynamic Dock State**: Implementation of a "Minimize to Tray" feature where the Pin button transforms to convert the Dock into a Menu Bar icon. Clicking the Menu Bar icon restores the NotchDock overlay.
- **Interactive Home View**: 
    - Development of a **Widgetized Home Page** allowing users to see glanceable data (e.g., Music widget, Calendar summary) at once.
    - **Drag-and-Drop Assembly**: Users will be able to customize their Home View by dragging and dropping widgets.
- **Extension Reordering**: Native drag-and-drop support within the expansion tray to customize module sequence.

### 7.2 Module Improvements
- **Meeting Navigator (Calendar)**: Persistent "Join" links that remain accessible throughout the duration of an ongoing meeting, ensuring quick re-entry if disconnected.
- **Messages (iMessage Integration)**:
    - **Compact Design**: Reimagined UI following the ultra-tight "ToDo" module aesthetic.
    - **Smart Feed**: Displaying the top 3 most recent or pinned conversations.
    - **Quick Reply**: An expandable tray that provides space for typing and emoji selection without leaving the Notch interface.

### 7.3 New Extensions Roadmap
- **Reminders (NotchList)**: Deep integration with the macOS Reminders app. Automatically creates and manages a dedicated `notchlist` (e.g., `notchlist 1`, `notchlist 2`) for rapid task entry.
- **AirDrop & Files**: Quick-drop zone for files to initiate AirDrop or move files to common directories.
- **Communication Suite**: Dedicated modules for **Mail**, **Slack**, and **WhatsApp**.
- **Live Camera**: A privacy-aware camera preview module for quick "mirror" checks (pending security hardening).

---

## 8. Success Criteria
- **Zero Friction**: <1% CPU idle footprint and <500ms launch-to-interactive time.
- **Reliability**: Perfect compatibility with macOS Mission Control and Fullscreen transitions.
- **Design Fidelity**: Indistinguishable from native macOS UI elements.
