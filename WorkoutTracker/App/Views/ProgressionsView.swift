import SwiftUI

struct ProgressionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("How to Progress")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.text)

                infoBox(title: ProgressionData.protocolTitle, text: ProgressionData.protocolText)

                ForEach(ProgressionData.groups) { group in
                    Text(group.title)
                        .font(.headline)
                        .foregroundStyle(Theme.accent)
                        .padding(.top, 4)
                    ForEach(group.stages) { stage in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(stage.title).font(.caption.weight(.bold)).foregroundStyle(Theme.accent)
                            Text(stage.headline).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                            if let detail = stage.detail {
                                Text(detail).font(.footnote).foregroundStyle(Theme.textSecondary)
                            }
                        }
                        .card()
                    }
                }

                infoBox(title: ProgressionData.exampleTitle, text: ProgressionData.exampleText)
            }
            .padding(16)
        }
        .background(Theme.background)
    }

    private func infoBox(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline.weight(.bold)).foregroundStyle(Theme.accent)
            Text(text).font(.footnote).foregroundStyle(Theme.textSecondary)
        }
        .card()
    }
}
