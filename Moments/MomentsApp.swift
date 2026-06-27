//
//  MomentsApp.swift
//  Moments
//
//  Created by Anoop Vishwakarma on 6/27/26.
//

import SwiftUI
import CoreData

@main
struct MomentsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
