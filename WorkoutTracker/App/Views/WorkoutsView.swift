import SwiftUI

struct WorkoutsView: View {
    @Environment(AppStore.self) private var store
    @State private var favoritesOnly = false
    @State private var showNew = false
    @State private var showImport = false
    @State private var editing: WorkoutPlan?

    private var visiblePlans: [WorkoutPlan] {
        favoritesOnly ? store.plans.filter { $0.favorite } : store.plans
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Button {
                        favoritesOnly.toggle()
                    } label: {
                        Text("★ Favorites")
                    }
                    .buttonStyle(OutlineButtonStyle(tint: favoritesOnly ? Theme.warm : Theme.textSecondary))
                    Spacer()
                    Button("+ New Plan") { showNew = true }
                        .buttonStyle(AccentButtonStyle())
                    Button("Import") { showImport = true }
                        .buttonStyle(OutlineButtonStyle())
                }

                if visiblePlans.isEmpty {
                    Text(favoritesOnly ? "No favorite plans yet. Tap the star on a plan to add one." : "No plans yet. Create one or import one.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                }

                ForEach(visiblePlans) { plan in
                    PlanCard(plan: plan, onEdit: { editing = plan })
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .sheet(isPresented: $showNew) { PlanEditorView(plan: nil) }
        .sheet(item: $editing) { plan in PlanEditorView(plan: plan) }
        .sheet(isPresented: $showImport) { ImportPlanView() }
    }
}

struct PlanCard: View {
    @Environment(AppStore.self) private var store
    let plan: WorkoutPlan
    let onEdit: () -> Void
    @State private var expanded = false
    @State private var confirmDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Button {
                    withAnimation { expanded.toggle() }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.name)
                            .font(.headline)
                            .foregroundStyle(Theme.text)
                            .multilineTextAlignment(.leading)
                        Text(summary)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                Button {
                    store.toggleFavorite(id: plan.id)
                    Haptics.selection()
                } label: {
                    Image(systemName: plan.favorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(plan.favorite ? Theme.warm : Theme.textMuted)
                }
                .buttonStyle(.plain)
            }

            if expanded {
                ForEach(plan.sections) { section in
                    if !section.exercises.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(section.icon) \(section.title)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Theme.accent)
                            ForEach(Array(section.exercises.enumerated()), id: \.offset) { _, ex in
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(ex.name)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.text)
                                    if !ex.prescribed.isEmpty {
                                        Text(ex.prescribed)
                                            .font(.caption)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                Button("▶ Start") { store.startSession(planId: plan.id) }
                    .buttonStyle(AccentButtonStyle())
                Button("Edit", action: onEdit)
                    .buttonStyle(OutlineButtonStyle())
                Spacer()
                Button("Delete") { confirmDelete = true }
                    .buttonStyle(OutlineButtonStyle(tint: Theme.warm))
            }
        }
        .card()
        .confirmationDialog("Delete \"\(plan.name)\"?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete Plan", role: .destructive) { store.deletePlan(id: plan.id) }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var summary: String {
        let count = plan.sections.reduce(0) { $0 + $1.exercises.count }
        return "\(count) exercises"
    }
}
