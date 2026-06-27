// MomentEntry.swift
// Moments
//
// Core SwiftData model. Single source of truth for all entry data.
// No widget DTO needed in v1 — add in v1.1 alongside WidgetKit extension.

import SwiftData
import SwiftUI
import UserNotifications

// MARK: - Enums

enum Recurrence: String, Codable, CaseIterable {
    case none      = "none"
    case weekly    = "weekly"
    case monthly   = "monthly"
    case quarterly = "quarterly"
    case yearly    = "yearly"

    /// Label shown in the ledger list row subtitle.
    var listLabel: String {
        switch self {
        case .none:      return ""          // handled separately as "Upcoming"/"Ongoing"
        case .weekly:    return "Weekly"
        case .monthly:   return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly:    return "Yearly"
        }
    }

    /// Label shown on the detail screen recurrence pill.
    var detailLabel: String {
        switch self {
        case .none:      return ""
        case .weekly:    return "Repeats weekly"
        case .monthly:   return "Repeats monthly"
        case .quarterly: return "Repeats quarterly"
        case .yearly:    return "Repeats yearly"
        }
    }

    /// Label shown on the chip button in AddEditScreen.
    var chipLabel: String {
        switch self {
        case .none:      return "Never"
        case .weekly:    return "Weekly"
        case .monthly:   return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly:    return "Yearly"
        }
    }
}

enum Direction: String, Codable {
    case down = "down"  // counting DOWN to a future event
    case up   = "up"    // counting UP from a past event
}

enum ReminderDays: Int, Codable, CaseIterable, Identifiable {
    case none      = 0
    case oneDay    = 1
    case threeDays = 3
    case oneWeek   = 7
    case twoWeeks  = 14

    var id: Int { rawValue }

    var chipLabel: String {
        switch self {
        case .none:      return "None"
        case .oneDay:    return "1 day before"
        case .threeDays: return "3 days before"
        case .oneWeek:   return "1 week before"
        case .twoWeeks:  return "2 weeks before"
        }
    }

    var confirmationLabel: String {
        switch self {
        case .none:      return ""
        case .oneDay:    return "1 day before"
        case .threeDays: return "3 days before"
        case .oneWeek:   return "1 week before"
        case .twoWeeks:  return "2 weeks before"
        }
    }
}

// MARK: - MomentEntry

@Model
final class MomentEntry {
    var id: UUID
    var title: String
    /// Anchor date. For recurring entries the next occurrence is computed from this.
    var date: Date
    var recurrence: Recurrence
    var direction: Direction
    /// Premium: id into MAccentColor.all. Defaults to "clay".
    var accentID: String
    /// Premium: emoji string. nil = no icon.
    var icon: String?
    /// Reminder: days before event to notify. 0 = no reminder.
    var reminderDays: Int
    /// Non-nil when this entry is pinned as hero. Cleared after 7 days.
    var pinnedAt: Date?

    init(
        title: String,
        date: Date,
        recurrence: Recurrence = .none,
        direction: Direction = .down,
        accentID: String = "clay",
        icon: String? = nil,
        reminderDays: Int = 0
    ) {
        self.id           = UUID()
        self.title        = title
        self.date         = date
        self.recurrence   = recurrence
        self.direction    = direction
        self.accentID     = accentID
        self.icon         = icon
        self.reminderDays = reminderDays
        self.pinnedAt     = nil
    }
}

// MARK: - Computed Properties

extension MomentEntry {

    /// The next meaningful occurrence date.
    /// Non-recurring entries return the anchor date as-is.
    /// Recurring entries advance until >= today.
    var nextOccurrence: Date {
        let cal = Calendar.current
        let now = Date()
        var candidate = date
        guard recurrence != .none else { return candidate }
        while candidate < now {
            switch recurrence {
            case .none:      break
            case .weekly:    candidate = cal.date(byAdding: .weekOfYear, value: 1, to: candidate)!
            case .monthly:   candidate = cal.date(byAdding: .month,      value: 1, to: candidate)!
            case .quarterly: candidate = cal.date(byAdding: .month,      value: 3, to: candidate)!
            case .yearly:    candidate = cal.date(byAdding: .year,       value: 1, to: candidate)!
            }
        }
        return candidate
    }

    /// Calendar days from today to nextOccurrence.
    /// Positive = future, negative = past.
    var daysDifference: Int {
        let cal   = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end   = cal.startOfDay(for: nextOccurrence)
        return cal.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// Absolute day count for display. Sign conveyed by isFuture/isToday.
    var diffDays: Int { abs(daysDifference) }

    var isFuture: Bool { daysDifference >= 0 }
    var isToday:  Bool { daysDifference == 0 }

    /// Formatted number + unit for display everywhere.
    var magnitude: MagnitudeResult { formatMagnitude(days: diffDays) }

    /// Sort key: ascending by proximity. Pinned entries are sorted separately
    /// by AppState before this value is used.
    var sortKey: Int { diffDays }

    /// Resolved accent color, falling back to clay if id is unrecognised.
    var accent: MAccentColor {
        MAccentColor.all.first { $0.id == accentID } ?? MAccentColor.default
    }

    /// True only when pinnedAt is within the 7-day window.
    var isValidlyPinned: Bool {
        guard let p = pinnedAt else { return false }
        return Date().timeIntervalSince(p) <= MConstants.pinDuration
    }

    /// Whole days remaining on the current pin. 0 if not pinned or expired.
    var pinDaysLeft: Int {
        guard let p = pinnedAt, isValidlyPinned else { return 0 }
        let remaining = MConstants.pinDuration - Date().timeIntervalSince(p)
        return max(0, Int(ceil(remaining / 86400)))
    }

    /// Subtitle shown in the list row below the title.
    var listSubtitle: String {
        if recurrence != .none { return recurrence.listLabel }
        return isFuture ? "Upcoming" : "Ongoing"
    }
}

// MARK: - Notification Scheduling

func scheduleReminder(for entry: MomentEntry) {
    let center = UNUserNotificationCenter.current()
    // Always clear previous notification for this entry first
    center.removePendingNotificationRequests(withIdentifiers: [entry.id.uuidString])

    guard entry.reminderDays > 0 else { return }

    let occ = entry.nextOccurrence
    let cal = Calendar.current
    guard
        let triggerDate = cal.date(byAdding: .day, value: -entry.reminderDays, to: occ),
        triggerDate > Date()
    else { return }

    let content        = UNMutableNotificationContent()
    content.title      = entry.title
    content.body       = entry.reminderDays == 1 ? "Tomorrow." : "In \(entry.reminderDays) days."
    content.sound      = .default

    let comps   = cal.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
    let request = UNNotificationRequest(identifier: entry.id.uuidString, content: content, trigger: trigger)
    center.add(request)
}

func cancelReminder(for entry: MomentEntry) {
    UNUserNotificationCenter.current()
        .removePendingNotificationRequests(withIdentifiers: [entry.id.uuidString])
}

func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
}
