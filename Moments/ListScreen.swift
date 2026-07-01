// ListScreen.swift
// Moments

import SwiftUI
import SwiftData
import WidgetKit

struct ListScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [MomentEntry]

    let onNavigate: (NavDest) -> Void

    @State private var confirmDeleteEntry: MomentEntry? = nil

    // MARK: - Computed

    var sorted: [MomentEntry] { appState.sortedEntries(allEntries) }
    var heroEntry: MomentEntry? { sorted.first }
    var ledgerEntries: [MomentEntry] { sorted.dropFirst().map { $0 } }

    var isPinned: Bool {
        guard let hero = heroEntry else { return false }
        return appState.pinnedEntryID == hero.id && !appState.isPinExpired
    }

    // MARK: - Body

    var body: some View {
        if sorted.isEmpty {
            EmptyState(onAdd: handleAddTap)
                .paperBG()
        } else {
            VStack(spacing: 0) {
                header
                heroSection
                    .padding(.horizontal, MSpace.heroMargin)
                    .padding(.top, MSpace.heroTopMargin)
                    .padding(.bottom, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let hero = heroEntry {
                            onNavigate(.detail(hero.persistentModelID))
                        }
                    }

                List {
                    ForEach(ledgerEntries) { entry in
                        LedgerRow(
                            entry: entry,
                            onTap: { onNavigate(.detail(entry.persistentModelID)) }
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: MSpace.screenH, bottom: 0, trailing: MSpace.screenH))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                confirmDeleteEntry = entry
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }

                    Color.clear.frame(height: MSpace.fabBottom + MSpace.fabSize)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .background(Color.clear)
            }
            .overlay(alignment: .bottom) { fab }
            .paperBG()
            .overlay {
                if let entry = confirmDeleteEntry {
                    ConfirmDeleteSheet(
                        title: entry.title,
                        onDelete: {
                            deleteEntry(entry)
                            confirmDeleteEntry = nil
                        },
                        onCancel: { confirmDeleteEntry = nil }
                    )
                    .transition(.opacity)
                    .zIndex(10)
                    .animation(.easeInOut(duration: 0.2), value: confirmDeleteEntry?.id)
                }
            }
        }
    }

    // MARK: - Header

    var header: some View {
        ZStack {
            Text("MOMENTS")
                .font(.mSans(MType.wordmark, weight: .semibold))
                .foregroundStyle(Color.mInkSoft)
                .tracking(6)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Spacer()
                Button { onNavigate(.settings) } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.mInkSoft.opacity(0.55))
                        .frame(width: 30, height: 30)
                        .overlay(Circle().stroke(Color.mHairline, lineWidth: 1))
                }
            }
            .padding(.horizontal, MSpace.screenH + 8)
        }
        .padding(.top, MSpace.statusBar)
        .padding(.bottom, MSpace.headerBottom)
    }

    // MARK: - Hero

    @ViewBuilder
    var heroSection: some View {
        if let hero = heroEntry {
            HeroCard(entry: hero, isPinned: isPinned)
        }
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
    }

    // MARK: - Actions

    func handleAddTap() {
        let count = (try? modelContext.fetch(FetchDescriptor<MomentEntry>()))?.count ?? allEntries.count
        if appState.atFreeLimit(entryCount: count) {
            onNavigate(.paywall)
        } else {
            onNavigate(.addEdit(nil))
        }
    }

    func deleteEntry(_ entry: MomentEntry) {
        if appState.pinnedEntryID == entry.id {
            appState.unpin(entry: entry)
        }
        let title = entry.title
        modelContext.delete(entry)
        try? modelContext.save()
        appState.showToast("Deleted \"\(title)\"")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Ledger Row

struct LedgerRow: View {
    let entry: MomentEntry
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.mSans(MType.rowTitle, weight: .medium))
                    .foregroundStyle(Color.mInk)
                if entry.recurrence != .none {
                    HStack(spacing: 4) {
                        Text(entry.listDateLabel)
                            .foregroundStyle(Color.mInkSoft)
                        Text("·")
                            .foregroundStyle(Color.mClay)
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.mClay)
                        Text(entry.recurrence.listLabel)
                            .foregroundStyle(Color.mClay)
                    }
                    .font(.mSans(MType.rowSubtitle))
                } else {
                    Text(entry.listDateLabel)
                        .font(.mSans(MType.rowSubtitle))
                        .foregroundStyle(Color.mInkSoft)
                }
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
        .onTapGesture { onTap() }
        .overlay(alignment: .bottom) {
            Color.mHairline.frame(height: 1)
        }
    }
}
