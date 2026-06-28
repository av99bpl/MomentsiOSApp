// DesignSystem.swift
// Moments
//
// Single source of truth for all visual design decisions.
// Values extracted 1:1 from the React prototype (moments-preview.jsx).
// Do not hardcode colors, fonts, or spacing anywhere else in the project.

import SwiftUI

// MARK: - Color Palette

extension Color {
    /// Warm off-white. App background. Hex: #FAF8F5
    static let mPaper       = Color(hex: "FAF8F5")
    /// Slightly deeper warm white. Hero card, bottom sheets. Hex: #F3F0EA
    static let mPaperRaised = Color(hex: "F3F0EA")
    /// Near-black. All primary text. Hex: #1C1B19
    static let mInk         = Color(hex: "1C1B19")
    /// Warm mid-gray. Secondary labels, units, dates. Hex: #6B6760
    static let mInkSoft     = Color(hex: "6B6760")
    /// Pale warm gray. 1pt row dividers only. Never thicker. Hex: #E4E0D8
    static let mHairline    = Color(hex: "E4E0D8")

    // ACCENT — RESERVED.
    // Use ONLY on: hero card status label, hero card status label on detail screen.
    // Do NOT use on: buttons, chips, navigation, form fields, or any secondary UI.
    /// Muted terracotta. The single accent color. Hex: #B8693F
    static let mClay        = Color(hex: "B8693F")
    /// Pale clay. Empty state decoration only. Hex: #D9B6A4
    static let mClayDim     = Color(hex: "D9B6A4")

    /// Cool gray. Past/count-up event numerals in the ledger list. Hex: #9C988F
    static let mPast        = Color(hex: "9C988F")
    /// Dark red. Delete actions only. Nothing else. Hex: #A8472E
    static let mDestructive = Color(hex: "A8472E")
}

// MARK: - Typography

extension Font {
    /// Palatino serif. Used ONLY for the large numeral and the word "Today".
    /// iOS fallback: Georgia → system serif.
    static func mSerif(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        Font.custom("Palatino-Roman", size: size).weight(weight)
    }

    /// SF Pro system font. Used for all UI chrome, labels, buttons, body text.
    static func mSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Type Scale (all sizes by role)

enum MType {
    static let heroNumber:      CGFloat = 88   // serif, hero card numeral
    static let heroToday:       CGFloat = 72   // serif, "Today" on hero card
    static let heroStatus:      CGFloat = 13   // sans semibold uppercase, "COMING UP" etc.
    static let heroUnit:        CGFloat = 17   // sans, "days to go / months since"
    static let heroTitle:       CGFloat = 19   // sans semibold, event title on hero
    static let heroDate:        CGFloat = 14   // sans, date below title on hero
    static let detailNumber:    CGFloat = 96   // serif, numeral on detail screen
    static let detailToday:     CGFloat = 80   // serif, "Today" on detail screen
    static let detailStatus:    CGFloat = 13   // sans semibold uppercase
    static let detailUnit:      CGFloat = 18   // sans, unit label
    static let detailTitle:     CGFloat = 22   // sans semibold
    static let detailDate:      CGFloat = 15   // sans
    static let rowTitle:        CGFloat = 16   // sans medium, list row title
    static let rowSubtitle:     CGFloat = 13   // sans, list row subtitle
    static let rowNumber:       CGFloat = 22   // serif, right-aligned list numeral
    static let rowUnit:         CGFloat = 13   // sans, right-aligned list unit
    static let wordmark:        CGFloat = 13   // sans semibold uppercase, "MOMENTS"
    static let navItem:         CGFloat = 16   // sans, nav bar buttons
    static let fieldLabel:      CGFloat = 12   // sans semibold uppercase, form labels
    static let chip:            CGFloat = 13   // sans semibold, recurrence chips
    static let segButton:       CGFloat = 14   // sans semibold, direction segment
    static let counter:         CGFloat = 12   // sans semibold, "8/10" entry count
    static let actionBtn:       CGFloat = 14   // sans semibold, pin/unpin/reminder btns
    static let reminderConfirm: CGFloat = 12   // sans, reminder confirmation text
    static let recurrencePill:  CGFloat = 13   // sans, detail recurrence pill
    static let sheetTitle:      CGFloat = 19   // serif, confirm delete / share title
    static let sheetSubtitle:   CGFloat = 14   // sans, "This can't be undone."
    static let sheetBtn:        CGFloat = 16   // sans bold/semibold, sheet buttons
    static let toast:           CGFloat = 13   // sans semibold, toast text
    static let paywallHead:     CGFloat = 32   // serif, paywall headline
    static let paywallSub:      CGFloat = 15   // sans, paywall subtitle
    static let paywallFeature:  CGFloat = 15   // sans, feature list rows
    static let paywallCTA:      CGFloat = 16   // sans bold, unlock button
    static let paywallMeta:     CGFloat = 12   // sans, "One-time purchase" note
    static let paywallRestore:  CGFloat = 13   // sans, restore purchase link
    static let shareLabel:      CGFloat = 12   // sans bold uppercase, share sheet header
    static let shareStatus:     CGFloat = 11   // sans bold uppercase, share card status
    static let shareNumber:     CGFloat = 64   // serif, share card numeral
    static let shareToday:      CGFloat = 52   // serif, "Today" on share card
    static let shareUnit:       CGFloat = 14   // sans, share card unit
    static let shareTitle:      CGFloat = 16   // sans semibold, share card title
    static let shareDate:       CGFloat = 12   // sans, share card date
    static let shareCredit:     CGFloat = 10   // sans, "Moments App" credit
    static let emptyHead:       CGFloat = 18   // sans semibold, empty state heading
    static let emptyBody:       CGFloat = 14   // sans, empty state body
    static let emptyBtn:        CGFloat = 15   // sans semibold, empty state CTA
}

// MARK: - Spacing & Layout

enum MSpace {
    static let screenH:          CGFloat = 20   // screen horizontal padding
    static let statusBar:        CGFloat = 54   // top spacer compensating for status bar
    static let headerBottom:     CGFloat = 4    // wordmark → hero card
    static let heroMargin:       CGFloat = 20   // hero card horizontal margin
    static let heroTopMargin:    CGFloat = 18   // wordmark row → hero card top
    static let heroRadius:       CGFloat = 28   // hero card corner radius
    static let heroPadTop:       CGFloat = 36   // hero card internal top padding
    static let heroPadH:         CGFloat = 24   // hero card internal side padding
    static let heroPadBottom:    CGFloat = 30   // hero card internal bottom padding
    static let heroStatusBottom: CGFloat = 14   // status label → numeral
    static let heroNumUnitGap:   CGFloat = 4    // numeral → unit
    static let heroUnitTitleGap: CGFloat = 18   // unit → title
    static let heroTitleDateGap: CGFloat = 3    // title → date
    static let heroTodayBottom:  CGFloat = 22   // "Today" word bottom margin
    static let rowV:             CGFloat = 16   // list row vertical padding each side
    static let rowH:             CGFloat = 6    // list row inner horizontal padding
    static let fabBottom:        CGFloat = 36   // FAB from bottom
    static let fabRight:         CGFloat = 24   // FAB from right
    static let fabSize:          CGFloat = 56   // FAB circle diameter
    static let fabIcon:          CGFloat = 24   // Plus icon size inside FAB
    static let formFieldGap:     CGFloat = 28   // vertical gap between form fields
    static let chipGap:          CGFloat = 8    // gap between recurrence chips
    static let chipV:            CGFloat = 9    // chip vertical padding
    static let chipH:            CGFloat = 16   // chip horizontal padding
    static let chipRadius:       CGFloat = 18   // chip corner radius
    static let segV:             CGFloat = 12   // segment button vertical padding
    static let segRadius:        CGFloat = 14   // segment button corner radius
    static let swipeDeleteW:     CGFloat = 76   // swipe-to-delete action width
    static let accentDot:        CGFloat = 30   // premium color swatch circle size
    static let iconBtn:          CGFloat = 38   // premium icon button size
    static let iconBtnRadius:    CGFloat = 12   // premium icon button corner radius
    static let toastH:           CGFloat = 28   // toast from bottom
    static let toastRadius:      CGFloat = 20   // toast corner radius
    static let toastPadV:        CGFloat = 10   // toast vertical padding
    static let toastPadH:        CGFloat = 18   // toast horizontal padding
    static let sheetRadius:      CGFloat = 24   // bottom sheet top corner radius
    static let sheetPadTop:      CGFloat = 28   // bottom sheet internal top padding
    static let sheetPadH:        CGFloat = 20   // bottom sheet horizontal padding
    static let sheetPadBottom:   CGFloat = 36   // bottom sheet bottom padding
    static let sheetBtnV:        CGFloat = 15   // bottom sheet button vertical padding
    static let sheetBtnRadius:   CGFloat = 16   // bottom sheet button corner radius
    static let sheetBtnGap:      CGFloat = 10   // gap between sheet buttons
    static let actionBtnV:       CGFloat = 11   // pin/reminder button vertical padding
    static let actionBtnH:       CGFloat = 20   // pin/reminder button horizontal padding
    static let actionBtnRadius:  CGFloat = 18   // pin/reminder button corner radius
    static let recurrPillPadV:   CGFloat = 6    // recurrence pill vertical padding
    static let recurrPillPadH:   CGFloat = 14   // recurrence pill horizontal padding
    static let recurrPillRadius: CGFloat = 14   // recurrence pill corner radius
    static let reminderChipV:    CGFloat = 8    // reminder chip vertical padding
    static let reminderChipH:    CGFloat = 14   // reminder chip horizontal padding
    static let reminderChipR:    CGFloat = 16   // reminder chip corner radius
    static let pinSectionTop:    CGFloat = 28   // top margin above pin section
    static let reminderTop:      CGFloat = 32   // top margin above reminder section
    static let paywallDot:       CGFloat = 14   // paywall accent dot size
    static let paywallDotGap:    CGFloat = 10   // paywall dot spacing
    static let paywallCheckCirc: CGFloat = 20   // paywall check circle size
    static let paywallCheckIcon: CGFloat = 12   // paywall check icon size
    static let shareCardRadius:  CGFloat = 20   // share card corner radius
    static let shareCardPadTop:  CGFloat = 28   // share card internal padding
    static let shareCardPadH:    CGFloat = 24
    static let shareCardPadBot:  CGFloat = 22
}

// MARK: - Surface Styles

/// Warm paper background: base color + two layered radial gradients
/// simulating paper catching light unevenly. Apply to the root app background.
struct MPaperBG: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            ZStack {
                Color.mPaper
                RadialGradient(
                    colors: [.white.opacity(0.55), .clear],
                    center: UnitPoint(x: 0.3, y: 0),
                    startRadius: 0, endRadius: 320
                )
                RadialGradient(
                    colors: [.black.opacity(0.025), .clear],
                    center: UnitPoint(x: 0.85, y: 1),
                    startRadius: 0, endRadius: 340
                )
            }
            .ignoresSafeArea()
        )
    }
}

/// Warm paper raised: same treatment on mPaperRaised.
/// Apply to the hero card and bottom sheets.
struct MPaperRaisedBG: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            ZStack {
                Color.mPaperRaised
                RadialGradient(
                    colors: [.white.opacity(0.55), .clear],
                    center: UnitPoint(x: 0.3, y: 0),
                    startRadius: 0, endRadius: 280
                )
            }
        )
    }
}

extension View {
    func paperBG() -> some View       { modifier(MPaperBG()) }
    func paperRaisedBG() -> some View  { modifier(MPaperRaisedBG()) }
}

// MARK: - App Constants

enum MBuild {
    static let label = "Jun28-3"
}

enum MConstants {
    /// Free tier entry cap. Paywall fires on attempt to add entry #11.
    static let freeEntryLimit = 10
    /// Pin duration: 7 days in seconds.
    static let pinDuration: TimeInterval = 7 * 24 * 60 * 60
    /// StoreKit product ID for the one-time unlock. Update with your App Store Connect ID.
    static let iapProductID = "com.yourname.moments.unlock"
    /// Fallback price string (real price comes from StoreKit Product).
    static let priceDisplay = "$4.99"
    /// IAP display name shown in the paywall CTA button.
    static let iapDisplayName = "Moments Unlimited"
}

// MARK: - Number Formatting

struct MagnitudeResult {
    let number: String   // e.g. "12", "3", "1.4", "Today"
    let unit: String     // e.g. "days", "weeks", "months", "years", ""
    let isToday: Bool
}

func formatMagnitude(days: Int) -> MagnitudeResult {
    if days == 0 {
        return MagnitudeResult(number: "Today", unit: "", isToday: true)
    }
    if days < 14 {
        return MagnitudeResult(number: "\(days)", unit: days == 1 ? "day" : "days", isToday: false)
    }
    if days < 60 {
        let w = (days + 3) / 7
        return MagnitudeResult(number: "\(w)", unit: "weeks", isToday: false)
    }
    if days < 365 {
        let m = (days + 15) / 30
        return MagnitudeResult(number: "\(m)", unit: "months", isToday: false)
    }
    let y = Double(days) / 365.0
    let r = (y * 10).rounded() / 10
    let s = r.truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(r))
        : String(format: "%.1f", r)
    return MagnitudeResult(number: s, unit: "years", isToday: false)
}

// MARK: - Color Hex Init

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
