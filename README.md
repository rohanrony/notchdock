# NotchDock Product Requirements Document (PRD)

---

## 🎥 Video Demo
NotchDock=Demo.vid(https://github.com/user-attachments/assets/352bd85a-5fcc-414a-8364-1286573b8997)

<img width="693" height="370" alt="image" src="https://github.com/user-attachments/assets/aca66a74-4537-4893-ac6f-417736aff6c7" />

<img width="540" height="201" alt="image" src="https://github.com/user-attachments/assets/1927ca40-71ad-4119-a067-2bcfae45b3e2" />

<img width="751" height="228" alt="image" src="https://github.com/user-attachments/assets/dd2bde9e-df62-4339-8884-5f829fabf639" />

<img width="550" height="283" alt="image" src="https://github.com/user-attachments/assets/385cb90d-a7c8-4047-85c1-5baebd2cb302" />




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

## 7. Roadmap (Future Extensions)
- **Messaging Integration**: Quick glance for Slack, Messages, and Mail.
- **System Telemetry**: Monitoring CPU, RAM, and battery health.
- **Custom Theming**: User-definable accent colors and transparency levels.

---

## 8. Success Criteria
- **Zero Friction**: <1% CPU idle footprint and <500ms launch-to-interactive time.
- **Reliability**: Perfect compatibility with macOS Mission Control and Fullscreen transitions.
- **Design Fidelity**: Indistinguishable from native macOS UI elements.
