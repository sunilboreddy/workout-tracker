import XCTest
@testable import WorkoutTracker

final class StatsTests: XCTestCase {
    private func workout(_ id: Int64, _ date: String, _ exercises: [LoggedExercise]) -> Workout {
        Workout(id: id, type: "T", date: date, exercises: exercises)
    }

    func testEmpty() {
        let s = Stats.compute(workouts: [])
        XCTAssertEqual(s, ProgressStats(total: 0, thisWeek: 0, bestPullups: nil, bestPushups: nil))
    }

    func testThisWeekStartsOnSunday() {
        let now = Formatting.parseISODay("2026-10-14")! // Wednesday; week began Sunday 2026-10-11
        let ws = [
            workout(1, "2026-10-11", []),
            workout(2, "2026-10-14", []),
            workout(3, "2026-10-10", [])
        ]
        let s = Stats.compute(workouts: ws, now: now)
        XCTAssertEqual(s.total, 3)
        XCTAssertEqual(s.thisWeek, 2)
    }

    func testBestPullupsAndPushupsAcrossShapes() {
        let ws = [
            workout(1, "2026-10-01", [
                LoggedExercise(name: "Pull-up Progression", sets: [5, 4, 3], weights: [nil, nil, nil]),
                LoggedExercise(name: "Push-ups", sets: [10, 10], weight: nil)
            ]),
            workout(2, "2026-10-02", [
                LoggedExercise(name: "Band Pullups", sets: [6, 6]),
                LoggedExercise(name: "Pike Push-ups", sets: [8, 8, 8], weights: [nil, nil, nil]),
                LoggedExercise(name: "Squat", sets: [100])
            ])
        ]
        let s = Stats.compute(workouts: ws)
        XCTAssertEqual(s.bestPullups, 12)
        XCTAssertEqual(s.bestPushups, 24)
    }

    func testNoPullupsGivesNil() {
        let ws = [workout(1, "2026-10-01", [LoggedExercise(name: "Squat", sets: [5])])]
        let s = Stats.compute(workouts: ws)
        XCTAssertNil(s.bestPullups)
        XCTAssertNil(s.bestPushups)
    }
}
