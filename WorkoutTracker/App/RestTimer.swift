import Foundation
import Observation

@MainActor
@Observable
final class RestTimer {
    private(set) var remaining: Int = 0
    private(set) var isRunning = false
    private(set) var finishedCount = 0

    @ObservationIgnored private var endDate: Date?
    @ObservationIgnored private var ticker: Task<Void, Never>?
    @ObservationIgnored var onFinish: () -> Void = { Feedback.timerDone() }

    /// Starting a timer replaces any running one, so only one is ever active.
    func start(seconds: Int, now: Date = Date(), autoTick: Bool = true) {
        guard seconds > 0 else { return }
        cancelTicker()
        endDate = now.addingTimeInterval(TimeInterval(seconds))
        remaining = seconds
        isRunning = true
        guard autoTick else { return }
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 250_000_000)
                self?.tick(now: Date())
            }
        }
    }

    func tick(now: Date) {
        guard isRunning, let end = endDate else { return }
        let left = Int(ceil(end.timeIntervalSince(now)))
        if left <= 0 {
            finish()
        } else {
            remaining = left
        }
    }

    func stop() {
        cancelTicker()
        isRunning = false
        remaining = 0
        endDate = nil
    }

    private func finish() {
        stop()
        finishedCount += 1
        onFinish()
    }

    private func cancelTicker() {
        ticker?.cancel()
        ticker = nil
    }

    static func clock(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
