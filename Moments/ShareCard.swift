import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Share Card View (renderable to image)

struct ShareCardView: View {
    let entry: MomentEntry

    private var mag: FormattedMagnitude { entry.magnitude }

    var body: some View {
        VStack(spacing: 0) {
            // Status
            Text(statusLabel)
                .font(.mSans(11, weight: .bold))
                .foregroundStyle(Color.mClay)
                .tracking(0.8)
                .textCase(.uppercase)
                .padding(.bottom, 12)

            // Number or Today
            if entry.isToday {
                Text("Today")
                    .font(.mSerif(52))
                    .foregroundStyle(Color.mInk)
                    .padding(.bottom, 12)
            } else {
                Text(mag.number)
                    .font(.mSerif(64))
                    .foregroundStyle(Color.mInk)
                    .monospacedDigit()
                    .tracking(-1.5)
                    .padding(.bottom, 4)
                Text("\(mag.unit) \(entry.isFuture ? "to go" : "since")")
                    .font(.mSans(14))
                    .foregroundStyle(Color.mInkSoft)
                    .padding(.bottom, 12)
            }

            // Title
            Text(entry.title)
                .font(.mSans(16, weight: .semibold))
                .foregroundStyle(Color.mInk)
                .padding(.bottom, 4)

            // Date
            Text(entry.nextOccurrence.formatted(.dateTime.month(.wide).day().year()))
                .font(.mSans(12))
                .foregroundStyle(Color.mInkSoft)
                .padding(.bottom, 14)

            // Credit
            Text("Moments App")
                .font(.mSans(10))
                .foregroundStyle(Color.mClayDim)
                .tracking(0.5)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 28)
        .padding(.horizontal, 24)
        .padding(.bottom, 22)
        .frame(width: 340)
        .paperRaisedBackground()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.mHairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var statusLabel: String {
        if entry.isToday { return "TODAY" }
        return entry.isFuture ? "COMING UP" : "ONGOING"
    }
}

// MARK: - Share Sheet

struct ShareSheet: View {
    let entry: MomentEntry
    let onDismiss: () -> Void

    @State private var renderedImage: UIImage? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.38)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                Text("Share this Moment")
                    .font(.mSans(12, weight: .bold))
                    .foregroundStyle(Color.mInkSoft)
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .padding(.bottom, 16)

                // Preview
                ShareCardView(entry: entry)
                    .padding(.bottom, 20)

                // Actions
                HStack(spacing: 10) {
                    Button {
                        saveToPhotos()
                    } label: {
                        Text("Save Image")
                            .font(.mSans(15, weight: .bold))
                            .foregroundStyle(Color.mPaper)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.mInk)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    Button {
                        shareImage()
                    } label: {
                        Text("Share…")
                            .font(.mSans(15, weight: .semibold))
                            .foregroundStyle(Color.mInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.mPaperRaised)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 36)
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
        .onAppear { renderCard() }
    }

    private func renderCard() {
        let card = ShareCardView(entry: entry)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3
        renderedImage = renderer.uiImage
    }

    private func saveToPhotos() {
        guard let img = renderedImage else { renderCard(); return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        onDismiss()
    }

    private func shareImage() {
        guard let img = renderedImage else { renderCard(); return }
        let vc = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(vc, animated: true)
        }
        onDismiss()
    }
}
