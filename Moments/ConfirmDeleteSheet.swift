import SwiftUI

struct ConfirmDeleteSheet: View {
    let title: String
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // Dimmed overlay
            Color.black.opacity(0.32)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            // Sheet
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text("Delete \"\(title)\"?")
                        .font(.mSerif(19))
                        .foregroundStyle(Color.mInk)
                    Text("This can't be undone.")
                        .font(.mSans(14))
                        .foregroundStyle(Color.mInkSoft)
                        .lineSpacing(4)
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 22)

                VStack(spacing: 10) {
                    Button(action: onDelete) {
                        Text("Delete")
                            .font(.mSans(16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.mDestructive)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.mSans(16, weight: .semibold))
                            .foregroundStyle(Color.mInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.mPaperRaised)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, MSpacing.sheetPaddingH)
            .padding(.top, MSpacing.sheetPaddingV)
            .padding(.bottom, MSpacing.sheetPaddingBottom)
            .background(Color.mPaper)
            .clipShape(
                .rect(
                    topLeadingRadius: MSpacing.sheetRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: MSpacing.sheetRadius
                )
            )
            .shadow(color: .black.opacity(0.18), radius: 20, y: -8)
        }
        .ignoresSafeArea()
    }
}
