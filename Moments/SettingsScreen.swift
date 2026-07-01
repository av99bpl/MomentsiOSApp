// SettingsScreen.swift
// Moments

import SwiftUI

struct SettingsScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var state = appState
        VStack(spacing: 0) {
            navBar

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Appearance card
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Dark Mode")
                                .font(.mSans(16, weight: .medium))
                                .foregroundStyle(Color.mInk)
                            Text("Easier on the eyes at night")
                                .font(.mSans(13))
                                .foregroundStyle(Color.mInkSoft)
                        }
                        Spacer()
                        Toggle("", isOn: $state.prefersDarkMode)
                            .labelsHidden()
                            .tint(Color.mClay)
                    }
                    .padding(.horizontal, MSpace.heroPadH)
                    .padding(.vertical, 20)
                    .paperRaisedBG()
                    .clipShape(RoundedRectangle(cornerRadius: MSpace.heroRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: MSpace.heroRadius)
                            .stroke(Color.mHairline, lineWidth: 1)
                    )
                    .padding(.horizontal, MSpace.heroMargin)
                    .padding(.top, 16)

                    // Placeholder for future settings
                    VStack(spacing: 10) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 32, weight: .thin))
                            .foregroundStyle(Color.mInkSoft.opacity(0.35))
                        Text("More settings coming soon")
                            .font(.mSans(MType.paywallSub))
                            .foregroundStyle(Color.mInkSoft.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
        }
        .paperBG()
    }

    private var navBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                    Text("Back")
                        .font(.mSans(MType.navItem))
                }
                .foregroundStyle(Color.mInk)
            }
            .padding(8)

            Spacer()

            Text("SETTINGS")
                .font(.mSans(MType.wordmark, weight: .semibold))
                .foregroundStyle(Color.mInkSoft)
                .tracking(4)

            Spacer()

            Color.clear.frame(width: 60, height: 1)
        }
        .padding(.horizontal, 8)
        .padding(.top, MSpace.statusBar)
        .padding(.bottom, 8)
    }
}
