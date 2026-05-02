import SwiftUI
import AppKit
import Combine
import EventKit

struct CalendarExpandedView: View {
    @ObservedObject var viewModel = CalendarViewModel.shared
    @State private var selectedGridDate: Date? = nil
    
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            
            // COLUMN 1: Calendar Grid
            VStack(alignment: .center, spacing: 8) {
                // Header
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
                
                // Days of week
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { index in
                        Text(daysOfWeek[index])
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(ThemeTokens.secondaryText)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 6-Row Date Grid
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(viewModel.daysInMonth, id: \.self) { date in
                        let isToday = viewModel.isToday(date)
                        let isSameMonth = viewModel.isSameMonth(date, viewModel.currentMonth)
                        let isSelected = selectedGridDate == date
                        
                        Text("\(viewModel.calendar.component(.day, from: date))")
                            .font(.system(size: 12, weight: isToday ? .bold : .medium))
                            .foregroundColor(isToday || isSelected ? .white : (isSameMonth ? ThemeTokens.primaryText : ThemeTokens.secondaryText.opacity(0.3)))
                            .frame(width: 24, height: 24)
                            .background(isSelected ? ThemeTokens.secondaryText.opacity(0.5) : (isToday ? ThemeTokens.accentColor : Color.clear))
                            .clipShape(Circle())
                            .onTapGesture {
                                selectedGridDate = date
                            }
                    }
                }
                
                // Launch Calendar
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
            
            // DIVIDER 1 (Covers ~80% height using vertical padding)
            Rectangle()
                .fill(ThemeTokens.secondaryText.opacity(0.2))
                .frame(width: 1)
                .padding(.vertical, 16)
            
            // COLUMN 2: Next Event
            VStack(alignment: .leading, spacing: 6) {
                Text("Next")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeTokens.secondaryText)
                    .textCase(.uppercase)
                
                if let event = viewModel.nextEvent {
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeTokens.primaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let location = event.location {
                        Text(location)
                            .font(.system(size: 12))
                            .foregroundColor(ThemeTokens.secondaryText)
                    }
                    
                    Text(viewModel.formatTimeString(for: event.startDate))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ThemeTokens.accentColor)

                    if let minutes = viewModel.minutesUntil(event: event), minutes <= 10, let link = event.meetingLink {
                        Button(action: {
                            NSWorkspace.shared.open(link)
                        }) {
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
                    
                    if let notes = event.notes {
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
            
            // COLUMN 3: Upcoming Event
            VStack(alignment: .leading, spacing: 6) {
                Text("Upcoming")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeTokens.secondaryText)
                    .textCase(.uppercase)
                
                if !viewModel.upcomingEvents.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.upcomingEvents) { event in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(ThemeTokens.primaryText)
                                        .lineLimit(1)
                                    
                                    Text(viewModel.formatTimeString(for: event.startDate))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(ThemeTokens.accentColor)
                                    
                                    if let location = event.location {
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
                    Text("No Events")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeTokens.secondaryText)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .fixedSize(horizontal: false, vertical: true) // Prevents the grid from clipping vertically
    }
}

struct CalendarCompactView: View {
    @ObservedObject var viewModel = CalendarViewModel.shared
    
    var body: some View {
        HStack(spacing: 0) {
            // LEFT SIDE (Tightly hugs text)
            if let event = viewModel.nextEvent,
               let mins = viewModel.minutesUntil(event: event),
               mins <= 20 {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(ThemeTokens.primaryText)
                    
                    let title = event.title
                    let truncatedTitle = title.count > 50 ? String(title.prefix(50)) + "..." : title
                    Text(truncatedTitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(ThemeTokens.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                        .minimumScaleFactor(0.8)
                }
                .padding(.trailing, 8)
            }
            
            // CENTER NOTCH (Aligned to absolute screen center)
            Spacer()
                .frame(width: 190)
                .alignmentGuide(.notchCenter) { d in d[HorizontalAlignment.center] }
            
            // RIGHT SIDE (Tightly hugs text)
            Text(viewModel.formatTimeString(for: viewModel.nextEvent?.startDate))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(ThemeTokens.primaryText)
                .padding(.leading, 8)
        }
    }
}

struct CalendarModule: NotchletExtension {
    var id: String = "com.notchlet.calendar"
    var displayName: String = "Calendar"
    var iconName: String = "calendar"
    
    var isPremium: Bool = false
    var productID: String? = nil
    var hasRequiredPermissions: Bool = true
    
    var compactView: AnyView {
        AnyView(CalendarCompactView())
    }
    
    var expandedView: AnyView {
        AnyView(CalendarExpandedView())
    }
}

// MARK: - ViewModel

class CalendarViewModel: ObservableObject {
    static let shared = CalendarViewModel()
    
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date = Date()
    
    // Using simple structs for mock data first before EKEvent
    struct MockEvent: Identifiable {
        let id = UUID()
        let title: String
        let startDate: Date
        let location: String?
        let notes: String?
        let meetingLink: URL?
        
        var isOnlineMeeting: Bool {
            return meetingLink != nil
        }
    }
    
    @Published var nextEvent: MockEvent?
    @Published var upcomingEvents: [MockEvent] = []
    
    private init() {
        setupMockData()
    }
    
    private func setupMockData() {
        // Next event in 8 minutes (online, to test join button)
        nextEvent = MockEvent(
            title: "Product Sync",
            startDate: Date().addingTimeInterval(8 * 60),
            location: "Zoom",
            notes: "Reviewing the roadmap for Q3 and discussed potential bottlenecks.",
            meetingLink: URL(string: "https://zoom.us/j/123456789")
        )
        
        // Upcoming events in the next 6 days
        let day: TimeInterval = 24 * 60 * 60
        upcomingEvents = [
            MockEvent(
                title: "Design Review",
                startDate: Date().addingTimeInterval(120 * 60),
                location: "Conference Room B",
                notes: "Discussing the new dark mode tokens.",
                meetingLink: nil
            ),
            MockEvent(
                title: "One-on-One",
                startDate: Date().addingTimeInterval(day + 3600),
                location: "Cafeteria",
                notes: nil,
                meetingLink: nil
            ),
            MockEvent(
                title: "Weekly Planning",
                startDate: Date().addingTimeInterval(2 * day + 18000),
                location: "Google Meet",
                notes: "Bring your individual task lists.",
                meetingLink: URL(string: "https://meet.google.com/abc-defg-hij")
            )
        ]
    }
    
    func formatTimeString(for date: Date?) -> String {
        guard let date = date else { return "No upcoming events" }
        let diff = date.timeIntervalSinceNow
        let calendar = Calendar.current
        
        if diff > 0 && diff < 3600 { // Less than 60 minutes away
            let minutes = Int(diff / 60)
            return "In \(minutes)m"
        } else {
            let formatter = DateFormatter()
            if calendar.isDateInToday(date) {
                formatter.timeStyle = .short
                return formatter.string(from: date)
            } else {
                // Date format: Day of week (3 chars) followed by time
                formatter.dateFormat = "EEE h:mm a"
                return formatter.string(from: date)
            }
        }
    }
    
    func minutesUntil(event: MockEvent?) -> Int? {
        guard let date = event?.startDate else { return nil }
        let diff = date.timeIntervalSinceNow
        if diff > 0 {
            return Int(diff / 60)
        }
        return nil
    }
    
    // MARK: - Calendar Grid Helpers
    let calendar = Calendar.current
    
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        var dates: [Date] = []
        var currentDate = monthInterval.start
        
        // Find the first Sunday before the month start to align the grid
        let firstWeekday = calendar.component(.weekday, from: currentDate)
        let offsetDays = firstWeekday - 1
        
        if let startGridDate = calendar.date(byAdding: .day, value: -offsetDays, to: currentDate) {
            currentDate = startGridDate
        }
        
        // Add 42 days (6 rows of 7 days) to ensure a stable grid height
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
        }
    }
    
    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .month)
    }
    
    func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
}
