import SwiftUI

struct DraftExercise: Identifiable {
    let id = UUID()
    var name: String
    var prescribed: String
}

struct DraftSection: Identifiable {
    let id = UUID()
    var title: String
    var icon: String
    var loggable: Bool
    var exercises: [DraftExercise]
}

struct PlanEditorView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let plan: WorkoutPlan?
    @State private var name: String
    @State private var sections: [DraftSection]

    init(plan: WorkoutPlan?) {
        self.plan = plan
        _name = State(initialValue: plan?.name ?? "")
        let source = plan?.sections ?? SectionType.emptySections()
        _sections = State(initialValue: SectionType.all.map { type in
            let match = source.first { $0.title == type.title }
            let exercises = (match?.exercises ?? []).map { DraftExercise(name: $0.name, prescribed: $0.prescribed) }
            return DraftSection(title: type.title, icon: type.icon, loggable: type.loggable, exercises: exercises)
        })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plan name") {
                    TextField("e.g. Day 1 – Upper Body", text: $name)
                }
                .listRowBackground(Theme.card)

                ForEach($sections) { $section in
                    Section("\(section.icon) \(section.title)") {
                        ForEach($section.exercises) { $ex in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    TextField("Exercise", text: $ex.name)
                                    Button {
                                        section.exercises.removeAll { $0.id == ex.id }
                                    } label: {
                                        Image(systemName: "minus.circle.fill").foregroundStyle(Theme.warm)
                                    }
                                    .buttonStyle(.plain)
                                }
                                TextField("Prescribed (e.g. 3×12)", text: $ex.prescribed)
                                    .font(.footnote)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                        Button("+ Add Exercise") {
                            section.exercises.append(DraftExercise(name: "", prescribed: ""))
                        }
                    }
                    .listRowBackground(Theme.card)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle(plan == nil ? "New Plan" : "Edit Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let built = sections.map { s -> PlanSection in
            let exercises = s.exercises.compactMap { ex -> Exercise? in
                let n = ex.name.trimmingCharacters(in: .whitespacesAndNewlines)
                if n.isEmpty { return nil }
                return Exercise(name: n, prescribed: ex.prescribed.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            return PlanSection(title: s.title, icon: s.icon, loggable: s.loggable, exercises: exercises)
        }
        let result = WorkoutPlan(
            id: plan?.id ?? PlanImport.newPlanId(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            favorite: plan?.favorite ?? false,
            sections: built
        )
        store.savePlan(result)
        dismiss()
    }
}
