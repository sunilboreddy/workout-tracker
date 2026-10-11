import UIKit
import AudioToolbox

/// UIKit feedback generators are silent no-ops on the Simulator.
enum Haptics {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func impact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

enum Feedback {
    static func timerDone() {
        Haptics.success()
        AudioServicesPlaySystemSound(1007)
    }
}
