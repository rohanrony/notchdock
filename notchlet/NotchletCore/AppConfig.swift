import SwiftUI

struct AppConfig {
    static let shared = AppConfig()
    
    private var config: [String: [String: Any]] = [:]
    
    private init() {
        if let url = Bundle.main.url(forResource: "AppConfig", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
            self.config = json
        }
    }
    
    // Helper to get a value with a default fallback
    func value<T>(for category: String, key: String, default: T) -> T {
        guard let cat = config[category],
              let entry = cat[key] as? [String: Any],
              let val = entry["value"] as? T else {
            return `default`
        }
        return val
    }
    
    // Static accessors for convenience
    struct App {
        static let defaultNotchWidth: CGFloat = CGFloat(AppConfig.shared.value(for: "app", key: "default_notch_width", default: 190.0))
        static let defaultMenuBarHeight: CGFloat = CGFloat(AppConfig.shared.value(for: "app", key: "default_menu_bar_height", default: 32.0))
        static let fallbackMenuBarHeight: CGFloat = CGFloat(AppConfig.shared.value(for: "app", key: "fallback_menu_bar_height", default: 24.0))
        static let homeViewLimit: Int = AppConfig.shared.value(for: "app", key: "home_view_limit", default: 5)
        static let panelWidth: CGFloat = CGFloat(AppConfig.shared.value(for: "app", key: "panel_width", default: 400.0))
        static let iconSlotWidth: CGFloat = CGFloat(AppConfig.shared.value(for: "app", key: "icon_slot_width", default: 32.0))
        static let barPadding: CGFloat = CGFloat(AppConfig.shared.value(for: "app", key: "bar_padding", default: 16.0))
        static let notchBreathingRoom: CGFloat = CGFloat(AppConfig.shared.value(for: "app", key: "notch_breathing_room", default: 8.0))
        static let maxExpandedWidth: CGFloat = CGFloat(AppConfig.shared.value(for: "app", key: "max_expanded_width", default: 700.0))
    }
    
    struct Calendar {
        static let minimizedThreshold: Int = AppConfig.shared.value(for: "calendar", key: "minimized_threshold", default: 60)
        static let ongoingThreshold: Int = AppConfig.shared.value(for: "calendar", key: "ongoing_transition_threshold", default: 10)
        static let upcomingCount: Int = AppConfig.shared.value(for: "calendar", key: "upcoming_events_count", default: 3)
        static let expandedMinWidth: CGFloat = CGFloat(AppConfig.shared.value(for: "calendar", key: "expanded_min_width", default: 560.0))
    }
    
    struct Timer {
        static let defaultDuration: Int = AppConfig.shared.value(for: "timer", key: "default_duration", default: 25)
        static let chimeDelay: Double = AppConfig.shared.value(for: "timer", key: "alarm_chime_delay", default: 0.4)
        static let expandedMinWidth: CGFloat = CGFloat(AppConfig.shared.value(for: "timer", key: "expanded_min_width", default: 260.0))
    }
    
    struct Music {
        static let expandedMinWidth: CGFloat = CGFloat(AppConfig.shared.value(for: "music", key: "expanded_min_width", default: 320.0))
    }
}
