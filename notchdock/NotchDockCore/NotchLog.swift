import Foundation
import os.log

enum NotchLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.notchdock.app"
    
    static let general = OSLog(subsystem: subsystem, category: "General")
    static let security = OSLog(subsystem: subsystem, category: "Security")
    static let music = OSLog(subsystem: subsystem, category: "Music")
    
    static func info(_ message: String, category: OSLog = .default) {
        os_log("%{public}@", log: category, type: .info, message)
    }
    
    static func error(_ message: String, category: OSLog = .default) {
        os_log("%{public}@", log: category, type: .error, message)
    }
    
    /// Logs sensitive data using private formatting to ensure it is redacted in system logs.
    static func sensitive(_ message: String, category: OSLog = .default) {
        os_log("%{private}@", log: category, type: .debug, message)
    }
}
