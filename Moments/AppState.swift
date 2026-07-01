// AppState.swift
// Moments

import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case light  = "light"
    case dark   = "dark"
    case system = "system"

    var label: String {
        switch self {
        case .light:  return "Light"
        case .dark:   return "Dark"
        case .system: return "System"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light:  return .light
        case .dark:   return .dark
        case .system: return nil
        }
    }
}

@Observable
final class AppState {

    // MARK: - Persisted state

    var isPremium: Bool = UserDefaults.standard.bool(forKey: "isPremium") {
        didSet { UserDefaults.standard.set(isPremium, forKey: "isPremium") }
    }

    var appearanceMode: AppearanceMode = {
        let raw = UserDefaults.standard.string(forKey: "appearanceMode") ?? ""
        return AppearanceMode(rawValue: raw) ?? .system
    }() {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode") }
    }

    var pinnedEntryID: UUID? = {
        guard let s = UserDefaults.standard.string(forKey: "pinnedEntryID") else { return nil }
        return UUID(uuidString: s)
    }() {
        didSet { UserDefaults.standard.set(pinnedEntryID?.uuidString, forKey: "pinnedEntryID") }
    }

    var pinnedAt: Date? = {
        let t = UserDefaults.standard.double(forKey: "pinnedAt")
        return t > 0 ? Date(timeIntervalSince1970: t) : nil
    }() {
        didSet { UserDefaults.standard.set(pinnedAt?.timeIntervalSince1970 ?? 0, forKey: "pinnedAt") }
    }

    // MARK: - Ephemeral state

    var toastMessage: String? = nil

    // MARK: - Pin helpers

    var isPinExpired: Bool {
        guard let p = pinnedAt else { return true }
        return Date().timeIntervalSince(p) > MConstants.pinDuration
    }

    func pin(_ entry: MomentEntry) {
        let now = Date()
        pinnedEntryID = entry.id
        pinnedAt = now
        entry.pinnedAt = now
    }

    func unpin(entry: MomentEntry? = nil) {
        pinnedEntryID = nil
        pinnedAt = nil
        entry?.pinnedAt = nil
    }

    func checkPinExpiry(entries: [MomentEntry]) {
        guard let pa = pinnedAt, let pinnedID = pinnedEntryID else { return }
        guard Date().timeIntervalSince(pa) > MConstants.pinDuration else { return }
        let matched = entries.first(where: { $0.id == pinnedID })
        let title = matched?.title ?? ""
        matched?.pinnedAt = nil
        unpin()
        let msg = title.isEmpty
            ? "Pin expired — showing what's next"
            : "Pin on \"\(title)\" expired — showing what's next"
        showToast(msg, duration: 3.2)
    }

    // MARK: - Sorting

    func sortedEntries(_ entries: [MomentEntry]) -> [MomentEntry] {
        var sorted = entries.sorted { $0.diffDays < $1.diffDays }
        if let id = pinnedEntryID, !isPinExpired,
           let idx = sorted.firstIndex(where: { $0.id == id }) {
            let pinned = sorted.remove(at: idx)
            sorted.insert(pinned, at: 0)
        }
        return sorted
    }

    // MARK: - Free limit

    func atFreeLimit(entryCount: Int) -> Bool {
        !isPremium && entryCount >= MConstants.freeEntryLimit
    }

    // MARK: - Toast

    func showToast(_ message: String, duration: Double = 2.2) {
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(duration))
            if toastMessage == message { toastMessage = nil }
        }
    }

    // MARK: - IAP

    func unlock() {
        isPremium = true
        showToast("Moments Unlocked")
    }
}
