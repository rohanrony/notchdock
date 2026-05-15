# Calendar Module Specification

The Calendar module integrates with the macOS EventKit framework to display real Apple Calendar events and **Scheduled Reminders** directly in the notch.

## 1. Permission Model
The module requires `NSCalendarUsageDescription` and `NSRemindersUsageDescription` in `Info.plist` and uses `EKEventStore` to request access to both events and reminders.

| Status | Behavior |
|---|---|
| `.notDetermined` | Expanded view shows a prompt with an "Allow Access" button. Settings tab shows a connection card. |
| `.authorized` / `.fullAccess` | Events and reminders fetched and displayed. `hasRequiredPermissions` returns `true`. |
| `.denied` | "Open Settings" button deep-links to `x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars`. |
| `.restricted` | Shows a "Restricted by policy" message with no action. |

### API Availability
- macOS 14+: `requestFullAccessToEvents(completion:)`
- macOS 13 (fallback): `requestAccess(to: .event, completion:)`

---

## 2. Visual States

### 2.1 Compact State (Island)
Shown only when the next event is within the user-configured **threshold (5-120 minutes)** or is currently ongoing:
- **Left of Notch**: Calendar icon + truncated event title.
- **Right of Notch**: Time string (e.g., "In 8m", "2:30 PM") or "Ongoing" if the event is in progress.
- While an event is ongoing, the display switches to show the **next** upcoming event exactly **10 minutes** before its start time.


### 2.2 Expanded State (Panel)
A 3-column horizontal layout:

**Column 1 — Month Grid**
- Monthly calendar grid with 6 rows × 7 days, always starting on Sunday.
- Today highlighted with the olive accent color.
- Selected date shown with a secondary translucent circle.
- Dates with events display a small olive dot indicator below the date number.
- Tapping a date loads events for that day into Columns 2 and 3.
- Chevron buttons navigate between months.
- A calendar icon at the bottom right opens the macOS Calendar app via `ical://`.

**Column 2 — Current/Next Event**
- Shows the primary event. The header dynamically changes to **"CURRENT"** if an event is ongoing, or **"NEXT"** otherwise.
- Displays: Title, Location, Formatted time, Notes (3-line max).
- If the event is within **10 minutes** and has a meeting link (Zoom, Google Meet, Teams, Webex — parsed from `event.url` or `event.notes`), a "Join Meeting" button is displayed.

**Column 3 — Upcoming**
- Shows a unified list of upcoming items:
    - **Events**: Next 3 events after the primary event (Calendar icon).
    - **Scheduled Reminders**: Next 3 reminders with due dates (Bell icon).
- Scrollable list with Title and Formatted time.

### 2.3 Permission Guard
When access is not granted, the expanded panel is replaced by a centered prompt card with an icon, description text, and an action button. This ensures the module is always gracefully handled.

---

## 3. Settings View (`CalendarSettingsView`)

A dedicated tab in the Settings sidebar when the Calendar module is enabled.

### Connection Card
A status card that dynamically adapts:
- **Not Connected**: "Allow Access" button triggers the system permission prompt.
- **Connected**: Green checkmark seal, "Connected" status, no action button.
- **Denied**: Red X seal, "Access Denied" with an "Open Settings" button linking to System Preferences Privacy pane.

### Calendars & Lists (Visible when Connected)
- **Visible Calendars**: A list of all discovered system calendars with toggles.
- **Scheduled Reminders**: A list of all discovered system reminder lists with toggles.
- Colors and titles are preserved from system settings.

### Thresholds Section
- **Show Next Event in minimized Notch**: Slider to configure how early an upcoming event appears (5-120 minutes).
- **Ongoing Transition**: Fixed 10-minute logic that overrides an ongoing event display with the next upcoming one.

---

## 4. Data & Logic

### Event & Reminder Fetching
- Events and reminders are fetched for the **next 7 days** from `Date()`.
- Results are filtered by the **Visible Calendars** and **Reminder Lists** selected in Settings.
- Events are sorted ascending by `startDate`.
- Reminders are sorted ascending by `dueDate`.
- The first event result is assigned to `nextEvent`, the next 3 to `upcomingEvents`.
- The next 3 reminders with due dates are assigned to `upcomingReminders`.
- A `Timer` refreshes data every **60 seconds** to keep the display current.

### Event Dot Caching
- On each month navigation, all event dates in that month are fetched and stored as a `Set<String>` (`"yyyy-MM-dd"` format) for O(1) lookup during grid rendering.

### Meeting Link Detection
Priority order for meeting URLs:
1. `event.url` field
2. Notes field scanned for: `zoom.us`, `meet.google.com`, `teams.microsoft.com`, `webex.com`

---

## 5. Architecture

| Component | Type |
|---|---|
| `CalendarViewModel` | `ObservableObject` Singleton |
| `EKEventStore` | Shared instance on the ViewModel |
| `CalendarExpandedView` | Full panel with permission guard |
| `CalendarCompactView` | Compact notch bar display |
| `CalendarSettingsView` | Settings tab with permission flow |
| `CalendarModule` | `NotchDockExtension` conformance |

### `hasRequiredPermissions`
Computed at runtime from `EKEventStore.authorizationStatus(for: .event)`. Returns `true` for `.authorized` and `.fullAccess`. When `false`, the `safeExpandedView()` wrapper shows the standard "Access Required" message.

---

## 6. Future Roadmap
- Event creation shortcut from the expanded view.
- Support for event alerts and notifications.
- Configurable "Upcoming" window: today only vs. 7-day vs. 30-day.
- Drag-and-drop support for reordering reminders.
