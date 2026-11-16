
import Foundation
import Combine

final class ActivitiesViewModel: ObservableObject {

    private var calendar: Calendar

    init(calendar: Calendar = .current) {

        var configuredCalendar = calendar

        configuredCalendar.firstWeekday = 1

        self.calendar = configuredCalendar
    }

    // MARK: - Get All Months

    func months(
        from startDate: Date,
        through endDate: Date = Date()
    ) -> [Date] {

        let start = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: startDate
            )
        )!

        let end = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: endDate
            )
        )!

        var result: [Date] = []

        var current = start

        while current <= end {

            result.append(current)

            guard let next = calendar.date(
                byAdding: .month,
                value: 1,
                to: current
            ) else {
                break
            }

            current = next
        }

        return result
    }

    // MARK: - Number of Days

    func numberOfDays(in month: Date) -> Int {

        calendar.range(
            of: .day,
            in: .month,
            for: month
        )?.count ?? 30
    }

    // MARK: - First Weekday Offset

    func firstWeekdayOffset(for month: Date) -> Int {

        let weekday = calendar.component(
            .weekday,
            from: month
        )

        return weekday - 1
    }

    // MARK: - Create Date

    func date(
        for day: Int,
        in month: Date
    ) -> Date? {

        calendar.date(
            byAdding: .day,
            value: day - 1,
            to: month
        )
    }

    // MARK: - Get Day Status

    func status(
        for date: Date,
        days: [LearningDay]
    ) -> LearningDayStatus? {

        let selectedDate = calendar.startOfDay(
            for: date
        )

        return days.first {

            calendar.isDate(
                $0.date,
                inSameDayAs: selectedDate
            )

        }?.status
    }
}

