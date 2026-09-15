import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var createdAt: Date
    var trackingStartDate: Date?

    init(id: UUID = UUID(), name: String, createdAt: Date = .now, trackingStartDate: Date? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.trackingStartDate = trackingStartDate
    }
}

@Model
final class DayResult {
    var habitID: UUID
    var date: Date
    var succeeded: Bool

    init(habitID: UUID, date: Date, succeeded: Bool) {
        self.habitID = habitID
        self.date = Calendar.current.startOfDay(for: date)
        self.succeeded = succeeded
    }
}

@Model
final class HelpStep {
    var id: UUID
    var title: String
    var sortOrder: Int

    init(id: UUID = UUID(), title: String, sortOrder: Int) {
        self.id = id
        self.title = title
        self.sortOrder = sortOrder
    }
}

@Model
final class Quote {
    var text: String
    var createdAt: Date

    init(text: String, createdAt: Date = .now) {
        self.text = text
        self.createdAt = createdAt
    }
}
