import SwiftUI

struct DraftRep: Identifiable {
    let id = UUID()
    var text = ""
}

struct DraftManualExercise: Identifiable {
    let id = UUID()
    var name = ""
    var weightText = ""
    var reps: [DraftRep] = [DraftRep()]
}

struct LogWorkoutView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    static let types = ["Upper Body Push", "Lower Body", "Upper Body Pull", "Full Body", "Lower Hinge", "Shoulders + Arms"]

    @State private var type = ""
    @State private var date = Date()
    @State private var exercises: [DraftManualExercise] = [DraftManualExercise()]

    private func built() -> [LoggedExercise] {
        exercises.compactMap { ex -> LoggedExercise? in
            let name = ex.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let sets = ex.reps.compactMap { Int($0.text) }.filter { $0 > 0 }
            if name.isEmpty || sets.isEmpty { return nil }
            let weight = Double(ex.weightText.replacingOccurrences(of: ",", with: "."))
            return LoggedExercise(name: name, sets: sets, weights: nil, weight: weight)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Workout type", selection: $type) {
                        Text("Select…").tag("")
                        ForEach(Self.types, id: \.self) { Text($0).tag($0) }
                    }
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                }
                .listRowBackground(Theme.card)

                ForEach($exercises) { $ex in
                    Section {
                        HStack {
                            TextField("Exercise", text: $ex.name)
                            Button {
                                exercises.removeAll { $0.id == ex.id }
                            } label: {
                                Image(systemName: "minus.circle.fill").foregroundStyle(Theme.warm)
                            }
                            .buttonStyle(.plain)
                        }
                        TextField("Weight (kg, optional)", text: $ex.weightText)
                            .keyboardType(.decimalPad)
                        ForEach($ex.reps) { $rep in
                            TextField("Reps", text: $rep.text)
                                .keyboardType(.numberPad)
                        }
                        Button("+ Add Set") { ex.reps.append(DraftRep()) }
                    }
                    .listRowBackground(Theme.card)
                }

                Section {
                    Button("+ Add Exercise") { exercises.append(DraftManualExercise()) }
                }
                .listRowBackground(Theme.card)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addManualWorkout(type: type, date: date, exercises: built())
                        dismiss()
                    }
                    .disabled(type.isEmpty || built().isEmpty)
                }
            }
        }
    }
}
