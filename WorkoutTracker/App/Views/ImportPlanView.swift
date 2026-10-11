import SwiftUI
import UIKit

struct ImportPlanView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Paste the plan JSON you got from Claude. It needs a \"name\" and a \"sections\" object keyed by Warm-up, Main Workout, Cardio Finisher and Cool-down.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)

                TextEditor(text: $text)
                    .font(.system(.footnote, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                    .frame(minHeight: 220)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Theme.warm)
                }

                HStack {
                    Button("Paste") {
                        text = UIPasteboard.general.string ?? text
                    }
                    .buttonStyle(OutlineButtonStyle())
                    Spacer()
                    Button("Import") { importPlan() }
                        .buttonStyle(AccentButtonStyle())
                }
                Spacer()
            }
            .padding(16)
            .background(Theme.background)
            .navigationTitle("Import Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func importPlan() {
        do {
            let plan = try PlanImport.parse(text)
            store.savePlan(plan)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
