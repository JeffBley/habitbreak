import SwiftData
import SwiftUI

struct SummaryView: View {
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query private var records: [DayResult]

    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    ContentUnavailableView("No habits yet", systemImage: "chart.bar", description: Text("Add a habit to begin tracking your progress."))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(habits) { habit in
                                VStack(alignment: .leading, spacing: 14) {
                                    Text(habit.name).font(.headline)
                                    HStack(spacing: 12) {
                                        metric("Current streak", value: TrackingEngine.currentStreak(for: habit, records: records))
                                        metric("Longest streak", value: TrackingEngine.longestStreak(for: habit, records: records))
                                    }
                                }
                                .padding()
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Summary")
        }
    }

    private func metric(_ title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)").font(.system(size: 34, weight: .semibold, design: .rounded))
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
