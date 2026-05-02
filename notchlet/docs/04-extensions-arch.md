# Notchlet Extension Architecture

## Architecture model
Notchlet uses a host shell plus extensions. The core app owns the island UI, settings, unlock state, and extension registry. Each feature lives in a separate module.

## Folder structure
- NotchletApp
- NotchletCore
- Extensions/Modules/
    - CalendarModule.swift
    - MusicModule.swift
    - ToDoModule.swift
    - TimerModule.swift
    - ClaudeModule.swift
    - ClipboardModule.swift

## Extension protocol
Each extension should expose:
- `id`: Unique identifier (e.g., `com.notchlet.music`).
- `displayName`: Human-readable name.
- `iconName`: SF Symbol name.
- `isPremium`: Boolean for paywall gating.
- `hasCompactView`: Boolean. If `false`, the notch defaults to the **Home State (Calendar)** when collapsed.
- `isLive`: Boolean. Returns `true` if the extension has active background state (e.g., music playing, timer running).
- `compactView`: Returns `AnyView`.
- `expandedView`: Returns `AnyView`.
- `settingsView`: Returns `AnyView`.

## Intelligent Compact View Selection
To provide a proactive "Live Activity" experience, the active compact view is determined by a priority-based algorithm rather than simple manual selection.

### Priority Hierarchy
| Rank | Level | Condition | Behavior |
| :--- | :--- | :--- | :--- |
| **1** | **Critical** | Timer `< 60s` remaining. | Absolute override. |
| **2** | **Nudge** | Calendar 10m boundary hit. | Calendar takes over until acknowledged. |
| **3** | **Active Utility** | Music Playing OR Timer Running. | Uses the most recently touched module. |
| **4** | **Manual Select** | User clicked an icon in the tray. | Valid only if `hasCompactView` is true. |
| **5** | **Home State** | Fallback. | Defaults to **Calendar**. |

### The Sticky Nudge
- **Trigger**: Every 10 minutes (starting 60m before an event and during ongoing events).
- **Sticky**: Once triggered, it stays active until "Acknowledged".
- **Acknowledgment**: Occurs when the user expands the notch or manually selects another live-capable module (Music/Timer).

## State Management
- **ViewModels**: Each module's views are backed by a dedicated `@ObservedObject` or `@StateObject` ViewModel (e.g., `MusicViewModel.shared`).
- **Recency Tracking**: `AppState` maintains `lastInteractionTimes: [String: Date]` for all modules to resolve utility conflicts.
- **Background Execution**: Modules handle background polling or event listening (e.g., `MusicManager` subprocesses, `EKEventStore` observers) within their services/ViewModels.
- **Data Persistence**: Use `UserDefaults` with JSON encoding for complex data or `AppConfig` for centralized constants.

## Rules
- Extensions should be loosely coupled.
- New extensions should not require host rewrites.
- Paid extensions must be unlockable separately.
- Keep module boundaries strict.
