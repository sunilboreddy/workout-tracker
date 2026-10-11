import Foundation

struct Exercise: Codable, Equatable {
    var name: String
    var prescribed: String
}

struct PlanSection: Codable, Equatable, Identifiable {
    var title: String
    var icon: String
    var loggable: Bool
    var exercises: [Exercise]

    var id: String { title }
}

struct WorkoutPlan: Codable, Equatable, Identifiable {
    var id: Int64
    var name: String
    var favorite: Bool
    var sections: [PlanSection]

    init(id: Int64, name: String, favorite: Bool = false, sections: [PlanSection]) {
        self.id = id
        self.name = name
        self.favorite = favorite
        self.sections = sections
    }

    enum CodingKeys: String, CodingKey { case id, name, favorite, sections }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int64.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        favorite = (try? c.decode(Bool.self, forKey: .favorite)) ?? false
        sections = (try? c.decode([PlanSection].self, forKey: .sections)) ?? []
    }
}

enum SectionType {
    static let all: [(title: String, icon: String, loggable: Bool)] = [
        ("Warm-up", "🔥", false),
        ("Main Workout", "💪", true),
        ("Cardio Finisher", "🏃", true),
        ("Cool-down", "🧘", false)
    ]

    static func emptySections() -> [PlanSection] {
        all.map { PlanSection(title: $0.title, icon: $0.icon, loggable: $0.loggable, exercises: []) }
    }
}

/// Decodes a number that may be stored as a number, a numeric string, or null.
struct LenientNumber: Decodable {
    let value: Double?

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() {
            value = nil
        } else if let d = try? c.decode(Double.self) {
            value = d
        } else if let s = try? c.decode(String.self) {
            value = Double(s.trimmingCharacters(in: .whitespaces))
        } else {
            value = nil
        }
    }

    var intValue: Int {
        guard let v = value, v.isFinite, abs(v) < 1_000_000_000 else { return 0 }
        return Int(v)
    }
}

/// One exercise inside a saved workout. New entries carry per-set `weights`;
/// old and manually logged entries carry a single `weight`.
struct LoggedExercise: Codable, Equatable {
    var name: String
    var sets: [Int]
    var weights: [Double?]?
    var weight: Double?

    init(name: String, sets: [Int], weights: [Double?]? = nil, weight: Double? = nil) {
        self.name = name
        self.sets = sets
        self.weights = weights
        self.weight = weight
    }

    enum CodingKeys: String, CodingKey { case name, sets, weights, weight }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        let rawSets = (try? c.decode([LenientNumber].self, forKey: .sets)) ?? []
        sets = rawSets.map { $0.intValue }
        if let rawWeights = try? c.decode([LenientNumber].self, forKey: .weights) {
            weights = rawWeights.map { $0.value }
        } else {
            weights = nil
        }
        weight = (try? c.decode(LenientNumber.self, forKey: .weight))?.value
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(sets, forKey: .sets)
        try c.encodeIfPresent(weights, forKey: .weights)
        try c.encodeIfPresent(weight, forKey: .weight)
    }

    var totalReps: Int { sets.reduce(0, +) }
}

struct Workout: Codable, Equatable, Identifiable {
    var id: Int64
    var type: String
    var date: String
    var exercises: [LoggedExercise]
}

struct SetLog: Codable, Equatable {
    var reps: [Int] = []
    var weights: [Double?] = []
}

struct ActiveSession: Codable, Equatable {
    var planId: Int64
    var startedAt: Date
    var logged: [String: SetLog] = [:]
}

enum Formatting {
    static func kg(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }

    static func isoDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    static func parseISODay(_ s: String) -> Date? {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        if let d = f.date(from: s) { return d }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: s) { return d }
        iso.formatOptions = [.withInternetDateTime]
        return iso.date(from: s)
    }

    static func relativeDay(_ s: String, now: Date = Date()) -> String {
        guard let d = parseISODay(s) else { return s }
        let cal = Calendar.current
        if cal.isDate(d, inSameDayAs: now) { return "Today" }
        if let y = cal.date(byAdding: .day, value: -1, to: now), cal.isDate(d, inSameDayAs: y) { return "Yesterday" }
        return d.formatted(.dateTime.month(.abbreviated).day().year())
    }
}
