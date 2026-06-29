// MomentsApp.swift
// Moments

import SwiftUI
import SwiftData
import UIKit

// Re-enables the interactive back-swipe gesture when the nav bar is hidden.
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}

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
