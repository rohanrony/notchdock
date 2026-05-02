import SwiftUI
import AppKit
import Combine
import EventKit

// MARK: - Expanded View

struct CalendarExpandedView: View {
    @ObservedObject var viewModel = CalendarViewModel.shared
    @State private var selectedGridDate: Date? = nil

    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        calendarContentView
            .onAppear {
                selectedGridDate = nil
                viewModel.resetToToday()
            }
    }


    @ViewBuilder
    var calendarContentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 20) {

                // COLUMN 1: Calendar Grid
                VStack(alignment: .center, spacing: 8) {
                    HStack {
                        Button(action: { viewModel.previousMonth() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(ThemeTokens.secondaryText)
                                .padding(8)
                                .contentShape(Rectangle())
                        }.buttonStyle(.plain)

                        Spacer()
                        Text(viewModel.monthString)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ThemeTokens.primaryText)
                        Spacer()

                        Button(action: { viewModel.nextMonth() }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(ThemeTokens.secondaryText)
                                .padding(8)
                                .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                    .padding(.bottom, 4)

                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { index in
                            Text(daysOfWeek[index])
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(ThemeTokens.secondaryText)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(viewModel.daysInMonth, id: \.self) { date in
                            let isToday = viewModel.isToday(date)
                            let isSameMonth = viewModel.isSameMonth(date, viewModel.currentMonth)
                            let isSelected = selectedGridDate.map { viewModel.calendar.isDate($0, inSameDayAs: date) } ?? false
                            let hasEvents = viewModel.hasEvents(on: date)

                            ZStack(alignment: .bottom) {
                                Text("\(viewModel.calendar.component(.day, from: date))")
                                    .font(.system(size: 12, weight: isToday ? .bold : .medium))
                                    .foregroundColor(isToday || isSelected ? .white : (isSameMonth ? ThemeTokens.primaryText : ThemeTokens.secondaryText.opacity(0.3)))
                                    .frame(width: 24, height: 24)
                                    .background(isSelected ? ThemeTokens.secondaryText.opacity(0.5) : (isToday ? ThemeTokens.accentColor : Color.clear))
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        selectedGridDate = date
                                        viewModel.loadEvents(for: date)
                                    }

                                if hasEvents {
                                    Circle()
                                        .fill(isToday ? Color.white : ThemeTokens.accentColor.opacity(0.7))
                                        .frame(width: CalendarViewModel.Constants.dotIndicatorSize, height: CalendarViewModel.Constants.dotIndicatorSize)
                                        .offset(y: CalendarViewModel.Constants.dotIndicatorOffset)
                                }
                            }
                            .frame(height: 28)
                        }
                    }

                    HStack {
                        Spacer()
                        Button(action: {
                            if let url = URL(string: "ical://") {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeTokens.secondaryText)
                                .padding(.top, 4)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: 200)

                // DIVIDER 1
                Rectangle()
                    .fill(ThemeTokens.secondaryText.opacity(0.2))
                    .frame(width: 1)
                    .padding(.vertical, 16)

                // COLUMN 2: Current/Next Event
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.nextEventLabel)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeTokens.secondaryText)
                        .textCase(.uppercase)

                    if let event = viewModel.nextEvent {
                        Text(event.title ?? "Untitled")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ThemeTokens.primaryText)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let location = event.location, !location.isEmpty {
                            Text(location)
                                .font(.system(size: 12))
                                .foregroundColor(ThemeTokens.secondaryText)
                        }

                        Text(viewModel.formatTimeString(for: event.startDate))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeTokens.accentColor)

                        if let url = viewModel.meetingURL(for: event),
                           let mins = viewModel.minutesUntil(event: event),
                           mins <= CalendarViewModel.Constants.meetingJoinThreshold {
                            Button(action: { NSWorkspace.shared.open(url) }) {
                                Text("Join Meeting")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(ThemeTokens.secondaryText)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }

                        if let notes = event.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.system(size: 11))
                                .foregroundColor(ThemeTokens.secondaryText)
                                .lineLimit(3)
                                .padding(.top, 4)
                        }
                    } else {
                        Text("No Events")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeTokens.secondaryText)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // DIVIDER 2
                Rectangle()
                    .fill(ThemeTokens.secondaryText.opacity(0.2))
                    .frame(width: 1)
                    .padding(.vertical, 16)

                // COLUMN 3: Upcoming Events
                VStack(alignment: .leading, spacing: 6) {
                    Text("Upcoming")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeTokens.secondaryText)
                        .textCase(.uppercase)

                    if !viewModel.upcomingEvents.isEmpty {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.upcomingEvents, id: \.eventIdentifier) { event in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(event.title ?? "Untitled")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(ThemeTokens.primaryText)
                                            .lineLimit(1)

                                        Text(viewModel.formatTimeString(for: event.startDate))
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(ThemeTokens.accentColor)

                                        if let location = event.location, !location.isEmpty {
                                            Text(location)
                                                .font(.system(size: 11))
                                                .foregroundColor(ThemeTokens.secondaryText)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        Text("No Upcoming Events")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeTokens.secondaryText)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, viewModel.isAuthorized ? 24 : 8)
            .fixedSize(horizontal: false, vertical: true)

            // Permission note at the bottom
            if !viewModel.isAuthorized {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                    Button(action: {
                        if viewModel.authorizationStatus == .notDetermined {
                            viewModel.requestPermission()
                        } else {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    }) {
                        Text(viewModel.authorizationStatus == .notDetermined
                             ? "Calendar access not granted. Tap to allow."
                             : "Calendar access denied. Open Settings to fix.")
                            .font(.system(size: 11, weight: .medium))
                            .underline()
                    }
                    .buttonStyle(.plain)
                }
                .foregroundColor(.red)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
    }
}

// MARK: - Compact View

struct CalendarCompactView: View {
    @ObservedObject var viewModel = CalendarViewModel.shared

    var body: some View {
        HStack(spacing: 0) {
            // LEFT SIDE: Event Title (if within threshold or ongoing)
            if let event = viewModel.nextEvent, viewModel.shouldShowCompactDetails {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(ThemeTokens.primaryText)

                    let title = event.title ?? "Untitled"
                    let limit = CalendarViewModel.Constants.maxCompactTitleLength
                    let truncatedTitle = title.count > limit ? String(title.prefix(limit)) + "..." : title
                    Text(truncatedTitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(ThemeTokens.primaryText)
                        .lineLimit(1)
                }
                .padding(.trailing, 8)
            }

            Spacer()
                .frame(width: 190)
                .alignmentGuide(.notchCenter) { d in d[HorizontalAlignment.center] }

            // RIGHT SIDE: Time (if within threshold or ongoing)
            if viewModel.nextEvent != nil && viewModel.shouldShowCompactDetails {
                Text(viewModel.compactTimeText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ThemeTokens.accentColor)
                    .padding(.leading, 8)
            }
        }
    }
}

// MARK: - Settings View

struct CalendarSettingsView: View {
    @ObservedObject var viewModel = CalendarViewModel.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Calendar Settings")
                    .font(.title2)
                    .bold()

                // Permission Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Apple Calendar Access")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Image(systemName: permissionIcon)
                            .font(.system(size: 28))
                            .foregroundColor(permissionColor)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(permissionTitle)
                                .font(.subheadline)
                                .bold()
                            Text(permissionDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        permissionButton
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(10)
                }

                if viewModel.isAuthorized {
                    Divider()

                    // Calendar selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Visible Calendars")
                                .font(.headline)
                            Spacer()
                            HStack(spacing: 12) {
                                Button("Select All") { viewModel.selectAllCalendars() }
                                    .buttonStyle(.link)
                                    .font(.caption)
                                Button("Deselect All") { viewModel.deselectAllCalendars() }
                                    .buttonStyle(.link)
                                    .font(.caption)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(viewModel.availableCalendars, id: \.calendarIdentifier) { cal in
                                Toggle(isOn: Binding(
                                    get: { viewModel.enabledCalendarIDs.contains(cal.calendarIdentifier) },
                                    set: { _ in viewModel.toggleCalendar(cal.calendarIdentifier) }
                                )) {
                                    HStack {
                                        Circle()
                                            .fill(Color(nsColor: cal.color))
                                            .frame(width: 8, height: 8)
                                        Text(cal.title)
                                            .font(.subheadline)
                                    }
                                }
                                .toggleStyle(.checkbox)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(12)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(10)
                    }

                    Divider()

                    // Thresholds
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notch Display Thresholds")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Show Next Event in minimized Notch")
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text("\(viewModel.minimizedThreshold)m before")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: Binding(
                                    get: { Double(viewModel.minimizedThreshold) },
                                    set: { viewModel.minimizedThreshold = Int($0) }
                                ), in: 5...120, step: 5)
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Text("When a meeting is ongoing, Notchlet will automatically switch to showing the next event 10 minutes before it starts.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(12)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
            }
            .padding(24)
        }
    }

    // MARK: - Permission UI Helpers

    var permissionIcon: String {
        if viewModel.isAuthorized { return "checkmark.seal.fill" }
        switch viewModel.authorizationStatus {
        case .denied, .restricted: return "xmark.seal.fill"
        default: return "calendar.badge.plus"
        }
    }

    var permissionColor: Color {
        if viewModel.isAuthorized { return ThemeTokens.accentColor }
        switch viewModel.authorizationStatus {
        case .denied, .restricted: return .red
        default: return .secondary
        }
    }

    var permissionTitle: String {
        if viewModel.isAuthorized { return "Connected" }
        switch viewModel.authorizationStatus {
        case .denied: return "Access Denied"
        case .restricted: return "Restricted"
        default: return "Not Connected"
        }
    }

    var permissionDescription: String {
        if viewModel.isAuthorized {
            return "Notchlet can read your calendar events."
        }
        switch viewModel.authorizationStatus {
        case .denied:
            return "Open System Settings to allow Notchlet to access your calendar."
        case .restricted:
            return "Calendar access is restricted by a device policy."
        default:
            return "Allow Notchlet to show your upcoming events in the notch."
        }
    }

    @ViewBuilder
    var permissionButton: some View {
        let isAuthorized = viewModel.isAuthorized
        let status = viewModel.authorizationStatus
        
        if isAuthorized {
            EmptyView()
        } else if status == .denied || status == .restricted {
            Button("Open Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button("Allow Access") {
                viewModel.requestPermission()
            }
            .buttonStyle(.borderedProminent)
            .tint(ThemeTokens.accentColor)
        }
    }
}

// MARK: - Module Definition

struct CalendarModule: NotchletExtension {
    var id: String = "com.notchlet.calendar"
    var displayName: String = "Calendar"
    var iconName: String = "calendar"

    var isPremium: Bool = false
    var productID: String? = nil

    var hasRequiredPermissions: Bool {
        CalendarViewModel.shared.isAuthorized
    }

    /// 3-column layout: 200pt calendar grid + 2×dividers + 2×flexible event columns
    var expandedMinWidth: CGFloat { AppConfig.Calendar.expandedMinWidth }

    var compactView: AnyView {
        AnyView(CalendarCompactView())
    }

    var expandedView: AnyView {
        AnyView(CalendarExpandedView())
    }

    var settingsView: AnyView {
        AnyView(CalendarSettingsView())
    }
}

// MARK: - ViewModel

class CalendarViewModel: ObservableObject {
    static let shared = CalendarViewModel()
    
    struct Constants {
        static let defaultMinimizedThreshold: Int = 60
        static let defaultOngoingThreshold: Int = 10
        static let upcomingEventsCount: Int = 3
        static let maxCompactTitleLength: Int = 25
        static let refreshInterval: TimeInterval = 60
        static let daysInFutureToFetch: Int = 7
        static let meetingJoinThreshold: Int = 10
        static let dotIndicatorSize: CGFloat = 4
        static let dotIndicatorOffset: CGFloat = 14
        static let gridDaySize: CGFloat = 24
        static let gridRowHeight: CGFloat = 28
    }

    private let store = EKEventStore()

    @Published var currentMonth: Date = Date()
    @Published var authorizationStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
    @Published var nextEvent: EKEvent? = nil
    @Published var upcomingEvents: [EKEvent] = []
    @Published var availableCalendars: [EKCalendar] = []

    @AppStorage("calendar_enabled_ids") private var enabledIDsString: String = ""
    @AppStorage("calendar_minimized_threshold") var minimizedThreshold: Int = Constants.defaultMinimizedThreshold
    let ongoingThreshold: Int = Constants.defaultOngoingThreshold

    var enabledCalendarIDs: Set<String> {
        get { Set(enabledIDsString.components(separatedBy: ",").filter { !$0.isEmpty }) }
        set { enabledIDsString = newValue.joined(separator: ",") }
    }

    var isAuthorized: Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(macOS 14.0, *) {
            return status == .fullAccess
        } else {
            return status.rawValue == 3 // EKAuthorizationStatus.authorized
        }
    }

    // Cache event dates for dot indicators on the grid
    @Published var datesWithEvents: Set<String> = []

    private var refreshTimer: Timer?

    let calendar = Calendar.current

    private init() {
        if isAuthorized {
            refreshCalendars()
            fetchEvents()
            startRefreshTimer()
        }
    }

    func refreshCalendars() {
        self.availableCalendars = store.calendars(for: .event).sorted { $0.title < $1.title }
        
        // If enabledIDs is empty, enable all by default
        if enabledIDsString.isEmpty {
            enabledCalendarIDs = Set(availableCalendars.map { $0.calendarIdentifier })
        }
    }

    func toggleCalendar(_ id: String) {
        var current = enabledCalendarIDs
        if current.contains(id) {
            current.remove(id)
        } else {
            current.insert(id)
        }
        enabledCalendarIDs = current
        fetchEvents()
    }

    func selectAllCalendars() {
        enabledCalendarIDs = Set(availableCalendars.map { $0.calendarIdentifier })
        fetchEvents()
    }

    func deselectAllCalendars() {
        enabledCalendarIDs = []
        fetchEvents()
    }



    // MARK: - Permission

    func requestPermission() {
        if #available(macOS 14.0, *) {
            store.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                    if granted {
                        self?.refreshCalendars()
                        self?.fetchEvents()
                        self?.startRefreshTimer()
                    }
                }
            }
        } else {
            store.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                    if granted {
                        self?.refreshCalendars()
                        self?.fetchEvents()
                        self?.startRefreshTimer()
                    }
                }
            }
        }
    }

    // MARK: - Event Fetching

    func resetToToday() {
        currentMonth = Date()
        fetchEvents()
    }

    func fetchEvents() {
        if availableCalendars.isEmpty { refreshCalendars() }
        let now = Date()
        let endOfDay = calendar.date(byAdding: .day, value: Constants.daysInFutureToFetch, to: now) ?? now

        let enabledCalendars = availableCalendars.filter { enabledCalendarIDs.contains($0.calendarIdentifier) }
        guard !enabledCalendars.isEmpty else {
            DispatchQueue.main.async {
                self.nextEvent = nil
                self.upcomingEvents = []
            }
            return
        }

        let predicate = store.predicateForEvents(withStart: now, end: endOfDay, calendars: enabledCalendars)
        let events = store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }

        DispatchQueue.main.async {
            // Logic to handle ongoing events vs next event threshold
            if let first = events.first {

                // If the first event is ongoing
                if first.startDate <= now && (first.endDate ?? now) > now {
                    // Check if the NEXT event starts within ongoingThreshold minutes
                    if events.count > 1 {
                        let second = events[1]
                        let minsToSecond = second.startDate.timeIntervalSince(now) / 60
                        if minsToSecond <= Double(self.ongoingThreshold) {
                            // Show the second one as "Next"
                            self.nextEvent = second
                            self.upcomingEvents = Array(events.dropFirst(2).prefix(Constants.upcomingEventsCount))
                        } else {
                            self.nextEvent = first
                            self.upcomingEvents = Array(events.dropFirst().prefix(Constants.upcomingEventsCount))
                        }
                    } else {
                        self.nextEvent = first
                        self.upcomingEvents = []
                    }
                } else {
                    self.nextEvent = first
                    self.upcomingEvents = Array(events.dropFirst().prefix(Constants.upcomingEventsCount))
                }
            } else {
                self.nextEvent = nil
                self.upcomingEvents = []
            }
        }

        // Also cache all dates with events for the current month grid
        loadDatesWithEvents(for: currentMonth)
    }

    func loadEvents(for date: Date) {
        if availableCalendars.isEmpty { refreshCalendars() }
        guard let dayStart = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date),
              let dayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date) else { return }

        let enabledCalendars = availableCalendars.filter { enabledCalendarIDs.contains($0.calendarIdentifier) }
        guard !enabledCalendars.isEmpty else {
            DispatchQueue.main.async {
                self.nextEvent = nil
                self.upcomingEvents = []
            }
            return
        }
        
        let predicate = store.predicateForEvents(withStart: dayStart, end: dayEnd, calendars: enabledCalendars)
        let events = store.events(matching: predicate).sorted { $0.startDate < $1.startDate }

        DispatchQueue.main.async {
            self.nextEvent = events.first
            self.upcomingEvents = Array(events.dropFirst().prefix(Constants.upcomingEventsCount))
        }
    }

    func loadDatesWithEvents(for month: Date) {
        // Fetch for the entire 42-day grid range to cover visible days from prev/next months
        let days = daysInMonth
        guard let gridStart = days.first, let gridEnd = days.last else { return }
        
        let enabledCalendars = availableCalendars.filter { enabledCalendarIDs.contains($0.calendarIdentifier) }
        guard !enabledCalendars.isEmpty else {
            DispatchQueue.main.async { self.datesWithEvents = [] }
            return
        }

        let predicate = store.predicateForEvents(withStart: gridStart, end: gridEnd, calendars: enabledCalendars)
        let events = store.events(matching: predicate)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let dates = Set(events.map { formatter.string(from: $0.startDate) })
        DispatchQueue.main.async {
            self.datesWithEvents = dates
        }
    }

    func hasEvents(on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return datesWithEvents.contains(formatter.string(from: date))
    }

    private func startRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Constants.refreshInterval, repeats: true) { [weak self] _ in
            self?.fetchEvents()
        }
    }

    // MARK: - Meeting Link Helper

    func meetingURL(for event: EKEvent) -> URL? {
        // Check URL field
        if let url = event.url { return url }

        // Check notes for common meeting patterns
        let patterns = ["https://zoom.us", "https://meet.google.com", "https://teams.microsoft.com", "https://webex.com"]
        if let notes = event.notes {
            for pattern in patterns {
                if notes.contains(pattern),
                   let range = notes.range(of: pattern),
                   let urlEnd = notes[range.lowerBound...].firstIndex(of: "\n") {
                    let urlString = String(notes[range.lowerBound..<urlEnd])
                    return URL(string: urlString.trimmingCharacters(in: .whitespaces))
                } else if notes.contains(pattern) {
                    let words = notes.components(separatedBy: .whitespacesAndNewlines)
                    return words.compactMap { URL(string: $0) }.first(where: { $0.absoluteString.hasPrefix(pattern) })
                }
            }
        }
        return nil
    }

    // MARK: - Formatting

    func formatTimeString(for date: Date?) -> String {
        guard let date = date else { return "No upcoming events" }
        let diff = date.timeIntervalSinceNow

        if diff > 0 && diff < 3600 {
            let minutes = Int(diff / 60)
            return "In \(minutes)m"
        } else {
            let formatter = DateFormatter()
            if calendar.isDateInToday(date) {
                formatter.timeStyle = .short
                return formatter.string(from: date)
            } else {
                formatter.dateFormat = "EEE h:mm a"
                return formatter.string(from: date)
            }
        }
    }

    func minutesUntil(event: EKEvent?) -> Int? {
        guard let date = event?.startDate else { return nil }
        let diff = date.timeIntervalSinceNow
        return diff > 0 ? Int(diff / 60) : nil
    }

    var shouldShowCompactDetails: Bool {
        guard let event = nextEvent else { return false }
        let now = Date()
        let isOngoing = event.startDate <= now && (event.endDate ?? now.addingTimeInterval(3600)) > now
        let startsSoon = event.startDate.timeIntervalSince(now) <= Double(minimizedThreshold * 60) && event.startDate > now
        return isOngoing || startsSoon
    }

    var compactTimeText: String {
        guard let event = nextEvent else { return "" }
        let now = Date()
        if event.startDate <= now && (event.endDate ?? now.addingTimeInterval(3600)) > now {
            return "Ongoing"
        }
        return formatTimeString(for: event.startDate)
    }

    var nextEventLabel: String {
        guard let event = nextEvent else { return "NEXT" }
        let now = Date()
        if event.startDate <= now && (event.endDate ?? now) > now {
            return "CURRENT"
        }
        return "NEXT"
    }

    // MARK: - Calendar Grid

    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        var dates: [Date] = []
        var currentDate = monthInterval.start

        let firstWeekday = calendar.component(.weekday, from: currentDate)
        let offsetDays = firstWeekday - 1
        if let startGridDate = calendar.date(byAdding: .day, value: -offsetDays, to: currentDate) {
            currentDate = startGridDate
        }

        for _ in 0..<42 {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            }
        }
        return dates
    }

    func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            loadDatesWithEvents(for: newMonth)
        }
    }

    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            loadDatesWithEvents(for: newMonth)
        }
    }

    func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .month)
    }

    func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
}
