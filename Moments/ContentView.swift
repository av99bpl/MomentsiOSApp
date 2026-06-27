import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [MomentEntry]

    @State private var selectedTab: AppTab = .moments

    enum AppTab { case moments, widgets }

    var atLimit: Bool {
        !appState.isPremium && allEntries.count >= MConstants.freeEntryLimit
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                if selectedTab == .moments {
                    mainFlow
                } else {
                    widgetGalleryPlaceholder
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar (sits above content)
            tabBar
                .zIndex(5)

            // Toast above everything
            if let msg = appState.toastMessage {
                ToastView(message: msg)
                    .padding(.bottom, MSpacing.tabBarHeight + 16)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .zIndex(20)
                    .animation(.easeInOut(duration: 0.2), value: appState.toastMessage)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        // Add/Edit full screen cover
        .fullScreenCover(isPresented: Bindable(appState).showAddEdit) {
            AddEditScreen(existingEntry: appState.editingEntry)
                .environment(appState)
        }
        // Paywall full screen cover
        .fullScreenCover(isPresented: Bindable(appState).showPaywall) {
            PaywallScreen(atLimit: atLimit)
                .environment(appState)
        }
    }

    // MARK: - Main flow (list + detail)

    @ViewBuilder
    var mainFlow: some View {
        ZStack {
            // List is always rendered underneath
            ListScreen()

            // Detail slides over when an entry is selected
            if appState.showDetail, let entry = appState.selectedEntry {
                Color.mPaper.ignoresSafeArea()
                DetailScreen(entry: entry)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.28), value: appState.showDetail)
    }

    // MARK: - Widget gallery placeholder

    var widgetGalleryPlaceholder: some View {
        VStack(spacing: 16) {
            Color.clear.frame(height: MSpacing.statusBar)
            Text("WIDGETS")
                .font(.mSans(MTypography.wordmark, weight: .semibold))
                .foregroundStyle(Color.mInkSoft)
                .tracking(1.2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, MSpacing.screenH + 8)

            Spacer()
            Text("Widget preview coming soon.")
                .font(.mSans(15))
                .foregroundStyle(Color.mInkSoft)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mPaper)
    }

    // MARK: - Tab Bar

    var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(tab: .moments, label: "Moments", icon: "calendar")
            tabButton(tab: .widgets, label: "Widgets", icon: "square.grid.2x2")
        }
        .frame(height: MSpacing.tabBarHeight)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Color.mHairline.frame(height: 1)
        }
    }

    func tabButton(tab: AppTab, label: String, icon: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: selectedTab == tab ? .medium : .regular))
                    .foregroundStyle(selectedTab == tab ? Color.mClay : Color.mInkSoft)
                Text(label)
                    .font(.mSans(10, weight: .semibold))
                    .foregroundStyle(selectedTab == tab ? Color.mClay : Color.mInkSoft)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .buttonStyle(.plain)
    }
}
