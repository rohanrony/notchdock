# NotchDock Technical Decisions

## Language
Use Swift.

## UI framework
Use SwiftUI for the main UI and AppKit only where needed.

## Why Swift
- Best fit for native macOS behavior.
- Strong integration with Apple APIs.
- Good fit for Liquid Glass styling.
- Easy to keep modular.

## Key APIs & Frameworks
- **Calendar**: `EventKit` (`EKEventStore`) for querying local calendars and `.event` access. Regex matching for Zoom/Meet URLs.
- **Quick Access**: `NSPasteboard` monitoring for snippets and manual entry for notes. Persistence via local JSON/UserDefaults.
- **Timer**: `Foundation.Timer` for precise background counting, `NSSound` for alerts.
- **Music**: `/usr/bin/osascript` via `Process` for robust, silent control of Apple Music and Spotify. This avoids system log pollution and framework overhead.
- **AppKit**: `NSPanel` (`LSUIElement`) for overlay behavior. Settings window is a standard `NSWindow`.

## Constraints
- Keep code modular.
- Prefer small view models and focused services.
- **Privacy**: All permission strings (EventKit, MediaRemote) must be explicitly defined in the app's `Info.plist`.
- **Accessibility**: All interactive elements must include VoiceOver labels; UI must respect `accessibilityReduceMotion`.
## Interaction Logic
- **Restricted Hover Zone**: To prevent accidental activations, the notch surface's hover hit-test area is strictly constrained to the physical notch's detected width using `.contentShape(Rectangle())` and explicit frame management in the idle state.
