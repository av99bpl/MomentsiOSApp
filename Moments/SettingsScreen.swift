// SettingsScreen.swift
// Moments

import SwiftUI

struct SettingsScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
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
            }
            .padding(.horizontal, 8)
            .padding(.top, MSpace.statusBar)

            Spacer()

            VStack(spacing: 10) {
                Image(systemName: "gearshape")
                    .font(.system(size: 36, weight: .thin))
                    .foregroundStyle(Color.mInkSoft.opacity(0.4))

                Text("Settings")
                    .font(.mSerif(24))
                    .foregroundStyle(Color.mInkSoft)

                Text("Coming soon")
                    .font(.mSans(MType.paywallSub))
                    .foregroundStyle(Color.mInkSoft.opacity(0.45))
            }

            Spacer()
        }
        .paperBG()
    }
}
