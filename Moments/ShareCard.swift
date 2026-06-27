// ShareCard.swift
// Moments

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Share Card View (renderable to image)

struct ShareCardView: View {
    let entry: MomentEntry

    private var mag: MagnitudeResult { entry.magnitude }

    var body: some View {
        VStack(spacing: 0) {
            Text(statusLabel)
                .font(.mSans(MType.shareStatus, weight: .bold))
                .foregroundStyle(Color.mClay)
                .tracking(0.8)
                .textCase(.uppercase)
                .padding(.bottom, 12)

            if entry.isToday {
                Text("Today")
                    .font(.mSerif(MType.shareToday))
                    .foregroundStyle(Color.mInk)
                    .padding(.bottom, 12)
            } else {
                Text(mag.number)
                    .font(.mSerif(MType.shareNumber))
                    .foregroundStyle(Color.mInk)
                    .monospacedDigit()
                    .tracking(-1.5)
                    .padding(.bottom, 4)
                Text("\(mag.unit) \(entry.isFuture ? "to go" : "since")")
                    .font(.mSans(MType.shareUnit))
                    .foregroundStyle(Color.mInkSoft)
                    .padding(.bottom, 12)
            }

            Text(entry.title)
                .font(.mSans(MType.shareTitle, weight: .semibold))
                .foregroundStyle(Color.mInk)
                .padding(.bottom, 4)

            Text(entry.nextOccurrence.formatted(.dateTime.month(.wide).day().year()))
                .font(.mSans(MType.shareDate))
                .foregroundStyle(Color.mInkSoft)
                .padding(.bottom, 14)

            Text("Moments App")
                .font(.mSans(MType.shareCredit))
                .foregroundStyle(Color.mClayDim)
                .tracking(0.5)
        }
        .multilineTextAlignment(.center)
        .padding(.top, MSpace.shareCardPadTop)
        .padding(.horizontal, MSpace.shareCardPadH)
        .padding(.bottom, MSpace.shareCardPadBot)
        .frame(width: 340)
        .paperRaisedBG()
        .overlay(
            RoundedRectangle(cornerRadius: MSpace.shareCardRadius)
                .stroke(Color.mHairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: MSpace.shareCardRadius))
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
                    .font(.mSans(MType.shareLabel, weight: .bold))
                    .foregroundStyle(Color.mInkSoft)
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .padding(.bottom, 16)

                ShareCardView(entry: entry)
                    .padding(.bottom, 20)

                HStack(spacing: 10) {
                    Button { saveToPhotos() } label: {
                        Text("Save Image")
                            .font(.mSans(15, weight: .bold))
                            .foregroundStyle(Color.mPaper)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.mInk)
                            .clipShape(RoundedRectangle(cornerRadius: MSpace.sheetBtnRadius))
                    }
                    Button { shareImage() } label: {
                        Text("Share…")
                            .font(.mSans(15, weight: .semibold))
                            .foregroundStyle(Color.mInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
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
