// ListScreen.swift
// Moments
//
// Root screen. Hero card is OUTSIDE the scroll view — fixed position.
// Only the ledger rows scroll.

import SwiftUI
import SwiftData

struct ListScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [MomentEntry]

    let onNavigate: (NavDest) -> Void

    @State private var swipedEntryID: UUID? = nil
    @State private var confirmDeleteEntry: MomentEntry? = nil

    // MARK: - Computed

    var sorted: [MomentEntry] { appState.sortedEntries(allEntries) }
    var heroEntry: MomentEntry? { sorted.first }
    var ledgerEntries: [MomentEntry] { sorted.dropFirst().map { $0 } }

    var isPinned: Bool {
        guard let hero = heroEntry else { return false }
        return appState.pinnedEntryID == hero.id && !appState.isPinExpired
    }

    var showEntryCount: Bool {
        !appState.isPremium && allEntries.count >= MConstants.freeEntryLimit - 2
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if sorted.isEmpty {
                EmptyState(onAdd: handleAddTap)
            } else {
                VStack(spacing: 0) {
                    header
                    heroSection
                    ledgerScrollView
                }

                fab
            }
        }
        .paperBG()
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
                .animation(.easeInOut(duration: 0.2), value: confirmDeleteEntry?.id)
            }
        }
    }

    // MARK: - Header

    var header: some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                Text("MOMENTS")
                    .font(.mSans(MType.wordmark, weight: .semibold))
                    .foregroundStyle(Color.mInkSoft)
                    .tracking(1.2)
                Image(systemName: "cloud")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.mInkSoft)
            }

            Spacer()

            if showEntryCount {
                Text("\(allEntries.count)/\(MConstants.freeEntryLimit)")
                    .font(.mSans(MType.counter, weight: .semibold))
                    .foregroundStyle(
                        allEntries.count >= MConstants.freeEntryLimit ? Color.mInk : Color.mInkSoft
                    )
            }
        }
        .padding(.horizontal, MSpace.screenH + 8)
        .padding(.top, MSpace.statusBar)
        .padding(.bottom, MSpace.headerBottom)
    }

    // MARK: - Hero

    @ViewBuilder
    var heroSection: some View {
        if let hero = heroEntry {
            HeroCard(entry: hero, isPinned: isPinned)
                .padding(.horizontal, MSpace.heroMargin)
                .padding(.top, MSpace.heroTopMargin)
                .padding(.bottom, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    onNavigate(.detail(hero.persistentModelID))
                }
        }
    }

    // MARK: - Ledger

    var ledgerScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(ledgerEntries.enumerated()), id: \.element.id) { index, entry in
                    LedgerRow(
                        entry: entry,
                        isLast: index == ledgerEntries.count - 1,
                        swipedID: $swipedEntryID,
                        onTap: { onNavigate(.detail(entry.persistentModelID)) },
                        onDeleteRequest: { confirmDeleteEntry = entry }
                    )
                    .padding(.horizontal, MSpace.screenH)
                }

                Color.clear.frame(height: 100)  // FAB clearance
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded { swipedEntryID = nil }
        )
    }

    // MARK: - FAB

    var fab: some View {
        Button(action: handleAddTap) {
            Image(systemName: "plus")
                .font(.system(size: MSpace.fabIcon, weight: .medium))
                .foregroundStyle(Color.mPaper)
                .frame(width: MSpace.fabSize, height: MSpace.fabSize)
                .background(Color.mInk)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
        }
        .padding(.bottom, MSpace.fabBottom)
        .padding(.trailing, MSpace.fabRight)
    }

    // MARK: - Actions

    func handleAddTap() {
        if appState.atFreeLimit(entryCount: allEntries.count) {
            onNavigate(.paywall)
        } else {
            onNavigate(.addEdit(nil))
        }
    }

    func deleteEntry(_ entry: MomentEntry) {
        if appState.pinnedEntryID == entry.id {
            appState.unpin(entry: entry)
        }
        cancelReminder(for: entry)
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

    @State private var offset: CGFloat = 0
    var isSwiped: Bool { swipedID == entry.id }

    var body: some View {
        ZStack(alignment: .trailing) {
            // Row content — stays fixed in place, never shifts
            rowContent
                .background(Color.mPaper)

            // Delete zone grows in from the right as user drags
            Button {
                onDeleteRequest()
            } label: {
                Color.mDestructive
                    .overlay(
                        Text("Delete")
                            .font(.mSans(13, weight: .bold))
                            .foregroundStyle(.white)
                            .opacity(-offset >= 40 ? 1 : 0)
                    )
            }
            .frame(width: max(0, -offset))
            .frame(maxHeight: .infinity)
            .clipped()
        }
        .contentShape(Rectangle())
        .clipped()
        .overlay(alignment: .bottom) {
            if !isLast { Color.mHairline.frame(height: 1) }
        }
        .gesture(swipeGesture)
        .onChange(of: swipedID) { _, id in
            if id != entry.id, offset != 0 {
                withAnimation(.easeOut(duration: 0.2)) { offset = 0 }
            }
        }
    }

    var rowContent: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.mSans(MType.rowTitle, weight: .medium))
                    .foregroundStyle(Color.mInk)
                Text(entry.listSubtitle)
                    .font(.mSans(MType.rowSubtitle))
                    .foregroundStyle(Color.mInkSoft)
            }

            Spacer()

            let mag = entry.magnitude
            if entry.isToday {
                Text("Today")
                    .font(.mSerif(MType.rowNumber))
                    .foregroundStyle(Color.mInk)
            } else if entry.isFuture {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("in")
                        .font(.mSans(MType.rowUnit))
                        .foregroundStyle(Color.mInkSoft)
                    Text(mag.number)
                        .font(.mSerif(MType.rowNumber))
                        .foregroundStyle(Color.mInk)
                        .monospacedDigit()
                    if !mag.unit.isEmpty {
                        Text(mag.unit)
                            .font(.mSans(MType.rowUnit))
                            .foregroundStyle(Color.mInkSoft)
                    }
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(mag.number)
                        .font(.mSerif(MType.rowNumber))
                        .foregroundStyle(Color.mPast)
                        .monospacedDigit()
                    if !mag.unit.isEmpty {
                        Text("\(mag.unit) ago")
                            .font(.mSans(MType.rowUnit))
                            .foregroundStyle(Color.mInkSoft)
                    }
                }
            }
        }
        .padding(.vertical, MSpace.rowV)
        .padding(.horizontal, MSpace.rowH)
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

    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { value in
                let base: CGFloat = isSwiped ? -MSpace.swipeDeleteW : 0
                let tentative = base + value.translation.width
                offset = max(-MSpace.swipeDeleteW - 8, min(0, tentative))
            }
            .onEnded { value in
                let base: CGFloat = isSwiped ? -MSpace.swipeDeleteW : 0
                let projected = base + value.translation.width
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if projected < -(MSpace.swipeDeleteW / 2) {
                        offset = -MSpace.swipeDeleteW
                        swipedID = entry.id
                    } else {
                        offset = 0
                        if swipedID == entry.id { swipedID = nil }
                    }
                }
            }
    }
}
