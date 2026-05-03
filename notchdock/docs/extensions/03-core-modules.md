# NotchDock Core Modules

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
4. **Compact State (Menu Bar)**: When the notch is collapsed and an event is within the threshold (default 60m), the event title is shown to the left of the notch, and the countdown/time to the right. While an event is ongoing, the display transitions to the next event 10 minutes before it starts.

### Quick Access
Maintain a history of snippets and notes for quick retrieval and insertion. Supports editable headings and persistent storage.

### ToDo List
A lightweight, interactive task manager. Tasks can be checked, added inline, and reordered.

### Timer
Offer quick countdown presets such as 15, 25, and 50 minutes, plus manual time entry.

### Music
Provide a premium now playing display and transport controls for Apple Music or Spotify. Features dynamic color extraction from artwork and a responsive music visualizer.

## Module behavior
Each module must have:
- Compact island state.
- Expanded panel state utilizing a highly compact vertical layout.
- Horizontal alignment (HStack) is preferred for internal content (like Music and Timer) to minimize vertical height.
- **Minimalist Headlines**: Redundant titles like "Ask Claude" or "Focus" should be omitted. However, modules like "Quick Access" may use a small, 1/3-width editable heading for context.
- Settings state if needed.
- Clear empty states.
- Clear permission or auth states.

## Non-goals
- No AI transform buttons on snippets.
- No full music library management.
- No complex project management in ToDo.

## Upgrade paths (See 08-monetization)
- **Quick Access**: Upgrade to **Pinboard** ($1) to save favorite snippets permanently.
- **Timer**: Upgrade to **Pomodoro+** ($1) for detailed focus statistics and custom sounds.
- **ToDo**: Upgrade to **Multi-List** ($1) for categorized task management.

## Permission requirements
- **Calendar**: Requires `NSCalendarUsageDescription` (EventKit).
- **Music**: Requires `NSAppleMusicUsageDescription` (MediaRemote).
- **Quick Access**: Requires sandbox exceptions for Apple Events to restore items.
