// ToastView.swift
// Moments

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.mSans(MType.toast, weight: .semibold))
            .foregroundStyle(Color.mPaper)
            .padding(.vertical, MSpace.toastPadV)
            .padding(.horizontal, MSpace.toastPadH)
            .background(Color.mInk)
            .clipShape(RoundedRectangle(cornerRadius: MSpace.toastRadius))
            .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
    }
}
