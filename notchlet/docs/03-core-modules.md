# Notchlet Core Modules

## Free modules
### Calendar
Show next meeting, countdown, and one-click join for Zoom, Google Meet, or Teams links.

### Clipboard
Show top 10 clipboard items and let the user restore one quickly.

### Timer
Offer quick countdown presets such as 15, 25, and 50 minutes.

### Music
Provide now playing display and transport controls for Apple Music or Spotify. This module is free.

### Claude
Allow lightweight Claude chat using a user-entered API key. No clipboard AI actions. Features a perfectly round (20pt radius) pill-shaped input field. Status warnings (e.g., "API Key not configured") are shown in dark red and hidden entirely when configured.

## Module behavior
Each module must have:
- Compact island state.
- Expanded panel state utilizing a highly compact vertical layout.
- Horizontal alignment (HStack) is preferred for internal content (like Music and Timer) to minimize vertical height.
- **No Module Headlines**: Redundant titles like "Ask Claude" or "Focus" must be omitted to save space.
- Settings state if needed.
- Clear empty states.
- Clear permission or auth states.

## Non-goals
- No AI transform buttons on clipboard.
- No full music library management.
- No heavy chat workspace.

## Upgrade paths (See 08-monetization)
- **Clipboard**: Upgrade to **Pinboard** ($1) to save favorite snippets permanently.
- **Claude**: Upgrade to **History** ($1) to persist conversations across sessions.
- **Timer**: Upgrade to **Pomodoro+** ($1) for detailed focus statistics and custom sounds.

## Permission requirements
- **Calendar**: Requires `NSCalendarUsageDescription` (EventKit).
- **Music**: Requires `NSAppleMusicUsageDescription` (MediaRemote).
- **Clipboard**: Requires sandbox exceptions for Apple Events to restore items.

