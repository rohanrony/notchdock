# Notchlet Technical Decisions

## Language
Use Swift.

## UI framework
Use SwiftUI for the main UI and AppKit only where needed.

## Why Swift
- Best fit for native macOS behavior.
- Strong integration with Apple APIs.
- Good fit for Liquid Glass styling.
- Easy to keep modular.

## Key APIs
- EventKit for calendar.
- NSPasteboard for clipboard.
- StoreKit 2 for purchases.
- Keychain for secrets.
- AppKit for panel/window behavior when required.

## Constraints
- Keep code modular.
- Prefer small view models and focused services.
- **Privacy**: All permission strings (EventKit, MediaRemote) must be explicitly defined in the app's `Info.plist`.
- **Accessibility**: All interactive elements must include VoiceOver labels; UI must respect `accessibilityReduceMotion`.
- Avoid overbuilding v1.
