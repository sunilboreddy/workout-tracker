import XCTest
@testable import WorkoutTracker

@MainActor
final class RestTimerTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_000_000)

    func testCountsDownFromInjectedTime() {
        let timer = RestTimer()
        timer.onFinish = {}
        timer.start(seconds: 10, now: t0, autoTick: false)
        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(timer.remaining, 10)

        timer.tick(now: t0.addingTimeInterval(3))
        XCTAssertEqual(timer.remaining, 7)
        timer.tick(now: t0.addingTimeInterval(9.2))
        XCTAssertEqual(timer.remaining, 1)
        XCTAssertEqual(timer.finishedCount, 0)
    }

    func testFinishesOnceAndResets() {
        let timer = RestTimer()
        var fired = 0
        timer.onFinish = { fired += 1 }
        timer.start(seconds: 5, now: t0, autoTick: false)
        timer.tick(now: t0.addingTimeInterval(5))
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.remaining, 0)
        XCTAssertEqual(timer.finishedCount, 1)
        XCTAssertEqual(fired, 1)

        timer.tick(now: t0.addingTimeInterval(20))
        XCTAssertEqual(fired, 1, "a finished timer must not fire again")
    }

    func testStartingSecondTimerReplacesFirst() {
        let timer = RestTimer()
        var fired = 0
        timer.onFinish = { fired += 1 }
        timer.start(seconds: 5, now: t0, autoTick: false)
        timer.start(seconds: 3, now: t0.addingTimeInterval(1), autoTick: false)
        XCTAssertEqual(timer.remaining, 3)

        timer.tick(now: t0.addingTimeInterval(5)) // original would have finished here; replacement has 1s left
        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(fired, 0)

        timer.tick(now: t0.addingTimeInterval(4))
        XCTAssertEqual(fired, 1)
        XCTAssertFalse(timer.isRunning)
    }

    func testStopIsSilent() {
        let timer = RestTimer()
        var fired = 0
        timer.onFinish = { fired += 1 }
        timer.start(seconds: 5, now: t0, autoTick: false)
        timer.stop()
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.remaining, 0)
        timer.tick(now: t0.addingTimeInterval(10))
        XCTAssertEqual(fired, 0)
        XCTAssertEqual(timer.finishedCount, 0)
    }

    func testClockFormat() {
        XCTAssertEqual(RestTimer.clock(5), "00:05")
        XCTAssertEqual(RestTimer.clock(90), "01:30")
    }
}
