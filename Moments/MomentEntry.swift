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

// MARK: - MomentEntry

@Model
final class MomentEntry {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()
    var recurrence: Recurrence = Recurrence.none
    var pinnedAt: Date?

    init(
        title: String,
        date: Date,
        recurrence: Recurrence = .none
    ) {
        self.id         = UUID()
        self.title      = title
        self.date       = date
        self.recurrence = recurrence
        self.pinnedAt   = nil
    }
}

// MARK: - Computed Properties

extension MomentEntry {

    var nextOccurrence: Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var candidate = cal.startOfDay(for: date)
        guard recurrence != .none else { return date }
        while candidate < today {
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
        if isToday { return "Today" }
        return isFuture ? "Upcoming" : "Ongoing"
    }
}
