import SwiftUI
import StoreKit

struct PaywallScreen: View {
    @Environment(AppState.self) private var appState
    let atLimit: Bool

    @State private var product: Product? = nil
    @State private var isPurchasing = false
    @State private var isRestoring = false

    private let features = [
        "Unlimited entries",
        "Custom color for each moment",
        "Custom icon for each moment",
    ]

    var priceLabel: String {
        if let p = product { return "Unlock Moments — \(p.displayPrice)" }
        return "Unlock Moments — \(MConstants.priceDisplay)"
    }

    var body: some View {
        ZStack {
            Color.mPaper.ignoresSafeArea()

            VStack(spacing: 0) {
                // Status bar spacer + close button
                Color.clear.frame(height: MSpacing.statusBar)
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.mInkSoft)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 8)

                Spacer()

                VStack(spacing: 0) {
                    // Color dots
                    HStack(spacing: 10) {
                        ForEach(AccentColor.all) { accent in
                            Circle()
                                .fill(accent.color)
                                .frame(width: 14, height: 14)
                        }
                    }
                    .padding(.bottom, 28)

                    Text("Moments Unlimited")
                        .font(.mSerif(32))
                        .foregroundStyle(Color.mInk)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 12)

                    Text(subtitle)
                        .font(.mSans(15))
                        .foregroundStyle(Color.mInkSoft)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 36)

                    // Feature list
                    VStack(spacing: 0) {
                        ForEach(features, id: \.self) { feature in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.mInk)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(Color.mPaper)
                                    )

                                Text(feature)
                                    .font(.mSans(15))
                                    .foregroundStyle(Color.mInk)

                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .overlay(alignment: .bottom) {
                                Color.mHairline.frame(height: 1)
                            }
                        }
                    }
                    .padding(.bottom, 36)

                    // CTA button
                    Button {
                        Task { await purchase() }
                    } label: {
                        HStack(spacing: 8) {
                            if isPurchasing {
                                ProgressView()
                                    .tint(Color.mPaper)
                            }
                            Text(priceLabel)
                                .font(.mSans(MTypography.paywallCTA, weight: .bold))
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
                        .font(.mSans(12))
                        .foregroundStyle(Color.mInkSoft)
                        .padding(.bottom, 18)

                    Button {
                        Task { await restore() }
                    } label: {
                        HStack(spacing: 8) {
                            if isRestoring {
                                ProgressView()
                                    .tint(Color.mInkSoft)
                                    .scaleEffect(0.8)
                            }
                            Text("Restore Purchase")
                                .font(.mSans(13))
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
        .task { await loadProduct() }
    }

    var subtitle: String {
        atLimit
            ? "You've reached the 10-entry limit on the free version. Unlock unlimited moments, your way."
            : "Track everything that matters, your way."
    }

    func dismiss() {
        appState.showPaywall = false
        if appState.paywallReturnToAdd {
            appState.paywallReturnToAdd = false
            appState.editingEntry = nil
            appState.showAddEdit = true
        }
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [MConstants.iapProductID])
            product = products.first
        } catch {
            // Proceed with fallback price display
        }
    }

    func purchase() async {
        guard let product else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified:
                    appState.unlock()
                    appState.showPaywall = false
                    appState.paywallReturnToAdd = false
                case .unverified:
                    break
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            // Purchase failed silently
        }
    }

    func restore() async {
        isRestoring = true
        defer { isRestoring = false }
        do {
            try await AppStore.sync()
            // Re-check entitlements
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   transaction.productID == MConstants.iapProductID {
                    appState.unlock()
                    appState.showPaywall = false
                    return
                }
            }
        } catch {
            // Restore failed silently
        }
    }
}
