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
- id
- displayName
- icon
- isPremium
- optional productID
- compact view (returns AnyView)
- expanded view (returns AnyView)
- settings view (returns AnyView)

## State Management
Extensions must be decoupled from the core UI thread. 
- **ViewModels**: Each module's views are backed by a dedicated `@ObservedObject` or `@StateObject` ViewModel (e.g., `MusicViewModel.shared`).
- **Background Execution**: Modules handle background polling or event listening (e.g., `MusicManager` subprocesses, `EKEventStore` observers) within their services/ViewModels.
- **Data Persistence**: Use `UserDefaults` with JSON encoding for complex data (e.g., ToDo items) or `AppConfig` for centralized constants.

## Rules
- Extensions should be loosely coupled.
- New extensions should not require host rewrites.
- Paid extensions must be unlockable separately.
- Keep module boundaries strict.
