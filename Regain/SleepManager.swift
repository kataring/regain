import Foundation
import IOKit.pwr_mgt

@MainActor
final class SleepManager: ObservableObject {
    @Published private(set) var isActive = false
    @Published private(set) var activeSince: Date?
    private var systemSleepAssertionID: IOPMAssertionID = 0
    private var displaySleepAssertionID: IOPMAssertionID = 0

    init() {
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

    deinit {
        if systemSleepAssertionID != 0 {
            IOPMAssertionRelease(systemSleepAssertionID)
        }
        if displaySleepAssertionID != 0 {
            IOPMAssertionRelease(displaySleepAssertionID)
        }
    }
}
