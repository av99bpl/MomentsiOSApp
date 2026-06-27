import SwiftUI

struct EmptyState: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("—")
                .font(.mSerif(56))
                .foregroundStyle(Color.mClayDim)
                .padding(.bottom, 18)

            Text("Nothing marked yet")
                .font(.mSans(18, weight: .semibold))
                .foregroundStyle(Color.mInk)
                .padding(.bottom, 8)

            Text("Add a date worth tracking — a birthday, an anniversary, or a day you'd like to remember.")
                .font(.mSans(14))
                .foregroundStyle(Color.mInkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 28)

            Button(action: onAdd) {
                Text("Add your first date")
                    .font(.mSans(15, weight: .semibold))
                    .foregroundStyle(Color.mPaper)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 26)
                    .background(Color.mInk)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
