import SwiftData
import SwiftUI

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query private var records: [DayResult]
    @State private var showingAddHabit = false
    @State private var newHabitName = ""

    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    ContentUnavailableView {
                        Label("No habits", systemImage: "list.bullet")
                    } description: {
                        Text("Create a habit you want to leave behind.")
                    } actions: {
                        Button("Add habit") { showingAddHabit = true }.buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(habits) { habit in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(habit.name).font(.headline)
                                Text(habit.trackingStartDate == nil ? "Not tracking yet" : "Tracking since \(habit.trackingStartDate!, format: .dateTime.month().day().year())")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: deleteHabits)
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                if !habits.isEmpty && habits.count < 3 {
                    Button("Add habit", systemImage: "plus") { showingAddHabit = true }
                }
            }
            .alert("Add habit", isPresented: $showingAddHabit) {
                TextField("Habit name", text: $newHabitName)
                Button("Cancel", role: .cancel) { newHabitName = "" }
                Button("Add") { addHabit() }.disabled(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } message: {
                Text("You can track up to three habits.")
            }
        }
    }

    private func addHabit() {
        guard habits.count < 3 else { return }
        let name = newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        modelContext.insert(Habit(name: name))
        newHabitName = ""
    }

    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            let habit = habits[index]
            records.filter { $0.habitID == habit.id }.forEach(modelContext.delete)
            modelContext.delete(habit)
        }
    }
}
