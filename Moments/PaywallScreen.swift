// PaywallScreen.swift
// Moments

import SwiftUI
import StoreKit

struct PaywallScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var product: Product? = nil
    @State private var isPurchasing = false
    @State private var isRestoring = false

    private let features = [
        "Unlimited entries",
        "All new features, free forever",
    ]

    private let comingSoon = [
        "Colors",
        "Widgets",
        "iCloud Sync",
        "Apple Watch app",
    ]

    var priceLabel: String {
        if let p = product { return "Unlock Moments — \(p.displayPrice)" }
        return "Unlock Moments — \(MConstants.priceDisplay)"
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Color.clear.frame(height: MSpace.statusBar)

                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.mInkSoft)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 8)

                Spacer()

                VStack(spacing: 0) {
                    Text("Moments Unlimited")
                        .font(.mSerif(MType.paywallHead))
                        .foregroundStyle(Color.mInk)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 12)

                    Text("Track everything that matters, your way.")
                        .font(.mSans(MType.paywallSub))
                        .foregroundStyle(Color.mInkSoft)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 36)

                    VStack(spacing: 0) {
                        ForEach(features, id: \.self) { feature in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.mInk)
                                    .frame(width: MSpace.paywallCheckCirc, height: MSpace.paywallCheckCirc)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: MSpace.paywallCheckIcon, weight: .bold))
                                            .foregroundStyle(Color.mPaper)
                                    )
                                Text(feature)
                                    .font(.mSans(MType.paywallFeature))
                                    .foregroundStyle(Color.mInk)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .overlay(alignment: .bottom) { Color.mHairline.frame(height: 1) }
                        }
                    }
                    .padding(.bottom, 24)

                    // Coming Soon
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Coming Soon")
                            .font(.mSans(MType.fieldLabel, weight: .semibold))
                            .foregroundStyle(Color.mInkSoft)
                            .tracking(1)
                            .textCase(.uppercase)
                            .padding(.bottom, 10)

                        ForEach(comingSoon, id: \.self) { item in
                            HStack(spacing: 12) {
                                Circle()
                                    .stroke(Color.mHairline, lineWidth: 1.5)
                                    .frame(width: MSpace.paywallCheckCirc, height: MSpace.paywallCheckCirc)
                                    .overlay(
                                        Image(systemName: "clock")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(Color.mInkSoft)
                                    )
                                Text(item)
                                    .font(.mSans(MType.paywallFeature))
                                    .foregroundStyle(Color.mInkSoft)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .overlay(alignment: .bottom) { Color.mHairline.frame(height: 1) }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 36)

                    Button {
                        Task { await purchase() }
                    } label: {
                        HStack(spacing: 8) {
                            if isPurchasing { ProgressView().tint(Color.mPaper) }
                            Text(priceLabel)
                                .font(.mSans(MType.paywallCTA, weight: .bold))
                                .foregroundStyle(Color.mPaper)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mInk)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .disabled(isPurchasing || isRestoring)
                    .padding(.bottom, 10)

                    Text("One-time purchase. No subscription.")
                        .font(.mSans(MType.paywallMeta))
                        .foregroundStyle(Color.mInkSoft)
                        .padding(.bottom, 18)

                    Button {
                        Task { await restore() }
                    } label: {
                        HStack(spacing: 8) {
                            if isRestoring {
                                ProgressView().tint(Color.mInkSoft).scaleEffect(0.8)
                            }
                            Text("Restore Purchase")
                                .font(.mSans(MType.paywallRestore))
                                .foregroundStyle(Color.mInkSoft)
                                .underline()
                        }
                    }
                    .disabled(isPurchasing || isRestoring)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
        .paperBG()
        .task { await loadProduct() }
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [MConstants.iapProductID])
            product = products.first
        } catch {}
    }

    func purchase() async {
        guard let product else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    appState.unlock()
                    dismiss()
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {}
    }

    func restore() async {
        isRestoring = true
        defer { isRestoring = false }
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let tx) = result, tx.productID == MConstants.iapProductID {
                    appState.unlock()
                    dismiss()
                    return
                }
            }
        } catch {}
    }
}
