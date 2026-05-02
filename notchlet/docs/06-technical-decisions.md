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

## Key APIs & Frameworks
- **Calendar**: `EventKit` (`EKEventStore`) for querying local calendars and `.event` access. Regex matching for Zoom/Meet URLs.
- **Clipboard**: `NSPasteboard` changeCount monitoring. `CGEvent` or AppleScript for simulating `Cmd+V` to restore items.
- **Timer**: `Foundation.Timer` for precise background counting, `NSSound` for alerts.
- **Music**: `/usr/bin/osascript` via `Process` for robust, silent control of Apple Music and Spotify. This avoids system log pollution and framework overhead.
- **Claude**: `URLSession` for Anthropic HTTP API requests.
- **AppKit**: `NSPanel` (`LSUIElement`) for headless overlay behavior.

## Constraints
- Keep code modular.
- Prefer small view models and focused services.
- **Privacy**: All permission strings (EventKit, MediaRemote) must be explicitly defined in the app's `Info.plist`.
- **Accessibility**: All interactive elements must include VoiceOver labels; UI must respect `accessibilityReduceMotion`.
- Avoid overbuilding v1.
