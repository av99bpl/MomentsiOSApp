import SwiftUI
import SwiftData

@main
struct MomentsApp: App {
    @State private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(for: MomentEntry.self)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                if let expiredTitle = appState.clearPinIfExpired() {
                    appState.showToast(
                        "Pin on \"\(expiredTitle)\" has expired — showing what's next",
                        duration: 3.2
                    )
                }
            }
        }
    }
}
