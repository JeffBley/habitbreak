import Foundation

enum TrackingEngine {
    static func result(on date: Date, for habit: Habit, records: [DayResult]) -> Bool? {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: .now)

        guard let start = habit.trackingStartDate,
              day >= calendar.startOfDay(for: start),
              day <= today else { return nil }

        return records.first {
            $0.habitID == habit.id && calendar.isDate($0.date, inSameDayAs: day)
        }?.succeeded ?? true
    }

    static func currentStreak(for habit: Habit, records: [DayResult]) -> Int {
        guard let start = habit.trackingStartDate else { return 0 }
        let calendar = Calendar.current
        var date = calendar.startOfDay(for: .now)
        let firstDay = calendar.startOfDay(for: start)
        var count = 0

        while date >= firstDay, result(on: date, for: habit, records: records) == true {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return count
    }

    static func longestStreak(for habit: Habit, records: [DayResult]) -> Int {
        guard let start = habit.trackingStartDate else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        var date = calendar.startOfDay(for: start)
        var longest = 0
        var running = 0

        while date <= today {
            if result(on: date, for: habit, records: records) == true {
                running += 1
                longest = max(longest, running)
            } else {
                running = 0
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }
        return longest
    }
}
