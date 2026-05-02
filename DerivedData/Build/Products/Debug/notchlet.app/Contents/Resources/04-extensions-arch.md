# Notchlet Extension Architecture

## Architecture model
Notchlet uses a host shell plus extensions. The core app owns the island UI, settings, unlock state, and extension registry. Each feature lives in a separate module.

## Folder structure
- NotchletApp
- NotchletCore
- Extensions/CalendarExtension
- Extensions/ClipboardExtension
- Extensions/TimerExtension
- Extensions/MusicExtension
- Extensions/ClaudeExtension

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
- **ViewModels**: Each module's `expandedView` must be backed by a dedicated `@StateObject` ViewModel (e.g., `TimerViewModel`).
- **Background Execution**: Modules must handle their own background polling or event listening (e.g., `NSPasteboard` observers, `Timer` loops) within their ViewModel.
- **Data Persistence**: Use `@AppStorage` for simple toggles/API keys, or local JSON for historical data (e.g., Clipboard snippets).

## Rules
- Extensions should be loosely coupled.
- New extensions should not require host rewrites.
- Paid extensions must be unlockable separately.
- Keep module boundaries strict.
