// MomentsApp.swift
// Moments

import SwiftUI
import SwiftData

@main
struct MomentsApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(for: MomentEntry.self)
    }
}
