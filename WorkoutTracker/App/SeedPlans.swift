import Foundation

enum SeedPlans {
    private static func ex(_ name: String, _ prescribed: String) -> Exercise {
        Exercise(name: name, prescribed: prescribed)
    }

    private static func plan(
        id: Int64, name: String,
        warmUp: [Exercise], main: [Exercise], cardio: [Exercise], coolDown: [Exercise]
    ) -> WorkoutPlan {
        var sections = SectionType.emptySections()
        sections[0].exercises = warmUp
        sections[1].exercises = main
        sections[2].exercises = cardio
        sections[3].exercises = coolDown
        return WorkoutPlan(id: id, name: name, favorite: false, sections: sections)
    }

    static let all: [WorkoutPlan] = [
        plan(
            id: 1, name: "Day 1 – Upper Body Push + Core",
            warmUp: [
                ex("Arm Circles", "30s each direction"),
                ex("Band Pull-aparts", "15 reps"),
                ex("Scapular Push-ups", "10 reps"),
                ex("Dead Hangs", "3 × 10-15s")
            ],
            main: [
                ex("Push-up Progression", "4 × 8-12 • Rest: 90s"),
                ex("Dumbbell Chest Press", "4 × 10-12 • 3s negative • Rest: 90s"),
                ex("Dumbbell Shoulder Press", "3 × 10-12 • Rest: 60s"),
                ex("Lateral Raises", "3 × 12-15 • Rest: 60s"),
                ex("Tricep Extension (KB/DB)", "3 × 12-15 • Rest: 45s"),
                ex("Pike Push-ups", "3 × 8-12 • Rest: 45s"),
                ex("Plank", "30-45s hold"),
                ex("Dead Bug", "10 each side"),
                ex("Hollow Body Hold", "15-30s"),
                ex("Russian Twists (KB)", "20 total reps")
            ],
            cardio: [ex("Rowing Machine", "5 min moderate pace")],
            coolDown: [
                ex("Chest Doorway Stretch", "30s each side"),
                ex("Overhead Tricep Stretch", "30s each arm"),
                ex("Child's Pose", "45s")
            ]
        ),
        plan(
            id: 2, name: "Day 2 – Lower Body + Posterior Chain",
            warmUp: [
                ex("Walk/Bike", "5 min light"),
                ex("Leg Swings", "10 each direction, each leg"),
                ex("Bodyweight Squats", "15 reps"),
                ex("Glute Bridges", "15 reps")
            ],
            main: [
                ex("Goblet Squat", "4 × 10-12 • Rest: 2 min"),
                ex("Romanian Deadlift (KB/DB)", "4 × 10-12 • Rest: 2 min"),
                ex("Bulgarian Split Squat", "3 × 8-10 each leg • Rest: 90s"),
                ex("Single-leg RDL", "3 × 10 each • Rest: 90s"),
                ex("Glute Bridge March", "3 × 12-15 • Rest: 60s"),
                ex("Calf Raises", "3 × 15-20 • Rest: 45s"),
                ex("Pallof Press (Band)", "3 × 10 each side"),
                ex("OR Suitcase Carries", "3 × 30s each side with KB")
            ],
            cardio: [ex("Treadmill Intervals", "2 min walk / 1 min jog × 3 rounds")],
            coolDown: [
                ex("Standing Quad Stretch", "30s each leg"),
                ex("Pigeon Pose", "30s each side")
            ]
        ),
        plan(
            id: 3, name: "Day 3 – Full Body Pull + Core",
            warmUp: [
                ex("Elliptical/Bike", "5 min light"),
                ex("Scapular Retractions", "15 reps"),
                ex("Band Rows", "15 reps"),
                ex("Dead Hangs", "3 × 15s")
            ],
            main: [
                ex("Pull-up Progression", "5 sets • Rest: 2 min"),
                ex("Dumbbell Bent-Over Row", "4 × 10-12 • Rest: 90s"),
                ex("Single-arm DB Row", "3 × 10-12 each • Rest: 60s"),
                ex("Face Pulls (Band)", "3 × 15-20 • Rest: 60s"),
                ex("Dumbbell Bicep Curl", "3 × 10-12 • Rest: 45s"),
                ex("Hammer Curl", "3 × 12-15 • Rest: 45s"),
                ex("Farmer's Carry", "3 × 40s"),
                ex("Hanging Knee Raises", "3 × 8-12"),
                ex("Plank to Downward Dog", "3 × 10 reps"),
                ex("Side Plank", "2 × 30s each side")
            ],
            cardio: [ex("Bike HIIT", "30s fast / 90s easy × 5 rounds")],
            coolDown: [
                ex("Lat Stretch (Pull-up Bar)", "30s each side"),
                ex("Cobra Stretch", "45s")
            ]
        )
    ]
}
