// MomentEntry.swift
// Moments
//
// Core data model. Single source of truth for all entry data.
// Persisted via SwiftData. Shared to widgets via App Group UserDefaults.

import SwiftData
import SwiftUI

// MARK: - Recurrence

enum Recurrence: String, Codable, CaseIterable {
    case none       = "none"
    case weekly     = "weekly"
    case monthly    = "monthly"
    case quarterly  = "quarterly"
    case yearly     = "yearly"

    var label: String {
        switch self {
        case .none:      return "Doesn't repeat"
        case .weekly:    return "Weekly"
        case .monthly:   return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly:    return "Yearly"
        }
    }

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

// MARK: - Direction

enum Direction: String, Codable {
    case down = "down"  // counting down to a future event
    case up   = "up"    // counting up from a past event
}

// MARK: - Reminder

enum ReminderDays: Int, Codable, CaseIterable, Identifiable {
    case none      = 0
    case oneDay    = 1
    case threeDays = 3
    case oneWeek   = 7
    case twoWeeks  = 14

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .none:      return "None"
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
    /// The anchor date. For recurring events, this is the original date;
    /// next occurrence is computed dynamically.
    var date: Date
    var recurrence: Recurrence
    var direction: Direction
    /// Premium: accent color id from AccentColor.all. Defaults to "clay".
    var accentID: String
    /// Premium: emoji icon string. Optional.
    var icon: String?
    /// Reminder: days before the event to notify. 0 = no reminder.
    var reminderDays: Int
    /// Timestamp when this entry was pinned as hero. Nil if not pinned.
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
    /// For non-recurring past events this is the original anchor date.
    /// For recurring events this advances until it's >= today.
    var nextOccurrence: Date {
        let cal = Calendar.current
        let now = Date()
        var candidate = date
        guard recurrence != .none else { return candidate }
        while candidate < now {
            switch recurrence {
            case .none:      break
            case .weekly:    candidate = cal.date(byAdding: .weekOfYear, value: 1, to: candidate)!
            case .monthly:   candidate = cal.date(byAdding: .month, value: 1, to: candidate)!
            case .quarterly: candidate = cal.date(byAdding: .month, value: 3, to: candidate)!
            case .yearly:    candidate = cal.date(byAdding: .year,  value: 1, to: candidate)!
            }
        }
        return candidate
    }

    /// Difference in calendar days between today and nextOccurrence.
    /// Positive = future, negative = past (for non-recurring count-up entries).
    var daysDifference: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end   = cal.startOfDay(for: nextOccurrence)
        return cal.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// Absolute days for display. The sign is conveyed by isFuture/isToday.
    var diffDays: Int { abs(daysDifference) }

    /// True when nextOccurrence is in the future (or today).
    var isFuture: Bool { daysDifference >= 0 }

    /// True when diffDays == 0. This triggers the special "Today" display state.
    var isToday: Bool { daysDifference == 0 }

    /// Formatted magnitude for display.
    var magnitude: FormattedMagnitude { formatMagnitude(days: diffDays) }

    /// Sort key: always ascending by absolute proximity.
    var sortKey: Int { diffDays }

    /// Returns the AccentColor for this entry, falling back to clay.
    var accent: AccentColor {
        AccentColor.all.first { $0.id == accentID } ?? AccentColor.default
    }

    /// True if this entry is currently pinned and the pin hasn't expired.
    var isValidlyPinned: Bool {
        guard let p = pinnedAt else { return false }
        return Date().timeIntervalSince(p) <= MConstants.pinDurationSeconds
    }

    /// Days remaining on the pin. 0 if expired or not pinned.
    var pinDaysLeft: Int {
        guard let p = pinnedAt, isValidlyPinned else { return 0 }
        let remaining = MConstants.pinDurationSeconds - Date().timeIntervalSince(p)
        return max(0, Int(ceil(remaining / 86400)))
    }
}

// MARK: - App Group / Widget Data Transfer
// Write a lightweight DTO to UserDefaults(suiteName:) whenever entries change.
// The widget reads this directly — it cannot access SwiftData.

struct WidgetEntryDTO: Codable {
    let title: String
    let diffDays: Int
    let isFuture: Bool
    let isToday: Bool
    let isPinned: Bool
    let accentHex: String
}

func writeHeroToAppGroup(entry: MomentEntry, isPinned: Bool) {
    let dto = WidgetEntryDTO(
        title:     entry.title,
        diffDays:  entry.diffDays,
        isFuture:  entry.isFuture,
        isToday:   entry.isToday,
        isPinned:  isPinned,
        accentHex: entry.accent.hex
    )
    guard
        let defaults = UserDefaults(suiteName: MConstants.appGroupID),
        let data = try? JSONEncoder().encode(dto)
    else { return }
    defaults.set(data, forKey: MConstants.widgetDataKey)
}

// MARK: - Notification Scheduling

import UserNotifications

func scheduleReminder(for entry: MomentEntry) {
    guard entry.reminderDays > 0 else {
        // Clear any existing notification for this entry
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [entry.id.uuidString])
        return
    }
    let occ = entry.nextOccurrence
    let cal = Calendar.current
    guard let triggerDate = cal.date(byAdding: .day, value: -entry.reminderDays, to: occ),
          triggerDate > Date()
    else { return }

    let content = UNMutableNotificationContent()
    content.title = entry.title
    content.body = entry.reminderDays == 1
        ? "Tomorrow."
        : "In \(entry.reminderDays) days."
    content.sound = .default

    let components = cal.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    let request = UNNotificationRequest(identifier: entry.id.uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request)
}

func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
        DispatchQueue.main.async { completion(granted) }
    }
}
