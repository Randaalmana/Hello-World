import Foundation
import Combine

class ActivityViewModel: ObservableObject {

    @Published var selectedDate = Date()

    @Published var showCalendar = false

    @Published private(set) var learnedDates: Set<Date> = []

    @Published private(set) var frozenDates: Set<Date> = []

    private let maxFreezes = 2

    private let calendar: Calendar

    private let initialLearnedCount: Int

    init(
        calendar: Calendar = .current,
        initialLearnedCount: Int = 0
    ) {
        self.calendar = calendar
        self.initialLearnedCount = initialLearnedCount
    }

    // Learned Statistics
    var learnedCount: Int {
        initialLearnedCount + learnedDates.count
    }

    // Frozen Statistics
    var frozenCount: Int {
        frozenDates.count
    }

    // Check if day can be frozen
    var canFreeze: Bool {

        let date = dayStart(selectedDate)

        return frozenDates.count < maxFreezes &&
            !frozenDates.contains(date) &&
            !learnedDates.contains(date)
    }

    // Calculate weekly dates
    var weekDates: [Date] {

        let weekday = calendar.component(
            .weekday,
            from: selectedDate
        )

        let offset = (
            weekday - calendar.firstWeekday + 7
        ) % 7

        let start = calendar.date(
            byAdding: .day,
            value: -offset,
            to: dayStart(selectedDate)
        )!

        return (0..<7).compactMap {

            calendar.date(
                byAdding: .day,
                value: $0,
                to: start
            )
        }
    }

    // Get start of day
    func dayStart(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    // Check selected date
    func isSelected(_ date: Date) -> Bool {

        calendar.isDate(
            date,
            inSameDayAs: selectedDate
        )
    }

    // Log as learned
    func logLearned() {

        let date = dayStart(selectedDate)

        guard !frozenDates.contains(date) else {
            return
        }

        learnedDates.insert(date)
    }

    // Freeze selected day
    func freezeDay() {

        guard canFreeze else {
            return
        }

        frozenDates.insert(dayStart(selectedDate))
    }
}

