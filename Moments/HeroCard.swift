import SwiftUI

enum HeroVariant: String {
    case paper = "A"
    case frosted = "B"
}

struct HeroCard: View {
    let entry: MomentEntry
    let isPinned: Bool
    let variant: HeroVariant

    private var mag: FormattedMagnitude { entry.magnitude }

    var body: some View {
        ZStack {
            cardBackground
            cardContent
        }
        .clipShape(RoundedRectangle(cornerRadius: MSpacing.heroCardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: MSpacing.heroCardRadius)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    // MARK: - Background

    @ViewBuilder
    var cardBackground: some View {
        if variant == .frosted {
            RoundedRectangle(cornerRadius: MSpacing.heroCardRadius)
                .fill(.ultraThinMaterial)
        } else {
            RoundedRectangle(cornerRadius: MSpacing.heroCardRadius)
                .modifier(MPaperRaisedBackground())
        }
    }

    var borderColor: Color {
        variant == .frosted ? Color.white.opacity(0.75) : Color.mHairline
    }

    // MARK: - Content

    var cardContent: some View {
        VStack(spacing: 0) {
            // Status label
            statusLabel
                .padding(.bottom, MSpacing.statusLabelBottom)

            // Number or "Today"
            if entry.isToday {
                Text("Today")
                    .font(.mSerif(MTypography.todayWord))
                    .foregroundStyle(Color.mInk)
                    .tracking(-1)
                    .padding(.bottom, 22)
            } else {
                Text(mag.number)
                    .font(.mSerif(MTypography.heroNumber))
                    .foregroundStyle(Color.mInk)
                    .monospacedDigit()
                    .tracking(-2)

                Text("\(mag.unit) \(entry.isFuture ? "to go" : "since")")
                    .font(.mSans(MTypography.heroUnit))
                    .foregroundStyle(Color.mInkSoft)
                    .padding(.top, MSpacing.numberUnitGap)
                    .padding(.bottom, MSpacing.unitTitleGap)
            }

            // Title
            Text(entry.title)
                .font(.mSans(MTypography.heroTitle, weight: .semibold))
                .foregroundStyle(Color.mInk)
                .padding(.bottom, MSpacing.titleDateGap)

            // Date
            Text(entry.nextOccurrence.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.mSans(MTypography.heroDate))
                .foregroundStyle(Color.mInkSoft)
        }
        .multilineTextAlignment(.center)
        .padding(.top, MSpacing.heroCardV)
        .padding(.horizontal, MSpacing.heroCardH)
        .padding(.bottom, MSpacing.heroCardBottom)
        .frame(maxWidth: .infinity)
    }

    var statusLabel: some View {
        HStack(spacing: 5) {
            if isPinned && !entry.isToday {
                Image(systemName: "pin.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.mClay)
            }
            Text(statusText)
                .font(.mSans(MTypography.heroStatus, weight: .semibold))
                .foregroundStyle(Color.mClay)
                .tracking(0.3)
                .textCase(.uppercase)
        }
    }

    var statusText: String {
        if entry.isToday { return "TODAY" }
        if isPinned { return "PINNED" }
        return entry.isFuture ? "COMING UP" : "ONGOING"
    }
}
