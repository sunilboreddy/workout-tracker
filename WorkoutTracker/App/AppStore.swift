import Foundation
import Observation

@MainActor
@Observable
final class AppStore {
    private(set) var plans: [WorkoutPlan] = []
    private(set) var workouts: [Workout] = []
    private(set) var session: ActiveSession?
    var lastError: String?

    private let directory: URL

    private static let plansFile = "plans.json"
    private static let workoutsFile = "workouts.json"
    private static let sessionFile = "session.json"

    init(directory: URL? = nil) {
        let base = directory ?? AppStore.defaultDirectory()
        self.directory = base
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)

        if FileManager.default.fileExists(atPath: base.appendingPathComponent(Self.plansFile).path) {
            plans = Self.read([WorkoutPlan].self, from: base.appendingPathComponent(Self.plansFile)) ?? []
        } else {
            plans = SeedPlans.all
            persistPlans()
        }
        workouts = Self.read([Workout].self, from: base.appendingPathComponent(Self.workoutsFile)) ?? []
        session = Self.read(ActiveSession.self, from: base.appendingPathComponent(Self.sessionFile))
    }

    static func defaultDirectory() -> URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return support.appendingPathComponent("WorkoutTracker", isDirectory: true)
    }

    // MARK: Derived

    var stats: ProgressStats { Stats.compute(workouts: workouts) }

    var sessionPlan: WorkoutPlan? {
        guard let s = session else { return nil }
        return plans.first { $0.id == s.planId }
    }

    var sortedWorkouts: [Workout] {
        workouts.sorted { a, b in
            if a.date != b.date { return a.date > b.date }
            return a.id > b.id
        }
    }

    // MARK: Plans

    func savePlan(_ plan: WorkoutPlan) {
        if let i = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[i] = plan
        } else {
            plans.append(plan)
        }
        persistPlans()
    }

    func deletePlan(id: Int64) {
        plans.removeAll { $0.id == id }
        persistPlans()
    }

    func toggleFavorite(id: Int64) {
        guard let i = plans.firstIndex(where: { $0.id == id }) else { return }
        plans[i].favorite.toggle()
        persistPlans()
    }

    // MARK: Tracking session

    func startSession(planId: Int64, now: Date = Date()) {
        guard session == nil else { return }
        session = ActiveSession(planId: planId, startedAt: now)
        persistSession()
    }

    func logSet(exercise: String, reps: Int, weight: Double?) {
        guard var s = session, reps > 0 else { return }
        var log = s.logged[exercise] ?? SetLog()
        log.reps.append(reps)
        log.weights.append(weight)
        s.logged[exercise] = log
        session = s
        persistSession()
    }

    func editSet(exercise: String, index: Int, reps: Int, weight: Double?) {
        guard var s = session, reps > 0, var log = s.logged[exercise], log.reps.indices.contains(index) else { return }
        log.reps[index] = reps
        while log.weights.count < log.reps.count { log.weights.append(nil) }
        log.weights[index] = weight
        s.logged[exercise] = log
        session = s
        persistSession()
    }

    func deleteSet(exercise: String, index: Int) {
        guard var s = session, var log = s.logged[exercise], log.reps.indices.contains(index) else { return }
        log.reps.remove(at: index)
        if log.weights.indices.contains(index) { log.weights.remove(at: index) }
        if log.reps.isEmpty {
            s.logged.removeValue(forKey: exercise)
        } else {
            s.logged[exercise] = log
        }
        session = s
        persistSession()
    }

    func endSession(now: Date = Date()) {
        guard let s = session else { return }
        let hasSets = s.logged.values.contains { !$0.reps.isEmpty }
        if hasSets {
            let plan = plans.first { $0.id == s.planId }
            var orderedNames: [String] = []
            for section in plan?.sections ?? [] {
                for ex in section.exercises where s.logged[ex.name] != nil && !orderedNames.contains(ex.name) {
                    orderedNames.append(ex.name)
                }
            }
            for name in s.logged.keys.sorted() where !orderedNames.contains(name) {
                orderedNames.append(name)
            }
            let exercises = orderedNames.compactMap { name -> LoggedExercise? in
                guard let log = s.logged[name], !log.reps.isEmpty else { return nil }
                return LoggedExercise(name: name, sets: log.reps, weights: log.weights)
            }
            let workout = Workout(
                id: freshWorkoutId(now: now),
                type: plan?.name ?? "Workout",
                date: Formatting.isoDay(now),
                exercises: exercises
            )
            workouts.insert(workout, at: 0)
            persistWorkouts()
        }
        session = nil
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(Self.sessionFile))
    }

    // MARK: History

    func addManualWorkout(type: String, date: Date, exercises: [LoggedExercise], now: Date = Date()) {
        let workout = Workout(id: freshWorkoutId(now: now), type: type, date: Formatting.isoDay(date), exercises: exercises)
        workouts.insert(workout, at: 0)
        persistWorkouts()
    }

    func deleteWorkout(id: Int64) {
        workouts.removeAll { $0.id == id }
        persistWorkouts()
    }

    // MARK: Backup

    func exportData(now: Date = Date()) throws -> Data {
        try Backup.encode(workouts: workouts, plans: plans, now: now)
    }

    @discardableResult
    func importBackup(_ data: Data) throws -> (workouts: Int, plans: Int) {
        let file = try Backup.decode(data)
        let w = Backup.merge(existing: workouts, incoming: file.workouts)
        let p = Backup.merge(existing: plans, incoming: file.workoutPlans)
        workouts = w.merged
        plans = p.merged
        if w.added > 0 { persistWorkouts() }
        if p.added > 0 { persistPlans() }
        return (w.added, p.added)
    }

    // MARK: Persistence

    private func freshWorkoutId(now: Date) -> Int64 {
        var id = Int64(now.timeIntervalSince1970 * 1000)
        let used = Set(workouts.map { $0.id })
        while used.contains(id) { id += 1 }
        return id
    }

    private static func read<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func write<T: Encodable>(_ value: T, to name: String) {
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: directory.appendingPathComponent(name), options: .atomic)
        } catch {
            lastError = "Couldn't save data: \(error.localizedDescription)"
        }
    }

    private func persistPlans() { write(plans, to: Self.plansFile) }
    private func persistWorkouts() { write(workouts, to: Self.workoutsFile) }
    private func persistSession() { if let s = session { write(s, to: Self.sessionFile) } }
}
