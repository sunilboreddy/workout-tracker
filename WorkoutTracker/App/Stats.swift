import Foundation

struct ProgressStats: Equatable {
    var total: Int
    var thisWeek: Int
    var bestPullups: Int?
    var bestPushups: Int?
}

enum Stats {
    static func compute(workouts: [Workout], now: Date = Date(), calendar: Calendar = .current) -> ProgressStats {
        var cal = calendar
        cal.firstWeekday = 1 // Sunday, matching the web app
        let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start ?? cal.startOfDay(for: now)

        let thisWeek = workouts.filter { w in
            guard let d = Formatting.parseISODay(w.date) else { return false }
            return d >= weekStart
        }.count

        var bestPull: Int?
        var bestPush: Int?
        for workout in workouts {
            for ex in workout.exercises {
                let name = ex.name.lowercased()
                let total = ex.totalReps
                if name.contains("pull-up") || name.contains("pullup") {
                    if bestPull == nil || total > bestPull! { bestPull = total }
                }
                if name.contains("push-up") || name.contains("pushup") || name.contains("push up") {
                    if bestPush == nil || total > bestPush! { bestPush = total }
                }
            }
        }

        return ProgressStats(total: workouts.count, thisWeek: thisWeek, bestPullups: bestPull, bestPushups: bestPush)
    }
}
