import SwiftData
import SwiftUI

@main
struct HabitBreakApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Habit.self, DayResult.self, HelpStep.self, Quote.self])
    }
}
