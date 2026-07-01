// SharedStore.swift
// Moments
//
// The App Group container the app and widget extension both read/write.
// Keeps SwiftData and UserDefaults in one place so a single ModelContainer
// and defaults suite serve both processes.

import Foundation
import SwiftData

enum SharedStore {
    static var defaults: UserDefaults {
        UserDefaults(suiteName: MConstants.appGroupID) ?? .standard
    }

    static var storeURL: URL {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: MConstants.appGroupID)!
            .appendingPathComponent("Moments.sqlite")
    }

    static func makeContainer() -> ModelContainer {
        let schema = Schema([MomentEntry.self])
        let config = ModelConfiguration(schema: schema, url: storeURL)
        return try! ModelContainer(for: schema, configurations: [config])
    }
}
