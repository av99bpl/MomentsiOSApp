// MomentsApp.swift
// Moments

import SwiftUI
import SwiftData

@main
struct MomentsApp: App {
    @State private var appState = AppState()

    private static let container: ModelContainer = {
        try! ModelContainer(for: MomentEntry.self)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(Self.container)
    }
}
