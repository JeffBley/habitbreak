import SwiftData
import SwiftUI

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query private var records: [DayResult]
    @State private var displayedMonth = Calendar.current.startOfDay(for: .now)
    @State private var selectedDate: Date?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortStandaloneWeekdaySymbols

    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    ContentUnavailableView("Add a habit first", systemImage: "calendar", description: Text("Your calendar will appear once you create a habit."))
                } else {
                    ScrollView {
                        VStack(spacing: 18) {
                            unstartedHabits
                            monthHeader
                            calendarGrid
                            legend
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Tracker")
            .sheet(isPresented: Binding(
                get: { selectedDate != nil },
                set: { if !$0 { selectedDate = nil } }
            )) {
                if let selectedDate {
                    DayEditorView(date: selectedDate, habits: activeHabits(on: selectedDate), records: records)
                        .presentationDetents([.medium])
                }
            }
        }
    }

    @ViewBuilder private var unstartedHabits: some View {
        let unstarted = habits.filter { $0.trackingStartDate == nil }
        if !unstarted.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(unstarted) { habit in
                    HStack {
                        Text(habit.name).font(.subheadline.weight(.medium))
                        Spacer()
                        Button("Start tracking") { habit.trackingStartDate = Calendar.current.startOfDay(for: .now) }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var monthHeader: some View {
        HStack {
            Button("Previous month", systemImage: "chevron.left") { changeMonth(by: -1) }.labelStyle(.iconOnly)
            Spacer()
            Text(displayedMonth, format: .dateTime.month(.wide).year()).font(.headline)
            Spacer()
            Button("Next month", systemImage: "chevron.right") { changeMonth(by: 1) }
                .labelStyle(.iconOnly)
                .disabled(Calendar.current.isDate(displayedMonth, equalTo: .now, toGranularity: .month))
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol).font(.caption.weight(.medium)).foregroundStyle(.secondary).frame(height: 24)
            }
            ForEach(Array(monthCells.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 52)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let results = activeResults(on: date)
        let canEdit = !results.isEmpty
        let successes = results.filter { $0 }.count
        let failures = results.count - successes

        return Button {
            if canEdit { selectedDate = date }
        } label: {
            VStack(spacing: 3) {
                Text("\(Calendar.current.component(.day, from: date))").font(.caption)
                statusMark(successes: successes, failures: failures)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Calendar.current.isDateInToday(date) ? Color.secondary.opacity(0.12) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .disabled(!canEdit)
    }

    @ViewBuilder private func statusMark(successes: Int, failures: Int) -> some View {
        if successes > 0 && failures == 0 {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        } else if failures > 0 && successes == 0 {
            Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        } else if successes > 0 && failures > 0 {
            HStack(spacing: 3) {
                Label("\(successes)", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                Label("\(failures)", systemImage: "xmark.circle.fill").foregroundStyle(.red)
            }
            .font(.caption2).labelStyle(.titleAndIcon)
        }
    }

    private var legend: some View {
        HStack(spacing: 18) {
            Label("Avoided", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
            Label("Whoops", systemImage: "xmark.circle.fill").foregroundStyle(.red)
        }
        .font(.caption)
    }

    private var monthCells: [Date?] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth),
              let days = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
        return Array(repeating: nil, count: leading) + days.compactMap {
            calendar.date(bySetting: .day, value: $0, of: interval.start)
        }.map(Optional.some)
    }

    private func activeResults(on date: Date) -> [Bool] {
        habits.compactMap { TrackingEngine.result(on: date, for: $0, records: records) }
    }

    private func activeHabits(on date: Date) -> [Habit] {
        habits.filter { TrackingEngine.result(on: date, for: $0, records: records) != nil }
    }

    private func changeMonth(by value: Int) {
        if let month = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = month
        }
    }
}

private struct DayEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let date: Date
    let habits: [Habit]
    let records: [DayResult]

    var body: some View {
        NavigationStack {
            List(habits) { habit in
                VStack(alignment: .leading, spacing: 10) {
                    Text(habit.name).font(.headline)
                    HStack(spacing: 10) {
                        resultButton("I did it!", icon: "checkmark.circle.fill", succeeded: true, habit: habit)
                        resultButton("Whoops", icon: "xmark.circle.fill", succeeded: false, habit: habit)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle(date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Done") { dismiss() } }
        }
    }

    private func resultButton(_ title: String, icon: String, succeeded: Bool, habit: Habit) -> some View {
        let selected = TrackingEngine.result(on: date, for: habit, records: records) == succeeded
        return Button {
            setResult(succeeded, for: habit)
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(selected ? Color.primary : Color.secondary.opacity(0.12))
                .foregroundStyle(selected ? Color(uiColor: .systemBackground) : Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }

    private func setResult(_ succeeded: Bool, for habit: Habit) {
        let calendar = Calendar.current
        if let existing = records.first(where: { $0.habitID == habit.id && calendar.isDate($0.date, inSameDayAs: date) }) {
            existing.succeeded = succeeded
        } else {
            modelContext.insert(DayResult(habitID: habit.id, date: date, succeeded: succeeded))
        }
    }
}
