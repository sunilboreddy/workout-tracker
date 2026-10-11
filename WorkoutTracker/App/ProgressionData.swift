import Foundation

struct ProgressionStage: Identifiable {
    let title: String
    let headline: String
    let detail: String?
    var id: String { title + headline }
}

struct ProgressionGroup: Identifiable {
    let title: String
    let stages: [ProgressionStage]
    var id: String { title }
}

enum ProgressionData {
    static let protocolTitle = "🎯 Universal Progression Protocol"
    static let protocolText = """
    Step 1: Master the rep range (e.g., 3×8-12)
    Week 1: 3×8,7,6 → Week 2: 3×9,8,7 → Week 3: 3×10,9,9

    Step 2: Once you hit top range on ALL sets (3×12,12,12)
    Add 2-4kg for weights OR advance variation for bodyweight

    Step 3: Reset to bottom of range with new weight
    Example: 20kg 3×12 → 24kg 3×8,7,7 (build back up)

    Golden Rule: Add 1-2 total reps per week
    """

    static let groups: [ProgressionGroup] = [
        ProgressionGroup(title: "Goblet Squat Progression", stages: [
            ProgressionStage(title: "Weeks 1-4: Foundation", headline: "16kg KB → 4×10-12 reps", detail: "Focus: Perfect depth, chest up, knees out"),
            ProgressionStage(title: "Weeks 5-8: Build Load", headline: "20-24kg KB → 4×10-12 reps", detail: "Add 2-4kg when you hit 4×12 clean reps"),
            ProgressionStage(title: "Weeks 9-12: Heavy Loading", headline: "28-32kg KB → 4×8-10 reps", detail: "OR Double KB front squat (16kg each hand)"),
            ProgressionStage(title: "Week 13+: Advanced", headline: "32kg+ OR tempo variations", detail: "3s descent, 1s pause, explosive up")
        ]),
        ProgressionGroup(title: "Pull-up Progression", stages: [
            ProgressionStage(title: "Weeks 1-4: Foundation", headline: "Dead hangs: Build to 3×30s", detail: "Scapular pull-ups: 5×5 | Band-assisted (heavy): 5×5"),
            ProgressionStage(title: "Weeks 5-8: Negatives", headline: "Negative pull-ups: 5×3 (5s descent)", detail: "Band-assisted (medium): 5×6-8 reps"),
            ProgressionStage(title: "Weeks 9-12: First Pull-up", headline: "Band-assisted (light): 5×8-10", detail: "Attempt 1-2 unassisted at start of session"),
            ProgressionStage(title: "Week 13+: Building Volume", headline: "Unassisted: 5-8 sets max reps", detail: "Aim for 25-30 total volume per session")
        ]),
        ProgressionGroup(title: "Push-up Progression", stages: [
            ProgressionStage(title: "Weeks 1-4", headline: "Incline push-ups (high)", detail: "4×10-12 reps"),
            ProgressionStage(title: "Weeks 5-8", headline: "Incline push-ups (low)", detail: "4×10-15 reps"),
            ProgressionStage(title: "Weeks 9-12", headline: "Floor push-ups (regular)", detail: "4×8-12 reps"),
            ProgressionStage(title: "Week 13+", headline: "Advanced variations", detail: "Deficit, archer, or diamond push-ups 4×8-12")
        ])
    ]

    static let exampleTitle = "📝 Practical Example"
    static let exampleText = """
    Week 1: DB Press 10kg: 10,9,8,8 = 35 total
    Week 2: DB Press 10kg: 11,10,9,9 = 39 total (+4!)
    Week 3: DB Press 10kg: 12,11,10,10 = 43 total
    Week 4: DB Press 10kg: 12,12,12,11 = 47 total ✓
    Week 5: DB Press 12kg: 8,7,7,6 = 28 total (increased weight!)
    """
}
