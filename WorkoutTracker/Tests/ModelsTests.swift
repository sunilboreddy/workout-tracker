import XCTest
@testable import WorkoutTracker

final class ModelsTests: XCTestCase {
    private func decodeWorkouts(_ json: String) throws -> [Workout] {
        try JSONDecoder().decode([Workout].self, from: Data(json.utf8))
    }

    func testDecodesLegacyShapeWithNumericAndStringWeights() throws {
        let json = """
        [
          {"id": 1700000000001, "type": "Upper Body Push", "date": "2026-06-01",
           "exercises": [
             {"name": "DB Press", "weight": 20, "sets": [10, 9, 8]},
             {"name": "Pull-ups", "weight": "12.5", "sets": [5, 4]},
             {"name": "Plank", "weight": null, "sets": [1]}
           ]}
        ]
        """
        let w = try decodeWorkouts(json)
        XCTAssertEqual(w.count, 1)
        XCTAssertEqual(w[0].id, 1700000000001)
        XCTAssertEqual(w[0].exercises[0].weight, 20)
        XCTAssertNil(w[0].exercises[0].weights)
        XCTAssertEqual(w[0].exercises[1].weight, 12.5)
        XCTAssertNil(w[0].exercises[2].weight)
        XCTAssertEqual(w[0].exercises[0].totalReps, 27)
    }

    func testDecodesPerSetWeightsIncludingNulls() throws {
        let json = """
        [{"id": 2, "type": "Day 1", "date": "2026-06-02",
          "exercises": [{"name": "Bench", "sets": [10, 8, 6], "weights": [50, null, "60"]}]}]
        """
        let w = try decodeWorkouts(json)
        let ex = w[0].exercises[0]
        XCTAssertEqual(ex.sets, [10, 8, 6])
        let weights = try XCTUnwrap(ex.weights)
        XCTAssertEqual(weights.count, 3)
        XCTAssertEqual(weights[0], 50)
        XCTAssertNil(weights[1])
        XCTAssertEqual(weights[2], 60)
    }

    func testBadSetValueDoesNotFailWholeDecode() throws {
        let json = """
        [{"id": 3, "type": "T", "date": "2026-06-03",
          "exercises": [{"name": "X", "sets": [5, "abc", 7]}]}]
        """
        let w = try decodeWorkouts(json)
        XCTAssertEqual(w[0].exercises[0].sets, [5, 0, 7])
    }

    func testWorkoutRoundTrip() throws {
        let original = Workout(id: 9, type: "T", date: "2026-06-04", exercises: [
            LoggedExercise(name: "A", sets: [1, 2], weights: [10, nil]),
            LoggedExercise(name: "B", sets: [3], weights: nil, weight: 5)
        ])
        let data = try JSONEncoder().encode([original])
        let decoded = try JSONDecoder().decode([Workout].self, from: data)
        XCTAssertEqual(decoded, [original])
    }

    func testPlanDecodesWithoutFavoriteKey() throws {
        let json = """
        {"id": 5, "name": "P", "sections": [
          {"title": "Warm-up", "icon": "🔥", "loggable": false,
           "exercises": [{"name": "Arm Circles", "prescribed": "30s"}]}]}
        """
        let p = try JSONDecoder().decode(WorkoutPlan.self, from: Data(json.utf8))
        XCTAssertFalse(p.favorite)
        XCTAssertEqual(p.sections[0].exercises[0].name, "Arm Circles")
    }

    func testSeedPlansShape() {
        XCTAssertEqual(SeedPlans.all.map { $0.id }, [1, 2, 3])
        for plan in SeedPlans.all {
            XCTAssertEqual(plan.sections.map { $0.title }, ["Warm-up", "Main Workout", "Cardio Finisher", "Cool-down"])
            XCTAssertEqual(plan.sections.map { $0.loggable }, [false, true, true, false])
        }
        XCTAssertEqual(SeedPlans.all[0].sections[1].exercises.count, 10)
    }
}
