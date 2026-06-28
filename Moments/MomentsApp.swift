// MomentsApp.swift
// Moments

import SwiftUI
import SwiftData

@main
struct MomentsApp: App {
    @State private var appState = AppState()

    private static let container: ModelContainer = {
        let schema = Schema([MomentEntry.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
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
