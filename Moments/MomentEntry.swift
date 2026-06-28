// MomentEntry.swift
// Moments
//
// Core SwiftData model. Single source of truth for all entry data.

import SwiftData
import SwiftUI

// MARK: - Enums

enum Recurrence: String, Codable, CaseIterable {
    case none      = "none"
    case weekly    = "weekly"
    case monthly   = "monthly"
    case quarterly = "quarterly"
    case yearly    = "yearly"

    var listLabel: String {
        switch self {
        case .none:      return ""
        case .weekly:    return "Weekly"
        case .monthly:   return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly:    return "Yearly"
        }
    }

    var detailLabel: String {
        switch self {
        case .none:      return ""
        case .weekly:    return "Repeats weekly"
        case .monthly:   return "Repeats monthly"
        case .quarterly: return "Repeats quarterly"
        case .yearly:    return "Repeats yearly"
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

enum Direction: String, Codable {
    case down = "down"
    case up   = "up"
}

// MARK: - MomentEntry

@Model
final class MomentEntry {
    var id: UUID
    var title: String
    var date: Date
    var recurrence: Recurrence
    var direction: Direction
    var pinnedAt: Date?

    init(
        title: String,
        date: Date,
        recurrence: Recurrence = .none,
        direction: Direction = .down
    ) {
        self.id         = UUID()
        self.title      = title
        self.date       = date
        self.recurrence = recurrence
        self.direction  = direction
        self.pinnedAt   = nil
    }
}

// MARK: - Computed Properties

extension MomentEntry {

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

    var daysDifference: Int {
        let cal   = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end   = cal.startOfDay(for: nextOccurrence)
        return cal.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var diffDays: Int { abs(daysDifference) }

    var isFuture: Bool { daysDifference >= 0 }
    var isToday:  Bool { daysDifference == 0 }

    var magnitude: MagnitudeResult { formatMagnitude(days: diffDays) }

    var sortKey: Int { diffDays }

    var isValidlyPinned: Bool {
        guard let p = pinnedAt else { return false }
        return Date().timeIntervalSince(p) <= MConstants.pinDuration
    }

    var pinDaysLeft: Int {
        guard let p = pinnedAt, isValidlyPinned else { return 0 }
        let remaining = MConstants.pinDuration - Date().timeIntervalSince(p)
        return max(0, Int(ceil(remaining / 86400)))
    }

    var listSubtitle: String {
        if recurrence != .none { return recurrence.listLabel }
        return isFuture ? "Upcoming" : "Ongoing"
    }
}
