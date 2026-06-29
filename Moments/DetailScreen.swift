// DetailScreen.swift
// Moments
//
// Pushed onto NavigationStack. Fetches entry live from SwiftData via entryID.

import SwiftUI
import SwiftData

struct DetailScreen: View {
    let entryID: PersistentIdentifier
    let onNavigate: (NavDest) -> Void

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allEntries: [MomentEntry]

    @State private var showShare = false
    @State private var showConfirmDelete = false

    var entry: MomentEntry? {
        allEntries.first { $0.persistentModelID == entryID }
    }

    var body: some View {
        Group {
            if let entry {
                mainContent(entry: entry)
            } else {
                Color.clear.onAppear { dismiss() }
            }
        }
    }

    @ViewBuilder
    private func mainContent(entry: MomentEntry) -> some View {
        let mag = entry.magnitude
        let isPinned = appState.pinnedEntryID == entry.id && !appState.isPinExpired
        let pinDaysLeft: Int = {
            guard let p = appState.pinnedAt, !appState.isPinExpired else { return 0 }
            let remaining = MConstants.pinDuration - Date().timeIntervalSince(p)
            return max(0, Int(ceil(remaining / 86400)))
        }()

        ZStack {
            VStack(spacing: 0) {
                navBar(entry: entry)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        countArea(entry: entry, mag: mag, isPinned: isPinned)
                        pinSection(entry: entry, isPinned: isPinned, pinDaysLeft: pinDaysLeft)
                        actionButtons(entry: entry)
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, MSpace.screenH + 8)
                }
            }

            if showShare {
                ShareSheet(entry: entry, onDismiss: { showShare = false })
                    .transition(.opacity)
                    .zIndex(10)
                    .animation(.easeInOut(duration: 0.2), value: showShare)
            }

            if showConfirmDelete {
                ConfirmDeleteSheet(
                    title: entry.title,
                    onDelete: { deleteEntry(entry) },
                    onCancel: { showConfirmDelete = false }
                )
                .transition(.opacity)
                .zIndex(11)
                .animation(.easeInOut(duration: 0.2), value: showConfirmDelete)
            }
        }
        .paperBG()
    }

    // MARK: - Nav bar

    private func navBar(entry: MomentEntry) -> some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                    Text("Back")
                        .font(.mSans(MType.navItem))
                }
                .foregroundStyle(Color.mInk)
            }
            .padding(8)

            Spacer()

            Button { showShare = true } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.mInk)
                    .padding(8)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, MSpace.statusBar)
        .padding(.bottom, 20)
    }

    // MARK: - Count area

    private func countArea(entry: MomentEntry, mag: MagnitudeResult, isPinned: Bool) -> some View {
        VStack(spacing: 0) {
            statusLabel(entry: entry, isPinned: isPinned)
                .padding(.bottom, 16)

            Text(entry.title)
                .font(.mSerif(34))
                .foregroundStyle(Color.mInk)
                .padding(.bottom, 10)

            let diffYear = Calendar.current.component(.year, from: entry.nextOccurrence) != Calendar.current.component(.year, from: Date())
            Text(diffYear
                ? entry.nextOccurrence.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
                : entry.nextOccurrence.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.mSans(MType.detailDate))
                .foregroundStyle(Color.mInkSoft)

            if entry.recurrence != .none {
                Text(entry.recurrence.detailLabel)
                    .font(.mSans(MType.recurrencePill))
                    .foregroundStyle(Color.mInkSoft)
                    .padding(.vertical, MSpace.recurrPillPadV)
                    .padding(.horizontal, MSpace.recurrPillPadH)
                    .overlay(
                        RoundedRectangle(cornerRadius: MSpace.recurrPillRadius)
                            .stroke(Color.mHairline, lineWidth: 1)
                    )
                    .padding(.top, 10)
            }

            if !entry.isToday {
                countPill(entry: entry, mag: mag)
                    .padding(.top, 20)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 32)
    }

    // MARK: - Action buttons (trash + pencil)

    private func actionButtons(entry: MomentEntry) -> some View {
        HStack(spacing: 16) {
            Button { showConfirmDelete = true } label: {
                Image(systemName: "trash")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.mInk)
                    .frame(width: 46, height: 46)
                    .overlay(Circle().stroke(Color.mHairline, lineWidth: 1))
            }

            Button { onNavigate(.addEdit(entry.persistentModelID)) } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.mInk)
                    .frame(width: 46, height: 46)
                    .overlay(Circle().stroke(Color.mHairline, lineWidth: 1))
            }
        }
        .padding(.top, 28)
    }

    private func deleteEntry(_ entry: MomentEntry) {
        if appState.pinnedEntryID == entry.id {
            appState.unpin(entry: entry)
        }
        let title = entry.title
        modelContext.delete(entry)
        appState.showToast("Deleted \"\(title)\"")
        dismiss()
    }

    private func countPill(entry: MomentEntry, mag: MagnitudeResult) -> some View {
        let label: String = {
            if entry.isToday { return "Today" }
            return entry.isFuture ? "in \(mag.number) \(mag.unit)" : "\(mag.number) \(mag.unit) ago"
        }()
        return Text(label)
            .font(.mSans(15, weight: .semibold))
            .foregroundStyle(Color.mClay)
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .background(Color.mClay.opacity(0.08))
            .overlay(Capsule().stroke(Color.mClay.opacity(0.4), lineWidth: 1))
            .clipShape(Capsule())
    }

    private func statusLabel(entry: MomentEntry, isPinned: Bool) -> some View {
        let text: String = {
            if entry.isToday { return "TODAY" }
            if isPinned { return "PINNED" }
            return entry.isFuture ? "COUNTING DOWN" : "COUNTING UP"
        }()
        let color = (entry.isFuture || entry.isToday) ? Color.mClay : Color.mPast
        return HStack(spacing: 5) {
            if isPinned && !entry.isToday {
                Image(systemName: "pin.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
            }
            Text(text)
                .font(.mSans(MType.detailStatus, weight: .semibold))
                .foregroundStyle(color)
                .tracking(0.3)
                .textCase(.uppercase)
        }
    }

    // MARK: - Pin section

    private func pinSection(entry: MomentEntry, isPinned: Bool, pinDaysLeft: Int) -> some View {
        VStack(spacing: 10) {
            if isPinned {
                Button {
                    appState.unpin(entry: entry)
                    appState.showToast("Unpinned \"\(entry.title)\"")
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "pin.slash")
                            .font(.system(size: 14, weight: .medium))
                        Text("Unpin")
                            .font(.mSans(MType.actionBtn, weight: .semibold))
                    }
                    .foregroundStyle(Color.mInk)
                    .padding(.vertical, MSpace.actionBtnV)
                    .padding(.horizontal, MSpace.actionBtnH)
                    .overlay(
                        RoundedRectangle(cornerRadius: MSpace.actionBtnRadius)
                            .stroke(Color.mHairline, lineWidth: 1)
                    )
                }

                Text(pinDaysLeft <= 0
                     ? "Pin expires today"
                     : "Pinned as hero · \(pinDaysLeft) day\(pinDaysLeft == 1 ? "" : "s") left")
                    .font(.mSans(MType.reminderConfirm))
                    .foregroundStyle(Color.mInkSoft)
            } else {
                Button {
                    appState.pin(entry)
                    appState.showToast("Pinned \"\(entry.title)\" for 7 days")
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "pin")
                            .font(.system(size: 14, weight: .medium))
                        Text("Pin as Hero")
                            .font(.mSans(MType.actionBtn, weight: .semibold))
                    }
                    .foregroundStyle(Color.mInk)
                    .padding(.vertical, MSpace.actionBtnV)
                    .padding(.horizontal, MSpace.actionBtnH)
                    .overlay(
                        RoundedRectangle(cornerRadius: MSpace.actionBtnRadius)
                            .stroke(Color.mHairline, lineWidth: 1)
                    )
                }

                let hasOtherPin = appState.pinnedEntryID != nil && appState.pinnedEntryID != entry.id && !appState.isPinExpired
                Text(hasOtherPin
                     ? "Replaces the current pin · stays for 7 days"
                     : "Stays at the top for 7 days")
                    .font(.mSans(MType.reminderConfirm))
                    .foregroundStyle(Color.mInkSoft)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, MSpace.pinSectionTop)
        .padding(.bottom, 28)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map(\.maxHeight).reduce(0, +) + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for sub in row.subviews {
                let size = sub.sizeThatFits(.unspecified)
                sub.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.maxHeight + spacing
        }
    }

    private struct Row {
        var subviews: [LayoutSubview] = []
        var maxHeight: CGFloat = 0
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var current = Row()
        var x: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && !current.subviews.isEmpty {
                rows.append(current)
                current = Row()
                x = 0
            }
            current.subviews.append(sub)
            current.maxHeight = max(current.maxHeight, size.height)
            x += size.width + spacing
        }
        if !current.subviews.isEmpty { rows.append(current) }
        return rows
    }
}
