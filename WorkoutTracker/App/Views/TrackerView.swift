import SwiftUI
import UniformTypeIdentifiers

struct BackupDocument: Transferable, Sendable {
    let workouts: [Workout]
    let plans: [WorkoutPlan]

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .json) { doc in
            let data = try Backup.encode(workouts: doc.workouts, plans: doc.plans)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(Backup.fileName())
            try data.write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }
}

struct TrackerView: View {
    @Environment(AppStore.self) private var store
    @State private var showLog = false
    @State private var showImporter = false
    @State private var importMessage: String?
    @State private var pendingDelete: Workout?

    var body: some View {
        let stats = store.stats
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    Text("Workout History")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.text)
                    Spacer()
                    Button("+ Log Workout") { showLog = true }
                        .buttonStyle(AccentButtonStyle())
                }

                HStack(spacing: 8) {
                    ShareLink(
                        item: BackupDocument(workouts: store.workouts, plans: store.plans),
                        preview: SharePreview("Workout backup")
                    ) {
                        Text("⬇ Export Data")
                    }
                    .buttonStyle(OutlineButtonStyle())
                    Button("⬆ Import Data") { showImporter = true }
                        .buttonStyle(OutlineButtonStyle())
                    Spacer()
                }

                HStack(spacing: 8) {
                    statBox("Workouts", "\(stats.total)")
                    statBox("This Week", "\(stats.thisWeek)")
                    statBox("Best Pull-ups", stats.bestPullups.map(String.init) ?? "--")
                    statBox("Best Push-ups", stats.bestPushups.map(String.init) ?? "--")
                }

                if store.workouts.isEmpty {
                    VStack(spacing: 8) {
                        Text("💪").font(.largeTitle)
                        Text("No workouts logged yet.\nStart a workout from the Workouts tab, or log one manually.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                        Text("Lost your data?")
                            .font(.footnote)
                            .foregroundStyle(Theme.textMuted)
                        Button("Restore from backup") { showImporter = true }
                            .buttonStyle(OutlineButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                } else {
                    ForEach(store.sortedWorkouts) { workout in
                        HistoryCard(workout: workout) { pendingDelete = workout }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .sheet(isPresented: $showLog) { LogWorkoutView() }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
            handleImport(result)
        }
        .alert("Import Data", isPresented: messageBinding) {
            Button("OK") { importMessage = nil }
        } message: {
            Text(importMessage ?? "")
        }
        .confirmationDialog(
            "Delete this workout?",
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete Workout", role: .destructive) {
                if let w = pendingDelete { store.deleteWorkout(id: w.id) }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) { pendingDelete = nil }
        }
    }

    private var messageBinding: Binding<Bool> {
        Binding(get: { importMessage != nil }, set: { if !$0 { importMessage = nil } })
    }

    private func statBox(_ label: String, _ value: String) -> some View {
        VStack(spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Theme.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.title3.weight(.heavy))
                .foregroundStyle(Theme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .failure(let error):
            importMessage = "Couldn't open the file: \(error.localizedDescription)"
        case .success(let url):
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let added = try store.importBackup(data)
                importMessage = "Added \(added.workouts) workout(s) and \(added.plans) plan(s). Anything already on this device was kept."
            } catch {
                importMessage = "That file isn't a valid workout backup. Nothing was changed."
            }
        }
    }
}

struct HistoryCard: View {
    let workout: Workout
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.type).font(.headline).foregroundStyle(Theme.text)
                    Text(Formatting.relativeDay(workout.date)).font(.caption).foregroundStyle(Theme.accent)
                }
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash").foregroundStyle(Theme.warm)
                }
                .buttonStyle(.plain)
            }

            ForEach(Array(workout.exercises.enumerated()), id: \.offset) { _, ex in
                VStack(alignment: .leading, spacing: 3) {
                    Text(ex.name).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                    if let weights = ex.weights {
                        ForEach(Array(ex.sets.enumerated()), id: \.offset) { index, reps in
                            Text(setLine(index: index, reps: reps, weight: weights.indices.contains(index) ? weights[index] : nil))
                                .font(.footnote)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Text("\(ex.totalReps) total reps")
                            .font(.caption)
                            .foregroundStyle(Theme.textMuted)
                    } else {
                        Text(legacyLine(ex))
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
        .card()
    }

    private func setLine(index: Int, reps: Int, weight: Double?) -> String {
        if let w = weight { return "Set \(index + 1): \(reps) reps @ \(Formatting.kg(w))kg" }
        return "Set \(index + 1): \(reps) reps"
    }

    private func legacyLine(_ ex: LoggedExercise) -> String {
        let reps = ex.sets.map(String.init).joined(separator: ", ")
        let base = "\(reps) reps (\(ex.totalReps) total)"
        if let w = ex.weight { return "\(Formatting.kg(w))kg · \(base)" }
        return base
    }
}
