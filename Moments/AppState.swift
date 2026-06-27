import SwiftUI
import Observation

@Observable
final class AppState {

    // MARK: - Premium

    var isPremium: Bool {
        didSet { UserDefaults.standard.set(isPremium, forKey: "isPremium") }
    }

    // MARK: - Pin (persisted across sessions)

    private(set) var pinnedID: UUID? {
        didSet { UserDefaults.standard.set(pinnedID?.uuidString, forKey: "pinnedID") }
    }
    private(set) var pinnedTitle: String = "" {
        didSet { UserDefaults.standard.set(pinnedTitle, forKey: "pinnedTitle") }
    }
    private(set) var pinnedAt: Date? {
        didSet { UserDefaults.standard.set(pinnedAt, forKey: "pinnedAt") }
    }

    var isPinValid: Bool {
        guard let p = pinnedAt else { return false }
        return Date().timeIntervalSince(p) <= MConstants.pinDurationSeconds
    }

    var pinDaysLeft: Int {
        guard let p = pinnedAt, isPinValid else { return 0 }
        let remaining = MConstants.pinDurationSeconds - Date().timeIntervalSince(p)
        return max(0, Int(ceil(remaining / 86400)))
    }

    // MARK: - Toast

    var toastMessage: String? = nil
    private var toastTask: Task<Void, Never>? = nil

    // MARK: - Navigation state

    var navigationPath: [MomentEntry] = []
    var showAddEdit = false
    var editingEntry: MomentEntry? = nil   // nil = add mode
    var showPaywall = false
    var paywallReturnToAdd = false
    var showDetail = false
    var selectedEntry: MomentEntry? = nil

    // MARK: - Init

    init() {
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        if let idStr = UserDefaults.standard.string(forKey: "pinnedID"),
           let uuid = UUID(uuidString: idStr) {
            self.pinnedID = uuid
            self.pinnedTitle = UserDefaults.standard.string(forKey: "pinnedTitle") ?? ""
            self.pinnedAt = UserDefaults.standard.object(forKey: "pinnedAt") as? Date
        }
    }

    // MARK: - Pin actions

    func pin(id: UUID, title: String) {
        pinnedID = id
        pinnedTitle = title
        pinnedAt = Date()
        showToast("Pinned \"\(title)\" for 7 days")
    }

    func unpin() {
        let title = pinnedTitle
        pinnedID = nil
        pinnedTitle = ""
        pinnedAt = nil
        showToast("Unpinned \"\(title)\"")
    }

    func clearPin() {
        pinnedID = nil
        pinnedTitle = ""
        pinnedAt = nil
    }

    // Returns expired title if pin was cleared, else nil
    func clearPinIfExpired() -> String? {
        guard pinnedID != nil else { return nil }
        guard let p = pinnedAt else { return nil }
        if Date().timeIntervalSince(p) > MConstants.pinDurationSeconds {
            let title = pinnedTitle
            pinnedID = nil
            pinnedTitle = ""
            pinnedAt = nil
            return title
        }
        return nil
    }

    // MARK: - Toast

    func showToast(_ message: String, duration: Double = 2.2) {
        toastTask?.cancel()
        toastMessage = message
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            self?.toastMessage = nil
        }
    }

    // MARK: - IAP

    func unlock() {
        isPremium = true
        showToast("Moments Unlocked")
    }
}
