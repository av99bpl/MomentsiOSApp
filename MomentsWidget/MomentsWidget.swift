// MomentsWidget.swift
// MomentsWidget
//
// Shows the current hero moment (soonest upcoming, or pinned) at a glance.

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Entry

struct MomentsEntry: TimelineEntry {
    let date: Date
    let title: String
    let dateLabel: String
    let magNumber: String
    let magUnit: String
    let isToday: Bool
    let isFuture: Bool
    let isEmpty: Bool
    let appearanceMode: AppearanceMode

    init(from entry: MomentEntry, appearanceMode: AppearanceMode) {
        date = Date()
        title = entry.title
        dateLabel = entry.listDateLabel
        let mag = entry.magnitude
        magNumber = mag.number
        magUnit = mag.unit
        isToday = entry.isToday
        isFuture = entry.isFuture
        isEmpty = false
        self.appearanceMode = appearanceMode
    }

    init(placeholder title: String, dateLabel: String, magNumber: String, magUnit: String, isToday: Bool, isFuture: Bool, isEmptyState: Bool = false, appearanceMode: AppearanceMode = .system) {
        date = Date()
        self.title = title
        self.dateLabel = dateLabel
        self.magNumber = magNumber
        self.magUnit = magUnit
        self.isToday = isToday
        self.isFuture = isFuture
        isEmpty = isEmptyState
        self.appearanceMode = appearanceMode
    }

    static let placeholder = MomentsEntry(
        placeholder: "Anniversary", dateLabel: "Aug 12",
        magNumber: "42", magUnit: "days", isToday: false, isFuture: true
    )

    static func empty(appearanceMode: AppearanceMode = .system) -> MomentsEntry {
        MomentsEntry(
            placeholder: "", dateLabel: "", magNumber: "", magUnit: "",
            isToday: false, isFuture: false, isEmptyState: true, appearanceMode: appearanceMode
        )
    }
}

// MARK: - Provider

struct MomentsProvider: TimelineProvider {
    func placeholder(in context: Context) -> MomentsEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (MomentsEntry) -> Void) {
        completion(context.isPreview ? .placeholder : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MomentsEntry>) -> Void) {
        let entry = currentEntry()
        let nextRefresh = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 5),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(6 * 3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func currentEntry() -> MomentsEntry {
        let container = SharedStore.makeContainer()
        let context = ModelContext(container)
        let all = (try? context.fetch(FetchDescriptor<MomentEntry>())) ?? []
        let appState = AppState()
        let sorted = appState.sortedEntries(all)
        guard let hero = sorted.first else {
            return .empty(appearanceMode: appState.appearanceMode)
        }
        return MomentsEntry(from: hero, appearanceMode: appState.appearanceMode)
    }
}

// MARK: - View

struct MomentsWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: MomentsEntry

    var body: some View {
        Group {
            if entry.isEmpty {
                emptyView
            } else {
                switch family {
                case .systemMedium: mediumView
                default: smallView
                }
            }
        }
        .containerBackground(Color.mPaper, for: .widget)
        .preferredColorScheme(entry.appearanceMode.colorScheme)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(Color.mInkSoft.opacity(0.4))
            Text("No moments yet")
                .font(.mSans(13))
                .foregroundStyle(Color.mInkSoft)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var smallView: some View {
        VStack(spacing: 6) {
            Text(entry.title)
                .font(.mSerif(16))
                .foregroundStyle(Color.mInk)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            Text(entry.dateLabel)
                .font(.mSans(11))
                .foregroundStyle(Color.mInkSoft)

            countPill
                .padding(.top, 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.mSerif(20))
                    .foregroundStyle(Color.mInk)
                    .lineLimit(2)
                Text(entry.dateLabel)
                    .font(.mSans(13))
                    .foregroundStyle(Color.mInkSoft)
            }
            Spacer()
            countPill
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var countPill: some View {
        Text(pillLabel)
            .font(.mSans(13, weight: .semibold))
            .foregroundStyle(Color.mClay)
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(Color.mClay.opacity(0.08))
            .overlay(Capsule().stroke(Color.mClay.opacity(0.4), lineWidth: 1))
            .clipShape(Capsule())
    }

    private var pillLabel: String {
        if entry.isToday { return "Today" }
        return entry.isFuture ? "in \(entry.magNumber) \(entry.magUnit)" : "\(entry.magNumber) \(entry.magUnit) ago"
    }
}

// MARK: - Widget

struct MomentsWidget: Widget {
    let kind: String = "MomentsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MomentsProvider()) { entry in
            MomentsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Moments")
        .description("See your next moment at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    MomentsWidget()
} timeline: {
    MomentsEntry.placeholder
}

#Preview(as: .systemMedium) {
    MomentsWidget()
} timeline: {
    MomentsEntry.placeholder
}
