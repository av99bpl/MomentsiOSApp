// HeroCard.swift
// Moments

import SwiftUI

struct HeroCard: View {
    let entry: MomentEntry
    let isPinned: Bool

    private var differentYear: Bool {
        let cal = Calendar.current
        return cal.component(.year, from: entry.nextOccurrence) != cal.component(.year, from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            statusLabel
                .padding(.bottom, 14)

            Text(entry.title)
                .font(.mSerif(28))
                .foregroundStyle(Color.mInk)
                .padding(.bottom, 8)

            Text(differentYear
                ? entry.nextOccurrence.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
                : entry.nextOccurrence.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.mSans(MType.heroDate))
                .foregroundStyle(Color.mInkSoft)
                .padding(.bottom, 18)

            if !entry.isToday { countPill }
        }
        .multilineTextAlignment(.center)
        .padding(.top, MSpace.heroPadTop)
        .padding(.horizontal, MSpace.heroPadH)
        .padding(.bottom, MSpace.heroPadBottom)
        .frame(maxWidth: .infinity)
        .paperRaisedBG()
        .clipShape(RoundedRectangle(cornerRadius: MSpace.heroRadius))
        .overlay(
            RoundedRectangle(cornerRadius: MSpace.heroRadius)
                .stroke(Color.mHairline, lineWidth: 1)
        )
    }

    private var countPill: some View {
        Text(pillLabel)
            .font(.mSans(14, weight: .semibold))
            .foregroundStyle(Color.mClay)
            .padding(.vertical, 7)
            .padding(.horizontal, 18)
            .background(Color.mClay.opacity(0.08))
            .overlay(Capsule().stroke(Color.mClay.opacity(0.4), lineWidth: 1))
            .clipShape(Capsule())
    }

    private var pillLabel: String {
        if entry.isToday { return "Today" }
        let m = entry.magnitude
        return entry.isFuture ? "in \(m.number) \(m.unit)" : "\(m.number) \(m.unit) ago"
    }

    private var statusLabel: some View {
        HStack(spacing: 5) {
            if isPinned && !entry.isToday {
                Image(systemName: "pin.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.mClay)
            }
            Text(statusText)
                .font(.mSans(MType.heroStatus, weight: .semibold))
                .foregroundStyle(Color.mClay)
                .tracking(0.3)
                .textCase(.uppercase)
        }
    }

    private var statusText: String {
        if entry.isToday { return "TODAY" }
        if isPinned { return "PINNED" }
        return entry.isFuture ? "COMING UP" : "ONGOING"
    }
}
