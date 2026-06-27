// MomentsApp.swift
// Moments

import SwiftUI
import SwiftData

@main
struct MomentsApp: App {
    @State private var appState = AppState()

    private static let container: ModelContainer = {
        let schema = Schema([MomentEntry.self])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.Vishful.Moments")
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Fallback to local store if CloudKit is unavailable (e.g. not signed in)
            let localConfig = ModelConfiguration(schema: schema)
            return try! ModelContainer(for: schema, configurations: [localConfig])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(Self.container)
    }
}
