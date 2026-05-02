# Notchlet Core Modules

## Free modules
### Calendar
Features a complex 3-column horizontal layout separated by 80%-height secondary color dividers:
1. **Grid Window**: An interactive monthly calendar grid with scrolling capabilities. 
    - The clickable hit area (padding/radius) for month switching arrows is expanded for easier clicking.
    - Clicking a specific date will show the events for that date.
    - A calendar icon is shown below, **aligned to the right** of the calendar month subwindow, to quickly launch the actual macOS Calendar app.
2. **Next Window**: Displays the immediate next event.
    - Shows the location of the event in secondary text.
    - If the event is online and within 10 minutes, a Join button is shown (opens in default browser, secondary color background).
    - Time parsing: shows "In xx minutes" if `< 60` minutes away, or the exact start time otherwise. This time string is displayed **below** the join button if it exists.
3. **Upcoming Window**: Displays the subsequent event using the exact same dynamic time and location logic.
4. **Compact State (Menu Bar)**: When the notch is collapsed and an event is within schedule, the meeting name (truncated to 50 characters) is shown in the right side of the menu bar next to the time.

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

