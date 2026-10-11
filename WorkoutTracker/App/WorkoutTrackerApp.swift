import SwiftUI

@main
struct WorkoutTrackerApp: App {
    @State private var store = AppStore()
    @State private var timer = RestTimer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(timer)
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
        }
    }
}
