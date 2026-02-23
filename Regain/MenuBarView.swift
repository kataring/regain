import ServiceManagement
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var sleepManager: SleepManager
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Button {
            sleepManager.toggle()
        } label: {
            if sleepManager.isActive {
                Label("Active — \(sleepManager.uptime)", systemImage: "eye.fill")
            } else {
                Label("Inactive", systemImage: "eye.slash")
            }
        }
        .keyboardShortcut("t", modifiers: .command)

        Divider()

        Button {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.unregister()
                    launchAtLogin = false
                } else {
                    try SMAppService.mainApp.register()
                    launchAtLogin = true
                }
            } catch {
                print("Failed to update login item: \(error)")
            }
        } label: {
            HStack {
                Label("Launch at Login", systemImage: launchAtLogin ? "checkmark" : "")
            }
        }

        Divider()

        Button("Quit Regain") {
            sleepManager.deactivate()
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
