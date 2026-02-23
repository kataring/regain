import Foundation
import IOKit.pwr_mgt

@MainActor
final class SleepManager: ObservableObject {
    @Published private(set) var isActive = false
    @Published private(set) var activeSince: Date?
    @Published private(set) var aggressiveModeEnabled = false

    private var systemSleepAssertionID: IOPMAssertionID = 0
    private var displaySleepAssertionID: IOPMAssertionID = 0

    init() {
        aggressiveModeEnabled = checkAggressiveMode()
        activate()
    }

    var uptime: String {
        guard let activeSince else { return "" }
        let interval = Date().timeIntervalSince(activeSince)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    func activate() {
        guard !isActive else { return }

        let name = "Regain: Preventing sleep" as CFString
        let properties: NSDictionary = [
            kIOPMAssertionTypeKey: kIOPMAssertionTypePreventSystemSleep,
            kIOPMAssertionNameKey: name,
            kIOPMAssertionLevelKey: kIOPMAssertionLevelOn,
        ]

        let systemResult = IOPMAssertionCreateWithProperties(
            properties,
            &systemSleepAssertionID
        )

        guard systemResult == kIOReturnSuccess else {
            print("Failed to create system sleep assertion: \(systemResult)")
            return
        }

        let displayResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            name,
            &displaySleepAssertionID
        )

        if displayResult != kIOReturnSuccess {
            print("Failed to create display sleep assertion: \(displayResult)")
            IOPMAssertionRelease(systemSleepAssertionID)
            systemSleepAssertionID = 0
            return
        }

        isActive = true
        activeSince = Date()
    }

    func deactivate() {
        guard isActive else { return }

        if systemSleepAssertionID != 0 {
            IOPMAssertionRelease(systemSleepAssertionID)
            systemSleepAssertionID = 0
        }

        if displaySleepAssertionID != 0 {
            IOPMAssertionRelease(displaySleepAssertionID)
            displaySleepAssertionID = 0
        }

        isActive = false
        activeSince = nil
    }

    func toggle() {
        if isActive {
            deactivate()
        } else {
            activate()
        }
    }

    func toggleAggressiveMode() {
        let script: String
        if aggressiveModeEnabled {
            script = "do shell script \"pmset restoredefaults\" with administrator privileges"
        } else {
            let cmds = [
                "pmset -a sleep 0 disksleep 0 displaysleep 0",
                "pmset -a hibernatemode 0 powernap 0",
                "pmset -a standby 0 autopoweroff 0",
                "pmset -a autorestart 1",
            ].joined(separator: " && ")
            script = "do shell script \"\(cmds)\" with administrator privileges"
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                aggressiveModeEnabled = !aggressiveModeEnabled
            }
        } catch {
            print("Failed to run pmset: \(error)")
        }
    }

    private func checkAggressiveMode() -> Bool {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g"]
        process.standardOutput = pipe
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return output.contains(" sleep\t\t0") && output.contains("hibernatemode\t\t0")
        } catch {
            return false
        }
    }

    deinit {
        if systemSleepAssertionID != 0 {
            IOPMAssertionRelease(systemSleepAssertionID)
        }
        if displaySleepAssertionID != 0 {
            IOPMAssertionRelease(displaySleepAssertionID)
        }
    }
}
