import Foundation

struct BackupFile: Codable {
    var workouts: [Workout]
    var workoutPlans: [WorkoutPlan]
    var exportedAt: String

    enum CodingKeys: String, CodingKey { case workouts, workoutPlans, exportedAt }

    init(workouts: [Workout], workoutPlans: [WorkoutPlan], exportedAt: String) {
        self.workouts = workouts
        self.workoutPlans = workoutPlans
        self.exportedAt = exportedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        workouts = (try? c.decode([Workout].self, forKey: .workouts)) ?? []
        workoutPlans = (try? c.decode([WorkoutPlan].self, forKey: .workoutPlans)) ?? []
        exportedAt = (try? c.decode(String.self, forKey: .exportedAt)) ?? ""
    }
}

enum Backup {
    static func encode(workouts: [Workout], plans: [WorkoutPlan], now: Date = Date()) throws -> Data {
        let file = BackupFile(
            workouts: workouts,
            workoutPlans: plans,
            exportedAt: ISO8601DateFormatter().string(from: now)
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(file)
    }

    static func decode(_ data: Data) throws -> BackupFile {
        try JSONDecoder().decode(BackupFile.self, from: data)
    }

    /// Add-only merge: incoming items whose id already exists are dropped.
    static func merge<T: Identifiable>(existing: [T], incoming: [T]) -> (merged: [T], added: Int) where T.ID == Int64 {
        let known = Set(existing.map { $0.id })
        var seen = known
        var fresh: [T] = []
        for item in incoming where !seen.contains(item.id) {
            seen.insert(item.id)
            fresh.append(item)
        }
        return (existing + fresh, fresh.count)
    }

    static func fileName(now: Date = Date()) -> String {
        "workout-backup-\(Formatting.isoDay(now)).json"
    }
}
