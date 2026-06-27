// DesignSystem.swift
// Moments
//
// Single source of truth for all visual design decisions.
// Values extracted 1:1 from the React prototype (moments-preview.jsx).
// Do not hardcode colors, fonts, or spacing anywhere else in the project.

import SwiftUI

// MARK: - Color Palette

extension Color {
    // Base surfaces
    /// Warm off-white app background. Hex: #FAF8F5
    static let mPaper        = Color(hex: "FAF8F5")
    /// Slightly deeper warm white for raised surfaces (hero card, sheets). Hex: #F3F0EA
    static let mPaperRaised  = Color(hex: "F3F0EA")

    // Text
    /// Near-black primary text. Hex: #1C1B19
    static let mInk          = Color(hex: "1C1B19")
    /// Warm mid-gray for secondary labels, units, dates. Hex: #6B6760
    static let mInkSoft      = Color(hex: "6B6760")

    // Structure
    /// Hairline divider between list rows. 1pt, never thicker. Hex: #E4E0D8
    static let mHairline      = Color(hex: "E4E0D8")

    // Accent — RESERVED. Use only for the hero event and its detail view.
    // Do not apply to buttons, chips, navigation, or secondary UI.
    /// Muted terracotta/clay. The single accent color. Hex: #B8693F
    static let mClay          = Color(hex: "B8693F")
    /// Pale clay for empty state decorations only. Hex: #D9B6A4
    static let mClayDim       = Color(hex: "D9B6A4")

    // Past events (count-up entries in the ledger list)
    /// Cool gray for past/ongoing events. Never red — no urgency. Hex: #9C988F
    static let mPast          = Color(hex: "9C988F")

    // Destructive (delete only — not used for any other state)
    /// Dark red for delete actions. Hex: #A8472E
    static let mDestructive   = Color(hex: "A8472E")

    // Variant B: Frosted glass backdrop
    /// Cool blue-gray app background when variant = .frosted. Hex: #D6DCE8
    static let mFrostBackdrop = Color(hex: "D6DCE8")
}

// MARK: - Premium Accent Palette
// Curated 6-color muted palette for premium per-entry color customization.
// All tones stay within the same restrained, unsaturated family as clay.
// No saturated, neon, or high-contrast options.

struct AccentColor: Identifiable, Hashable {
    let id: String
    let color: Color
    let hex: String
}

extension AccentColor {
    static let all: [AccentColor] = [
        AccentColor(id: "clay",  color: Color(hex: "B8693F"), hex: "B8693F"),
        AccentColor(id: "sage",  color: Color(hex: "7C8A6E"), hex: "7C8A6E"),
        AccentColor(id: "dusk",  color: Color(hex: "6E7691"), hex: "6E7691"),
        AccentColor(id: "plum",  color: Color(hex: "8A6378"), hex: "8A6378"),
        AccentColor(id: "ochre", color: Color(hex: "B68A3D"), hex: "B68A3D"),
        AccentColor(id: "slate", color: Color(hex: "5C6B6B"), hex: "5C6B6B"),
    ]
    static let `default` = all[0] // clay
}

// MARK: - Typography

extension Font {
    // Serif — used exclusively for the big countdown/countup numerals
    // and the hero "Today" word. The emotional centerpiece of the app.
    // iOS fallback chain: Palatino → Georgia (system serif)
    static func mSerif(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        Font.custom("Palatino-Roman", size: size)
            .weight(weight)
    }

    // Sans — SF Pro (system default on iOS). Used for all UI chrome,
    // labels, navigation, body text, and buttons.
    static func mSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Type Scale
// All font sizes used in the app. Named by role, not by px value.

enum MTypography {
    // Hero number — the big serif countdown/countup numeral on the hero card
    static let heroNumber: CGFloat     = 88
    // Hero number on detail screen (slightly larger)
    static let detailNumber: CGFloat   = 96
    // "Today" word replacing the number when diffDays == 0
    static let todayWord: CGFloat      = 72  // hero card
    static let todayWordDetail: CGFloat = 80 // detail screen
    // Widget small serif number
    static let widgetSmallNumber: CGFloat = 58
    // Widget medium serif number
    static let widgetMediumNumber: CGFloat = 52
    // Hero card title
    static let heroTitle: CGFloat      = 19
    // Hero card date label
    static let heroDate: CGFloat       = 14
    // Hero card unit label ("days to go", "months since")
    static let heroUnit: CGFloat       = 17
    // Hero card status label ("COMING UP", "PINNED", "TODAY")
    static let heroStatus: CGFloat     = 13
    // List row title
    static let rowTitle: CGFloat       = 16
    // List row subtitle (recurrence, "Upcoming", "Ongoing")
    static let rowSubtitle: CGFloat    = 13
    // List row right-aligned serif number
    static let rowNumber: CGFloat      = 22
    // List row right-aligned unit
    static let rowUnit: CGFloat        = 13
    // Detail screen title
    static let detailTitle: CGFloat    = 22
    // Detail screen date
    static let detailDate: CGFloat     = 15
    // Detail screen unit label
    static let detailUnit: CGFloat     = 18
    // Nav bar items, section labels
    static let navItem: CGFloat        = 16
    // Small caps wordmark ("MOMENTS")
    static let wordmark: CGFloat       = 13
    // Field labels in Add/Edit form (uppercase)
    static let fieldLabel: CGFloat     = 12
    // Recurrence chip / segment button
    static let chip: CGFloat           = 13 // and 14 for seg buttons
    // Paywall CTA
    static let paywallCTA: CGFloat     = 16
    // Toast message
    static let toast: CGFloat          = 13
    // Entry counter "8/10"
    static let counter: CGFloat        = 12
}

// MARK: - Spacing & Layout

enum MSpacing {
    // Screen horizontal padding (list rows, content areas)
    static let screenH: CGFloat     = 20
    // Hero card internal padding: top/bottom 36, sides 24
    static let heroCardV: CGFloat   = 36
    static let heroCardH: CGFloat   = 24
    static let heroCardBottom: CGFloat = 30
    // Hero card corner radius
    static let heroCardRadius: CGFloat = 28
    // Hero card margin from screen edges
    static let heroCardMargin: CGFloat = 20
    // Hero card top margin from wordmark
    static let heroCardTopMargin: CGFloat = 18
    // List row vertical padding (each side)
    static let rowV: CGFloat        = 16
    // List row horizontal padding (inner)
    static let rowH: CGFloat        = 6
    // Status bar spacer (top of each screen, compensates for status bar)
    static let statusBar: CGFloat   = 54
    // Section header bottom margin
    static let headerBottom: CGFloat = 4
    // Hero status label bottom margin
    static let statusLabelBottom: CGFloat = 14
    // Hero number → unit spacing
    static let numberUnitGap: CGFloat = 4
    // Hero unit → title spacing
    static let unitTitleGap: CGFloat = 18
    // Hero title → date spacing
    static let titleDateGap: CGFloat = 3
    // Add/Edit form field bottom margin
    static let formFieldGap: CGFloat = 28
    // Chip gap
    static let chipGap: CGFloat     = 8
    // FAB from bottom
    static let fabBottom: CGFloat   = 36
    // FAB from right
    static let fabRight: CGFloat    = 24
    // FAB size
    static let fabSize: CGFloat     = 56
    // Toast corner radius
    static let toastRadius: CGFloat = 20
    // Bottom sheet corner radius
    static let sheetRadius: CGFloat = 24
    // Confirmation sheet internal padding
    static let sheetPaddingH: CGFloat = 20
    static let sheetPaddingV: CGFloat = 28
    static let sheetPaddingBottom: CGFloat = 36
    // Pin/Reminder action button padding
    static let actionBtnH: CGFloat  = 20
    static let actionBtnV: CGFloat  = 11
    static let actionBtnRadius: CGFloat = 18
    // Tab bar height
    static let tabBarHeight: CGFloat = 82
    // Widget small size
    static let widgetSmall: CGFloat = 158
    // Widget medium size
    static let widgetMediumW: CGFloat = 338
    static let widgetMediumH: CGFloat = 158
    // Widget corner radius
    static let widgetRadius: CGFloat = 22
    // Widget internal padding
    static let widgetPadH: CGFloat  = 16
    static let widgetPadTop: CGFloat = 16
    static let widgetPadBottom: CGFloat = 14
    // Widget medium left panel width
    static let widgetMediumLeftW: CGFloat = 154
}

// MARK: - Surface Styles

struct MPaperBackground: ViewModifier {
    /// Variant A: warm paper with uneven light-catch gradient.
    /// Two radial gradients layered: bright top-left, subtle dark bottom-right.
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color.mPaper
                    // Bright upper-left catch (simulates paper in light)
                    RadialGradient(
                        colors: [Color.white.opacity(0.55), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0),
                        startRadius: 0,
                        endRadius: 320
                    )
                    // Subtle lower-right shadow
                    RadialGradient(
                        colors: [Color.black.opacity(0.025), Color.clear],
                        center: UnitPoint(x: 0.85, y: 1),
                        startRadius: 0,
                        endRadius: 340
                    )
                }
            )
    }
}

struct MPaperRaisedBackground: ViewModifier {
    /// Variant A raised surface (hero card, bottom sheets).
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color.mPaperRaised
                    RadialGradient(
                        colors: [Color.white.opacity(0.55), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0),
                        startRadius: 0,
                        endRadius: 280
                    )
                }
            )
    }
}

struct MFrostedBackground: ViewModifier {
    /// Variant B: frosted glass panel.
    /// Requires a non-white/colored background behind it to read correctly.
    /// Use Color.mFrostBackdrop as the app background in variant B.
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.white.opacity(0.75), lineWidth: 1)
            )
    }
}

extension View {
    func paperBackground() -> some View { modifier(MPaperBackground()) }
    func paperRaisedBackground() -> some View { modifier(MPaperRaisedBackground()) }
    func frostedBackground() -> some View { modifier(MFrostedBackground()) }
}

// MARK: - App Constants

enum MConstants {
    /// Free tier entry limit. Paywall triggers when user tries to add entry #11.
    static let freeEntryLimit = 10
    /// Duration a pinned hero entry stays pinned (7 days in seconds).
    static let pinDurationSeconds: TimeInterval = 7 * 24 * 60 * 60
    /// IAP product identifier for the one-time unlock.
    static let iapProductID = "com.yourname.moments.unlock"
    /// App Group identifier — must match in both app target and widget target entitlements.
    static let appGroupID = "group.com.yourname.moments"
    /// UserDefaults key for writing hero entry data to the App Group (for widgets).
    static let widgetDataKey = "heroEntryData"
    /// Price display string (mirrors StoreKit product, used as fallback only).
    static let priceDisplay = "$4.99"
}

// MARK: - Number Formatting
// Smart magnitude: avoids showing "1,847 days" — auto-converts to
// weeks → months → years based on magnitude.

struct FormattedMagnitude {
    let number: String  // "12", "3", "1.4", "Today"
    let unit: String    // "days", "weeks", "months", "years", "" (for Today)
    let isToday: Bool
}

func formatMagnitude(days: Int) -> FormattedMagnitude {
    if days == 0 { return FormattedMagnitude(number: "Today", unit: "", isToday: true) }
    if days < 14 { return FormattedMagnitude(number: "\(days)", unit: days == 1 ? "day" : "days", isToday: false) }
    if days < 60 {
        let w = (days + 3) / 7 // round
        return FormattedMagnitude(number: "\(w)", unit: "weeks", isToday: false)
    }
    if days < 365 {
        let m = (days + 15) / 30
        return FormattedMagnitude(number: "\(m)", unit: "months", isToday: false)
    }
    let years = Double(days) / 365.0
    let rounded = (years * 10).rounded() / 10
    let str = rounded.truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(rounded))
        : String(format: "%.1f", rounded)
    return FormattedMagnitude(number: str, unit: "years", isToday: false)
}

// MARK: - Color Hex Init (utility)

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
