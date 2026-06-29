// ContentView.swift
// Moments
//
// Root: NavigationStack wrapping ListScreen.
// Owns the nav path and all navigationDestination routes.

import SwiftUI
import SwiftData

enum NavDest: Hashable {
    case detail(PersistentIdentifier)
    case addEdit(PersistentIdentifier?)  // nil = add mode
    case paywall
}

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Query private var allEntries: [MomentEntry]
    @Environment(\.scenePhase) private var scenePhase
    @State private var navPath: [NavDest] = []

    var body: some View {
        NavigationStack(path: $navPath) {
            ListScreen(onNavigate: { navPath.append($0) })
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: NavDest.self) { dest in
                    destination(for: dest)
                }
        }
        .background(Color.mPaper)
        .overlay(alignment: .bottom) {
            ZStack {
                if let msg = appState.toastMessage {
                    ToastView(message: msg)
                        .padding(.bottom, MSpace.toastH)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: appState.toastMessage)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                appState.checkPinExpiry(entries: allEntries)
            }
        }
    }

    @ViewBuilder
    private func destination(for dest: NavDest) -> some View {
        switch dest {
        case .detail(let id):
            DetailScreen(entryID: id, onNavigate: { navPath.append($0) })
                .toolbar(.hidden, for: .navigationBar)
        case .addEdit(let id):
            AddEditScreen(
                existingID: id,
                onNavigate: { navPath.append($0) }
            )
            .toolbar(.hidden, for: .navigationBar)
        case .paywall:
            PaywallScreen()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}
