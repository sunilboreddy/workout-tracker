import XCTest
@testable import WorkoutTracker

@MainActor
final class StoreTests: XCTestCase {
    private func tempDir() -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("wt-tests-\(UUID().uuidString)", isDirectory: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
        return url
    }

    func testSeedsThreePlansOnceAndPersists() {
        let dir = tempDir()
        let store = AppStore(directory: dir)
        XCTAssertEqual(store.plans.map { $0.id }, [1, 2, 3])

        store.deletePlan(id: 2)
        let reopened = AppStore(directory: dir)
        XCTAssertEqual(reopened.plans.map { $0.id }, [1, 3], "deleted seed must not be re-seeded")
    }

    func testFavoriteAndSavePlan() {
        let store = AppStore(directory: tempDir())
        store.toggleFavorite(id: 1)
        XCTAssertTrue(store.plans.first { $0.id == 1 }!.favorite)
        store.toggleFavorite(id: 1)
        XCTAssertFalse(store.plans.first { $0.id == 1 }!.favorite)

        var edited = store.plans[0]
        edited.name = "Renamed"
        store.savePlan(edited)
        XCTAssertEqual(store.plans.count, 3)
        XCTAssertEqual(store.plans[0].name, "Renamed")

        store.savePlan(WorkoutPlan(id: 99, name: "New", sections: SectionType.emptySections()))
        XCTAssertEqual(store.plans.count, 4)
    }

    func testLoggingKeepsRepsAndWeightsAligned() {
        let store = AppStore(directory: tempDir())
        store.startSession(planId: 1)
        store.logSet(exercise: "Bench", reps: 10, weight: 50)
        store.logSet(exercise: "Bench", reps: 8, weight: 55)
        store.logSet(exercise: "Bench", reps: 6, weight: nil)
        store.logSet(exercise: "Bench", reps: 0, weight: 60) // ignored

        var log = store.session!.logged["Bench"]!
        XCTAssertEqual(log.reps, [10, 8, 6])
        XCTAssertEqual(log.weights, [50, 55, nil])

        store.editSet(exercise: "Bench", index: 0, reps: 11, weight: 52)
        log = store.session!.logged["Bench"]!
        XCTAssertEqual(log.reps, [11, 8, 6])
        XCTAssertEqual(log.weights, [52, 55, nil])

        store.deleteSet(exercise: "Bench", index: 0)
        log = store.session!.logged["Bench"]!
        XCTAssertEqual(log.reps, [8, 6])
        XCTAssertEqual(log.weights, [55, nil])

        store.deleteSet(exercise: "Bench", index: 0)
        store.deleteSet(exercise: "Bench", index: 0)
        XCTAssertNil(store.session!.logged["Bench"], "exercise with no sets is removed")
    }

    func testEndSessionWithNoSetsSavesNothing() {
        let dir = tempDir()
        let store = AppStore(directory: dir)
        store.startSession(planId: 1)
        store.endSession()
        XCTAssertNil(store.session)
        XCTAssertTrue(store.workouts.isEmpty)
        XCTAssertNil(AppStore(directory: dir).session)
    }

    func testEndSessionSavesNewShapeWorkout() {
        let store = AppStore(directory: tempDir())
        store.startSession(planId: 1)
        store.logSet(exercise: "Plank", reps: 1, weight: nil)
        store.logSet(exercise: "Push-up Progression", reps: 12, weight: nil)
        store.logSet(exercise: "Push-up Progression", reps: 10, weight: 5)
        let now = Formatting.parseISODay("2026-10-14")!
        store.endSession(now: now)

        XCTAssertNil(store.session)
        XCTAssertEqual(store.workouts.count, 1)
        let w = store.workouts[0]
        XCTAssertEqual(w.type, "Day 1 – Upper Body Push + Core")
        XCTAssertEqual(w.date, "2026-10-14")
        XCTAssertEqual(w.exercises.map { $0.name }, ["Push-up Progression", "Plank"], "ordered by plan, not by when logged")
        XCTAssertEqual(w.exercises[0].sets, [12, 10])
        XCTAssertEqual(w.exercises[0].weights, [nil, 5])
        XCTAssertNil(w.exercises[0].weight)
    }

    func testSessionSurvivesRelaunch() {
        let dir = tempDir()
        let store = AppStore(directory: dir)
        store.startSession(planId: 3)
        store.logSet(exercise: "Pull-up Progression", reps: 5, weight: nil)

        let reopened = AppStore(directory: dir)
        XCTAssertEqual(reopened.session?.planId, 3)
        XCTAssertEqual(reopened.session?.logged["Pull-up Progression"]?.reps, [5])
        XCTAssertEqual(reopened.sessionPlan?.id, 3)
    }

    func testStartSessionDoesNotReplaceExisting() {
        let store = AppStore(directory: tempDir())
        store.startSession(planId: 1)
        store.startSession(planId: 2)
        XCTAssertEqual(store.session?.planId, 1)
    }

    func testManualWorkoutAndDelete() {
        let store = AppStore(directory: tempDir())
        let day = Formatting.parseISODay("2026-09-01")!
        store.addManualWorkout(type: "Full Body", date: day, exercises: [LoggedExercise(name: "Squat", sets: [5, 5], weight: 60)])
        XCTAssertEqual(store.workouts.count, 1)
        XCTAssertEqual(store.workouts[0].date, "2026-09-01")
        XCTAssertEqual(store.workouts[0].exercises[0].weight, 60)
        XCTAssertNil(store.workouts[0].exercises[0].weights)
        store.deleteWorkout(id: store.workouts[0].id)
        XCTAssertTrue(store.workouts.isEmpty)
    }

    func testWorkoutsPersistAcrossRelaunch() {
        let dir = tempDir()
        let store = AppStore(directory: dir)
        store.addManualWorkout(type: "Lower Body", date: Date(), exercises: [LoggedExercise(name: "Squat", sets: [5], weight: 60)])
        XCTAssertEqual(AppStore(directory: dir).workouts.count, 1)
    }

    // MARK: Backup

    private let webBackup = """
    {
      "workouts": [
        {"id": 100, "type": "Upper Body Push", "date": "2026-06-01",
         "exercises": [{"name": "DB Press", "weight": "20", "sets": [10, 9]}]},
        {"id": 101, "type": "Day 3", "date": "2026-06-02",
         "exercises": [{"name": "Pull-ups", "sets": [5, 4], "weights": [null, 10]}]}
      ],
      "workoutPlans": [
        {"id": 1, "name": "Seed clash", "favorite": true, "sections": []},
        {"id": 555, "name": "Imported", "favorite": false, "sections": []}
      ],
      "exportedAt": "2026-06-25T12:00:00.000Z"
    }
    """

    func testImportBackupIsAddOnlyAndIdempotent() throws {
        let store = AppStore(directory: tempDir())
        let first = try store.importBackup(Data(webBackup.utf8))
        XCTAssertEqual(first.workouts, 2)
        XCTAssertEqual(first.plans, 1, "plan id 1 already exists and must be kept as-is")
        XCTAssertEqual(store.plans.count, 4)
        XCTAssertEqual(store.plans.first { $0.id == 1 }?.name, "Day 1 – Upper Body Push + Core")
        XCTAssertEqual(store.workouts.count, 2)

        let second = try store.importBackup(Data(webBackup.utf8))
        XCTAssertEqual(second.workouts, 0)
        XCTAssertEqual(second.plans, 0)
        XCTAssertEqual(store.workouts.count, 2)
    }

    func testImportBackupKeepsExistingWorkouts() throws {
        let store = AppStore(directory: tempDir())
        store.addManualWorkout(type: "Mine", date: Date(), exercises: [LoggedExercise(name: "X", sets: [1])])
        try store.importBackup(Data(webBackup.utf8))
        XCTAssertEqual(store.workouts.count, 3)
        XCTAssertTrue(store.workouts.contains { $0.type == "Mine" })
    }

    func testMalformedBackupChangesNothing() {
        let dir = tempDir()
        let store = AppStore(directory: dir)
        store.addManualWorkout(type: "Mine", date: Date(), exercises: [LoggedExercise(name: "X", sets: [1])])
        XCTAssertThrowsError(try store.importBackup(Data("not json at all".utf8)))
        XCTAssertEqual(store.workouts.count, 1)
        XCTAssertEqual(store.plans.count, 3)
        XCTAssertEqual(AppStore(directory: dir).workouts.count, 1)
    }

    func testExportThenImportRoundTrips() throws {
        let source = AppStore(directory: tempDir())
        source.addManualWorkout(type: "Full Body", date: Date(), exercises: [LoggedExercise(name: "Squat", sets: [5, 5], weight: 60)])
        source.startSession(planId: 2)
        source.logSet(exercise: "Goblet Squat", reps: 10, weight: 24)
        source.endSession()
        let data = try source.exportData()

        let target = AppStore(directory: tempDir())
        let added = try target.importBackup(data)
        XCTAssertEqual(added.workouts, 2)
        XCTAssertEqual(added.plans, 0, "seed plans already present on the target")
        XCTAssertEqual(Set(target.workouts.map { $0.id }), Set(source.workouts.map { $0.id }))
        XCTAssertEqual(target.workouts.flatMap { $0.exercises }.count, 2)
    }

    func testBackupFileName() {
        let day = Formatting.parseISODay("2026-06-25")!
        XCTAssertEqual(Backup.fileName(now: day), "workout-backup-2026-06-25.json")
    }
}
