import SwiftUI

struct TrackingView: View {
    @Environment(AppStore.self) private var store
    @Environment(RestTimer.self) private var timer
    @State private var confirmEnd = false

    private var loggedSetCount: Int {
        store.session?.logged.values.reduce(0) { $0 + $1.reps.count } ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TRACKING")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.accent)
                    Text(store.sessionPlan?.name ?? "Workout")
                        .font(.headline)
                        .foregroundStyle(Theme.text)
                        .lineLimit(2)
                }
                Spacer()
                Button("End") { confirmEnd = true }
                    .buttonStyle(AccentButtonStyle(destructive: true))
            }
            .padding(16)
            .background(Theme.secondary)

            ScrollView {
                VStack(spacing: 16) {
                    if let plan = store.sessionPlan {
                        ForEach(plan.sections) { section in
                            if !section.exercises.isEmpty {
                                SectionBlock(section: section)
                            }
                        }
                    } else {
                        Text("This plan no longer exists. You can still end the workout to save what you logged.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.top, 40)
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            RestTimerBar()
        }
        .confirmationDialog(
            loggedSetCount == 0 ? "Nothing logged, so nothing will be saved." : "Save \(loggedSetCount) logged sets to your history?",
            isPresented: $confirmEnd,
            titleVisibility: .visible
        ) {
            Button(loggedSetCount == 0 ? "End Workout" : "End & Save", role: loggedSetCount == 0 ? .destructive : nil) {
                timer.stop()
                store.endSession()
            }
            Button("Keep Tracking", role: .cancel) {}
        }
    }
}

struct SectionBlock: View {
    let section: PlanSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(section.icon) \(section.title)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.accent)

            ForEach(Array(section.exercises.enumerated()), id: \.offset) { _, ex in
                if section.loggable {
                    ExerciseTrackingCard(exercise: ex)
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ex.name).font(.subheadline).foregroundStyle(Theme.text)
                        if !ex.prescribed.isEmpty {
                            Text(ex.prescribed).font(.caption).foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .card()
                }
            }
        }
    }
}

struct ExerciseTrackingCard: View {
    @Environment(AppStore.self) private var store
    @Environment(RestTimer.self) private var timer
    let exercise: Exercise

    @State private var weightText = ""
    @State private var repsText = ""
    @State private var editingIndex: Int?
    @State private var editReps = ""
    @State private var editWeight = ""

    private var log: SetLog {
        store.session?.logged[exercise.name] ?? SetLog()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name).font(.headline).foregroundStyle(Theme.text)
                if !exercise.prescribed.isEmpty {
                    Text(exercise.prescribed).font(.caption).foregroundStyle(Theme.textSecondary)
                }
            }

            if !log.reps.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(Array(log.reps.enumerated()), id: \.offset) { index, reps in
                        chip(index: index, reps: reps)
                    }
                }
            }

            HStack(spacing: 8) {
                TextField("Weight (kg)", text: $weightText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                TextField("Reps", text: $repsText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                Button("+ Set") { addSet() }
                    .buttonStyle(AccentButtonStyle())
                    .disabled((Int(repsText) ?? 0) <= 0)
            }
        }
        .card()
        .alert("Edit Set \((editingIndex ?? 0) + 1)", isPresented: editingBinding) {
            TextField("Reps", text: $editReps).keyboardType(.numberPad)
            TextField("Weight (kg)", text: $editWeight).keyboardType(.decimalPad)
            Button("Save") { saveEdit() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var editingBinding: Binding<Bool> {
        Binding(get: { editingIndex != nil }, set: { if !$0 { editingIndex = nil } })
    }

    private func chip(index: Int, reps: Int) -> some View {
        let weight: Double? = log.weights.indices.contains(index) ? log.weights[index] : nil
        let label: String = {
            if let w = weight { return "Set \(index + 1): \(reps) reps @ \(Formatting.kg(w))kg" }
            return "Set \(index + 1): \(reps) reps"
        }()
        return HStack(spacing: 6) {
            Button {
                editReps = String(reps)
                editWeight = weight.map { Formatting.kg($0) } ?? ""
                editingIndex = index
            } label: {
                Text(label)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(.plain)
            Button {
                store.deleteSet(exercise: exercise.name, index: index)
            } label: {
                Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.warm)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.secondary)
        .clipShape(Capsule())
    }

    private func parseWeight(_ text: String) -> Double? {
        let cleaned = text.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        guard let v = Double(cleaned), v > 0 else { return nil }
        return v
    }

    private func addSet() {
        guard let reps = Int(repsText), reps > 0 else { return }
        store.logSet(exercise: exercise.name, reps: reps, weight: parseWeight(weightText))
        repsText = ""
        Haptics.impact()
    }

    private func saveEdit() {
        guard let index = editingIndex, let reps = Int(editReps), reps > 0 else { return }
        store.editSet(exercise: exercise.name, index: index, reps: reps, weight: parseWeight(editWeight))
    }
}

struct RestTimerBar: View {
    @Environment(RestTimer.self) private var timer
    @State private var customText = ""

    var body: some View {
        VStack(spacing: 8) {
            if timer.isRunning {
                HStack {
                    Text("REST")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                    Text(RestTimer.clock(timer.remaining))
                        .font(.system(size: 34, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Theme.accent)
                    Spacer()
                    Button("Cancel") { timer.stop() }
                        .buttonStyle(OutlineButtonStyle(tint: Theme.warm))
                }
            } else {
                HStack(spacing: 8) {
                    Text("Rest")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                    ForEach([30, 60, 90], id: \.self) { seconds in
                        Button("\(seconds)s") { timer.start(seconds: seconds) }
                            .buttonStyle(OutlineButtonStyle())
                    }
                    TextField("sec", text: $customText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 64)
                    Button("Go") {
                        if let s = Int(customText), s > 0 {
                            timer.start(seconds: s)
                            customText = ""
                        }
                    }
                    .buttonStyle(AccentButtonStyle())
                    .disabled((Int(customText) ?? 0) <= 0)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Theme.secondary)
        .overlay(alignment: .top) { Rectangle().fill(Theme.border).frame(height: 1) }
    }
}
