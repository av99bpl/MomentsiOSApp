// HeroCard.swift
// Moments
//
// v1: warm paper only. No frosted glass variant.

import SwiftUI

struct HeroCard: View {
    let entry: MomentEntry
    let isPinned: Bool

    private var mag: MagnitudeResult { entry.magnitude }

    var body: some View {
        VStack(spacing: 0) {
            statusLabel
                .padding(.bottom, MSpace.heroStatusBottom)

            if entry.isToday {
                Text("Today")
                    .font(.mSerif(MType.heroToday))
                    .foregroundStyle(Color.mInk)
                    .tracking(-1)
                    .padding(.bottom, MSpace.heroTodayBottom)
            } else {
                Text(mag.number)
                    .font(.mSerif(MType.heroNumber))
                    .foregroundStyle(Color.mInk)
                    .monospacedDigit()
                    .tracking(-2)

                Text("\(mag.unit) \(entry.isFuture ? "to go" : "since")")
                    .font(.mSans(MType.heroUnit))
                    .foregroundStyle(Color.mInkSoft)
                    .padding(.top, MSpace.heroNumUnitGap)
                    .padding(.bottom, MSpace.heroUnitTitleGap)
            }

            Text(entry.title)
                .font(.mSans(MType.heroTitle, weight: .semibold))
                .foregroundStyle(Color.mInk)
                .padding(.bottom, MSpace.heroTitleDateGap)

            Text(entry.nextOccurrence.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.mSans(MType.heroDate))
                .foregroundStyle(Color.mInkSoft)
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
