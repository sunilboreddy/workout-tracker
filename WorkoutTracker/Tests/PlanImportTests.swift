import XCTest
@testable import WorkoutTracker

final class PlanImportTests: XCTestCase {
    func testValidPartialPlanLeavesOtherSectionsEmpty() throws {
        let json = """
        {"name": "  Day 1 – Upper  ",
         "sections": {
           "Warm-up": [{"name": "Arm Circles", "prescribed": " 30s "}],
           "Main Workout": [{"name": "Bench Press", "prescribed": "3x10"}, {"name": "  "}, {"prescribed": "x"}, {"name": "Row"}]
         }}
        """
        let plan = try PlanImport.parse(json, id: 42)
        XCTAssertEqual(plan.id, 42)
        XCTAssertEqual(plan.name, "Day 1 – Upper")
        XCTAssertFalse(plan.favorite)
        XCTAssertEqual(plan.sections.count, 4)
        XCTAssertEqual(plan.sections[0].exercises, [Exercise(name: "Arm Circles", prescribed: "30s")])
        XCTAssertEqual(plan.sections[1].exercises, [
            Exercise(name: "Bench Press", prescribed: "3x10"),
            Exercise(name: "Row", prescribed: "")
        ])
        XCTAssertTrue(plan.sections[2].exercises.isEmpty)
        XCTAssertTrue(plan.sections[3].exercises.isEmpty)
        XCTAssertEqual(plan.sections.map { $0.loggable }, [false, true, true, false])
    }

    func testInvalidJSON() {
        XCTAssertThrowsError(try PlanImport.parse("{not json")) { error in
            guard case PlanImportError.invalidJSON = error else {
                return XCTFail("expected invalidJSON, got \(error)")
            }
            XCTAssertTrue(error.localizedDescription.hasPrefix("Invalid JSON:"))
        }
    }

    func testMissingOrBlankName() {
        XCTAssertThrowsError(try PlanImport.parse(#"{"sections": {}}"#)) {
            XCTAssertEqual($0 as? PlanImportError, .missingName)
        }
        XCTAssertThrowsError(try PlanImport.parse(#"{"name": "   ", "sections": {}}"#)) {
            XCTAssertEqual($0 as? PlanImportError, .missingName)
        }
        XCTAssertThrowsError(try PlanImport.parse("[]")) {
            XCTAssertEqual($0 as? PlanImportError, .missingName)
        }
    }

    func testMissingSections() {
        XCTAssertThrowsError(try PlanImport.parse(#"{"name": "P"}"#)) {
            XCTAssertEqual($0 as? PlanImportError, .missingSections)
        }
        XCTAssertThrowsError(try PlanImport.parse(#"{"name": "P", "sections": []}"#)) {
            XCTAssertEqual($0 as? PlanImportError, .missingSections)
        }
    }
}
