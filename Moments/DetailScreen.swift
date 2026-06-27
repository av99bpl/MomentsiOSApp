import SwiftUI
import SwiftData

struct DetailScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    let entry: MomentEntry

    @State private var showShare = false

    private var mag: FormattedMagnitude { entry.magnitude }
    private var isPinned: Bool { appState.pinnedID == entry.id && appState.isPinValid }
    private var hasOtherPin: Bool { appState.pinnedID != nil && appState.pinnedID != entry.id && appState.isPinValid }

    var body: some View {
        ZStack {
            Color.mPaper.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                navBar

                // Scrollable content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        contentArea
                        reminderSection
                        pinSection
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, MSpacing.screenH + 8)
                }
            }

            // Share sheet
            if showShare {
                ShareSheet(entry: entry, onDismiss: { showShare = false })
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showShare)
    }

    // MARK: - Nav Bar

    var navBar: some View {
        HStack(spacing: 0) {
            Button {
                appState.showDetail = false
                appState.selectedEntry = nil
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                    Text("Back")
                        .font(.mSans(MTypography.navItem))
                }
                .foregroundStyle(Color.mInk)
            }
            .padding(8)

            Spacer()

            HStack(spacing: 4) {
                // iCloud synced indicator
                HStack(spacing: 3) {
                    Image(systemName: "cloud")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.mInkSoft)
                    Text("Synced")
                        .font(.mSans(11))
                        .foregroundStyle(Color.mInkSoft)
                }
                .padding(.trailing, 4)

                Button {
                    showShare = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color.mInk)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 8)

                Button {
                    appState.editingEntry = entry
                    appState.showAddEdit = true
                } label: {
                    Text("Edit")
                        .font(.mSans(MTypography.navItem, weight: .bold))
                        .foregroundStyle(Color.mInk)
                }
                .padding(8)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, MSpacing.statusBar)
        .padding(.bottom, 20)
    }

    // MARK: - Content Area

    var contentArea: some View {
        VStack(spacing: 0) {
            // Status
            Text(statusLabel)
                .font(.mSans(13, weight: .semibold))
                .foregroundStyle(statusColor)
                .tracking(0.3)
                .textCase(.uppercase)
                .padding(.bottom, 16)

            // Number or Today
            if entry.isToday {
                Text("Today")
                    .font(.mSerif(MTypography.todayWordDetail))
                    .foregroundStyle(Color.mInk)
                    .tracking(-1)
                    .padding(.bottom, 24)
            } else {
                Text(mag.number)
                    .font(.mSerif(MTypography.detailNumber))
                    .foregroundStyle(Color.mInk)
                    .monospacedDigit()
                    .tracking(-2)

                Text(mag.unit)
                    .font(.mSans(MTypography.detailUnit))
                    .foregroundStyle(Color.mInkSoft)
                    .padding(.top, 6)
                    .padding(.bottom, 28)
            }

            // Title
            Text(entry.title)
                .font(.mSans(MTypography.detailTitle, weight: .semibold))
                .foregroundStyle(Color.mInk)
                .padding(.bottom, 6)

            // Date
            Text(entry.nextOccurrence.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                .font(.mSans(MTypography.detailDate))
                .foregroundStyle(Color.mInkSoft)

            // Recurrence pill
            if entry.recurrence != .none {
                Text("Repeats \(entry.recurrence.label.lowercased())")
                    .font(.mSans(13))
                    .foregroundStyle(Color.mInkSoft)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.mHairline, lineWidth: 1)
                    )
                    .padding(.top, 14)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 32)
    }

    var statusLabel: String {
        if entry.isToday { return "TODAY" }
        return entry.isFuture ? "COUNTING DOWN" : "COUNTING UP"
    }

    var statusColor: Color {
        entry.isFuture || entry.isToday ? Color.mClay : Color.mPast
    }

    // MARK: - Reminder Section

    var reminderSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "bell")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mInkSoft)
                Text("REMINDER")
                    .font(.mSans(12, weight: .bold))
                    .foregroundStyle(Color.mInkSoft)
                    .tracking(0.8)
            }
            .padding(.bottom, 10)

            // Chips
            let options: [(ReminderDays, String)] = [
                (.none, "None"),
                (.oneDay, "1 day"),
                (.threeDays, "3 days"),
                (.oneWeek, "1 week"),
                (.twoWeeks, "2 weeks"),
            ]

            FlowLayout(spacing: 7) {
                ForEach(options, id: \.0) { day, label in
                    let isActive = entry.reminderDays == day.rawValue
                    Button {
                        setReminder(day)
                    } label: {
                        Text(label)
                            .font(.mSans(13, weight: .semibold))
                            .foregroundStyle(isActive ? Color.mPaper : Color.mInk)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(isActive ? Color.mInk : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isActive ? Color.mInk : Color.mHairline, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }

            // Confirmation text
            if entry.reminderDays > 0 {
                let day = ReminderDays(rawValue: entry.reminderDays)
                Text("You'll be reminded \(day?.label.lowercased() ?? "") · \(entry.title)")
                    .font(.mSans(12))
                    .foregroundStyle(Color.mInkSoft)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 28)
    }

    func setReminder(_ day: ReminderDays) {
        if day != .none {
            requestNotificationPermission { granted in
                guard granted else { return }
                entry.reminderDays = day.rawValue
                scheduleReminder(for: entry)
            }
        } else {
            entry.reminderDays = 0
            scheduleReminder(for: entry)
        }
    }

    // MARK: - Pin Section

    var pinSection: some View {
        VStack(spacing: 10) {
            if isPinned {
                Button(action: { appState.unpin() }) {
                    HStack(spacing: 7) {
                        Image(systemName: "pin.slash")
                            .font(.system(size: 14, weight: .medium))
                        Text("Unpin")
                            .font(.mSans(14, weight: .semibold))
                    }
                    .foregroundStyle(Color.mInk)
                    .padding(.vertical, MSpacing.actionBtnV)
                    .padding(.horizontal, MSpacing.actionBtnH)
                    .overlay(
                        RoundedRectangle(cornerRadius: MSpacing.actionBtnRadius)
                            .stroke(Color.mHairline, lineWidth: 1)
                    )
                }

                let daysLeft = appState.pinDaysLeft
                Text(daysLeft <= 0 ? "Pin expires today" : "Pinned as hero · \(daysLeft) day\(daysLeft == 1 ? "" : "s") left")
                    .font(.mSans(12))
                    .foregroundStyle(Color.mInkSoft)
            } else {
                Button(action: {
                    appState.pin(id: entry.id, title: entry.title)
                }) {
                    HStack(spacing: 7) {
                        Image(systemName: "pin")
                            .font(.system(size: 14, weight: .medium))
                        Text("Pin as Hero")
                            .font(.mSans(14, weight: .semibold))
                    }
                    .foregroundStyle(Color.mInk)
                    .padding(.vertical, MSpacing.actionBtnV)
                    .padding(.horizontal, MSpacing.actionBtnH)
                    .overlay(
                        RoundedRectangle(cornerRadius: MSpacing.actionBtnRadius)
                            .stroke(Color.mHairline, lineWidth: 1)
                    )
                }

                if hasOtherPin {
                    Text("Replaces the current pin on \"\(appState.pinnedTitle)\" · stays for 7 days")
                        .font(.mSans(12))
                        .foregroundStyle(Color.mInkSoft)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Keeps this at the top for 7 days, however the dates fall")
                        .font(.mSans(12))
                        .foregroundStyle(Color.mInkSoft)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 28)
    }
}

// MARK: - Simple Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.maxHeight }.reduce(0, +) + CGFloat(max(0, rows.count - 1)) * spacing
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
