import SwiftUI
import SwiftData

struct ListScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [MomentEntry]

    @State private var swipedEntryID: UUID? = nil
    @State private var confirmDeleteEntry: MomentEntry? = nil

    var variant: HeroVariant { .paper }  // TODO: expose via AppState if needed

    // MARK: - Computed entries

    var sortedEntries: [MomentEntry] {
        allEntries.sorted { $0.diffDays < $1.diffDays }
    }

    var heroEntry: MomentEntry? {
        if let pinnedID = appState.pinnedID,
           appState.isPinValid,
           let pinned = allEntries.first(where: { $0.id == pinnedID }) {
            return pinned
        }
        return sortedEntries.first
    }

    var ledgerEntries: [MomentEntry] {
        let heroID = heroEntry?.id
        return sortedEntries.filter { $0.id != heroID }
    }

    var isPinned: Bool {
        guard let hero = heroEntry else { return false }
        return appState.pinnedID == hero.id && appState.isPinValid
    }

    var atLimit: Bool {
        !appState.isPremium && allEntries.count >= MConstants.freeEntryLimit
    }

    var showEntryCount: Bool {
        !appState.isPremium && allEntries.count >= MConstants.freeEntryLimit - 2
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.mPaper.ignoresSafeArea()

            if allEntries.isEmpty {
                EmptyState(onAdd: handleAddTap)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        header
                        heroSection
                        ledgerSection
                    }
                }
                .simultaneousGesture(
                    TapGesture().onEnded { swipedEntryID = nil }
                )
            }

            // FAB
            Button(action: handleAddTap) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.mPaper)
                    .frame(width: MSpacing.fabSize, height: MSpacing.fabSize)
                    .background(Color.mInk)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
            }
            .padding(.bottom, MSpacing.fabBottom)
            .padding(.trailing, MSpacing.fabRight)
        }
        .overlay(alignment: .bottom) {
            if confirmDeleteEntry != nil { Color.clear }  // placeholder, sheet below
        }
        .overlay {
            if let entry = confirmDeleteEntry {
                ConfirmDeleteSheet(
                    title: entry.title,
                    onDelete: {
                        deleteEntry(entry)
                        confirmDeleteEntry = nil
                    },
                    onCancel: {
                        confirmDeleteEntry = nil
                        swipedEntryID = nil
                    }
                )
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: confirmDeleteEntry?.id)
    }

    // MARK: - Header

    var header: some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                Text("MOMENTS")
                    .font(.mSans(MTypography.wordmark, weight: .semibold))
                    .foregroundStyle(Color.mInkSoft)
                    .tracking(1.2)

                // iCloud sync indicator
                Image(systemName: "cloud")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.mInkSoft)
            }

            Spacer()

            if showEntryCount {
                Text("\(allEntries.count)/\(MConstants.freeEntryLimit)")
                    .font(.mSans(MTypography.counter, weight: .semibold))
                    .foregroundStyle(
                        allEntries.count >= MConstants.freeEntryLimit
                            ? Color.mInk : Color.mInkSoft
                    )
            }
        }
        .padding(.horizontal, MSpacing.screenH + 8)
        .padding(.top, MSpacing.statusBar)
        .padding(.bottom, MSpacing.headerBottom)
    }

    // MARK: - Hero section

    @ViewBuilder
    var heroSection: some View {
        if let hero = heroEntry {
            HeroCard(entry: hero, isPinned: isPinned, variant: variant)
                .padding(.horizontal, MSpacing.heroCardMargin)
                .padding(.top, MSpacing.heroCardTopMargin)
                .padding(.bottom, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    appState.selectedEntry = hero
                    appState.showDetail = true
                }
        }
    }

    // MARK: - Ledger

    var ledgerSection: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(ledgerEntries.enumerated()), id: \.element.id) { index, entry in
                LedgerRow(
                    entry: entry,
                    isLast: index == ledgerEntries.count - 1,
                    swipedID: $swipedEntryID,
                    onTap: {
                        appState.selectedEntry = entry
                        appState.showDetail = true
                    },
                    onDeleteRequest: {
                        confirmDeleteEntry = entry
                    }
                )
                .padding(.horizontal, MSpacing.screenH)
            }

            // hint text
            Text("Swipe left on an entry to delete · Tap to view")
                .font(.mSans(12))
                .foregroundStyle(Color.mHairline)
                .padding(.top, 18)
                .padding(.bottom, 100)
        }
    }

    // MARK: - Actions

    func handleAddTap() {
        if atLimit {
            appState.paywallReturnToAdd = true
            appState.showPaywall = true
        } else {
            appState.editingEntry = nil
            appState.showAddEdit = true
        }
    }

    func deleteEntry(_ entry: MomentEntry) {
        if appState.pinnedID == entry.id {
            appState.clearPin()
        }
        let title = entry.title
        modelContext.delete(entry)
        swipedEntryID = nil
        appState.showToast("Deleted \"\(title)\"")
    }
}

// MARK: - Ledger Row

struct LedgerRow: View {
    let entry: MomentEntry
    let isLast: Bool
    @Binding var swipedID: UUID?
    let onTap: () -> Void
    let onDeleteRequest: () -> Void

    private let deleteWidth: CGFloat = 76
    @State private var offset: CGFloat = 0

    var isSwiped: Bool { swipedID == entry.id }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button behind
            Button(action: {
                withAnimation(.easeOut(duration: 0.15)) { offset = 0 }
                swipedID = nil
                onDeleteRequest()
            }) {
                Rectangle()
                    .fill(Color.mDestructive)
                    .frame(width: deleteWidth)
                    .overlay(
                        Text("Delete")
                            .font(.mSans(13, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .frame(maxHeight: .infinity)

            // Row content
            rowContent
                .offset(x: offset)
                .gesture(swipeGesture)
        }
        .clipped()
        .overlay(alignment: .bottom) {
            if !isLast {
                Color.mHairline.frame(height: 1)
            }
        }
        .onChange(of: swipedID) { _, id in
            if id != entry.id && offset != 0 {
                withAnimation(.easeOut(duration: 0.2)) { offset = 0 }
            }
        }
        .onChange(of: isSwiped) { _, swiped in
            if !swiped {
                withAnimation(.easeOut(duration: 0.2)) { offset = 0 }
            }
        }
    }

    var rowContent: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.mSans(MTypography.rowTitle, weight: .semibold))
                    .foregroundStyle(Color.mInk)
                Text(subtitleText)
                    .font(.mSans(MTypography.rowSubtitle))
                    .foregroundStyle(Color.mInkSoft)
            }

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                let mag = entry.magnitude
                Text(mag.number)
                    .font(.mSerif(MTypography.rowNumber))
                    .foregroundStyle(entry.isFuture ? Color.mInk : Color.mPast)
                    .monospacedDigit()
                if !mag.unit.isEmpty {
                    Text(mag.unit)
                        .font(.mSans(MTypography.rowUnit))
                        .foregroundStyle(Color.mInkSoft)
                }
            }
        }
        .padding(.vertical, MSpacing.rowV)
        .padding(.horizontal, MSpacing.rowH)
        .background(Color.mPaper)
        .contentShape(Rectangle())
        .onTapGesture {
            if isSwiped {
                withAnimation(.easeOut(duration: 0.2)) {
                    offset = 0
                    swipedID = nil
                }
            } else {
                onTap()
            }
        }
    }

    var subtitleText: String {
        if entry.recurrence != .none { return entry.recurrence.label }
        return entry.isFuture ? "Upcoming" : "Ongoing"
    }

    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { value in
                let base: CGFloat = isSwiped ? -deleteWidth : 0
                let tentative = base + value.translation.width
                offset = max(-deleteWidth - 8, min(0, tentative))
            }
            .onEnded { value in
                let base: CGFloat = isSwiped ? -deleteWidth : 0
                let projected = base + value.translation.width
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if projected < -(deleteWidth / 2) {
                        offset = -deleteWidth
                        swipedID = entry.id
                    } else {
                        offset = 0
                        if swipedID == entry.id { swipedID = nil }
                    }
                }
            }
    }
}
