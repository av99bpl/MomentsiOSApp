// ConfirmDeleteSheet.swift
// Moments

import SwiftUI

struct ConfirmDeleteSheet: View {
    let title: String
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.32)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text("Delete \"\(title)\"?")
                        .font(.mSerif(MType.sheetTitle))
                        .foregroundStyle(Color.mInk)
                    Text("This can't be undone.")
                        .font(.mSans(MType.sheetSubtitle))
                        .foregroundStyle(Color.mInkSoft)
                        .lineSpacing(4)
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 22)

                VStack(spacing: MSpace.sheetBtnGap) {
                    Button(action: onDelete) {
                        Text("Delete")
                            .font(.mSans(MType.sheetBtn, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, MSpace.sheetBtnV)
                            .background(Color.mDestructive)
                            .clipShape(RoundedRectangle(cornerRadius: MSpace.sheetBtnRadius))
                    }
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.mSans(MType.sheetBtn, weight: .semibold))
                            .foregroundStyle(Color.mInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, MSpace.sheetBtnV)
                            .background(Color.mPaperRaised)
                            .clipShape(RoundedRectangle(cornerRadius: MSpace.sheetBtnRadius))
                    }
                }
            }
            .padding(.horizontal, MSpace.sheetPadH)
            .padding(.top, MSpace.sheetPadTop)
            .padding(.bottom, MSpace.sheetPadBottom)
            .background(Color.mPaper)
            .clipShape(
                .rect(
                    topLeadingRadius: MSpace.sheetRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: MSpace.sheetRadius
                )
            )
            .shadow(color: .black.opacity(0.18), radius: 20, y: -8)
        }
        .ignoresSafeArea()
    }
}
