import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) private var store
    @State private var tab = 0

    private var trackingBinding: Binding<Bool> {
        Binding(get: { store.session != nil }, set: { _ in })
    }

    var body: some View {
        VStack(spacing: 0) {
            HeroHeader()
            TabView(selection: $tab) {
                WorkoutsView()
                    .tabItem { Label("Workouts", systemImage: "dumbbell.fill") }
                    .tag(0)
                TrackerView()
                    .tabItem { Label("Tracker", systemImage: "chart.bar.fill") }
                    .tag(1)
                ProgressionsView()
                    .tabItem { Label("Progressions", systemImage: "chart.line.uptrend.xyaxis") }
                    .tag(2)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .fullScreenCover(isPresented: trackingBinding) {
            TrackingView()
        }
    }
}

struct HeroHeader: View {
    private let stats: [(label: String, value: String)] = [
        ("Current", "84kg"), ("Target", "75-80kg"), ("Height", "6'0\""), ("Daily Cal", "2000")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.accent)
            Text("Workout Transformation")
                .font(.title2.weight(.heavy))
                .foregroundStyle(Theme.text)
            Text("From Machines to Functional Strength")
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
            HStack(spacing: 8) {
                ForEach(stats, id: \.label) { stat in
                    VStack(spacing: 2) {
                        Text(stat.label.uppercased())
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Theme.textMuted)
                        Text(stat.value)
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(Theme.accent)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.secondary)
    }
}
