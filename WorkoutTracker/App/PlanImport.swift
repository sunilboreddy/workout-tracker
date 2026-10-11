import Foundation

enum PlanImportError: LocalizedError, Equatable {
    case invalidJSON(String)
    case missingName
    case missingSections

    var errorDescription: String? {
        switch self {
        case .invalidJSON(let detail):
            return "Invalid JSON: " + detail
        case .missingName:
            return "JSON must include a non-empty \"name\" string."
        case .missingSections:
            return "JSON must include a \"sections\" object keyed by section title (Warm-up, Main Workout, Cardio Finisher, Cool-down)."
        }
    }
}

enum PlanImport {
    static func newPlanId() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }

    static func parse(_ text: String, id: Int64 = PlanImport.newPlanId()) throws -> WorkoutPlan {
        guard let data = text.data(using: .utf8) else {
            throw PlanImportError.invalidJSON("text is not valid UTF-8")
        }
        let object: Any
        do {
            object = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
        } catch {
            throw PlanImportError.invalidJSON(error.localizedDescription)
        }

        guard let dict = object as? [String: Any],
              let rawName = dict["name"] as? String,
              !rawName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PlanImportError.missingName
        }
        guard let rawSections = dict["sections"] as? [String: Any] else {
            throw PlanImportError.missingSections
        }

        var sections = SectionType.emptySections()
        for index in sections.indices {
            guard let list = rawSections[sections[index].title] as? [Any] else { continue }
            sections[index].exercises = list.compactMap { item -> Exercise? in
                guard let entry = item as? [String: Any],
                      let name = entry["name"] as? String else { return nil }
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty { return nil }
                let prescribed = (entry["prescribed"] as? String)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return Exercise(name: trimmed, prescribed: prescribed)
            }
        }

        return WorkoutPlan(
            id: id,
            name: rawName.trimmingCharacters(in: .whitespacesAndNewlines),
            favorite: false,
            sections: sections
        )
    }
}
