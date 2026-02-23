import SwiftUI

@main
struct RegainApp: App {
    @StateObject private var sleepManager = SleepManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(sleepManager: sleepManager)
        } label: {
            Image(systemName: sleepManager.isActive ? "eye.fill" : "eye.slash")
        }
        .menuBarExtraStyle(.menu)
    }
}
