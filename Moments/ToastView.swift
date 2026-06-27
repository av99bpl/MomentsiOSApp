import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.mSans(MTypography.toast, weight: .semibold))
            .foregroundStyle(Color.mPaper)
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(Color.mInk)
            .clipShape(RoundedRectangle(cornerRadius: MSpacing.toastRadius))
            .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
    }
}
