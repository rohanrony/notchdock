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
- compact view
- expanded view
- settings view
- lifecycle hooks

## Rules
- Extensions should be loosely coupled.
- New extensions should not require host rewrites.
- Paid extensions must be unlockable separately.
- Keep module boundaries strict.
