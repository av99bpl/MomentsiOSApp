// MomentsApp.swift
// Moments

import SwiftUI
import SwiftData

@main
struct MomentsApp: App {
    @State private var appState = AppState()

    private static let container: ModelContainer = {
        let schema = Schema([MomentEntry.self])
        let local = ModelConfiguration(schema: schema)
        return try! ModelContainer(for: schema, configurations: [local])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(Self.container)
    }
}
