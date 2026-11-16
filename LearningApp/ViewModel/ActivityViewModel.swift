import Foundation
import Combine

final class ActivityViewModel: ObservableObject {

    // MARK: - Published Variables

    @Published var selectedDate: Date

    @Published private(set) var days: [Date: LearningDay] = [:]

    @Published private(set) var plan: LearningPlan?

    @Published private(set) var streak = 0

    @Published private(set) var goalResult: Bool? = nil

    @Published private(set) var didFailGoal = false

    @Published private(set) var lastActivityAt: Date?

    // MARK: - Dependencies

    private let calendar: Calendar
    private let now: () -> Date

    private let maximumGap: TimeInterval = 32 * 60 * 60

    // MARK: - Initialization

    init(
        calendar: Calendar = .current,
        now: @escaping () -> Date = { Date() }
    ) {

        var configuredCalendar = calendar

        configuredCalendar.firstWeekday = 1

        self.calendar = configuredCalendar

        self.now = now

        self.selectedDate = configuredCalendar.startOfDay(
            for: now()
        )
    }

    // MARK: - Date Helpers

    private func dayStart(_ date: Date) -> Date {

        calendar.startOfDay(for: date)
    }

    private var today: Date {

        dayStart(now())
    }

    // MARK: - Goal Setup

    func startNewGoal(_ newPlan: LearningPlan) {

        plan = newPlan

        streak = 0

        lastActivityAt = nil

        didFailGoal = false

        goalResult = nil

        selectedDate = today
    }

    // MARK: - Statistics

    var learnedCount: Int {

        guard let plan else { return 0 }

        return days.values.filter {

            $0.status == .learned &&
            $0.date >= dayStart(plan.startDate)

        }.count
    }

    var frozenCount: Int {

        guard let plan else { return 0 }

        return days.values.filter {

            $0.status == .frozen &&
            $0.date >= dayStart(plan.startDate)

        }.count
    }

    var maxFreezes: Int {

        plan?.duration.freezeLimit ?? 0
    }

    var remainingFreezes: Int {

        max(0, maxFreezes - frozenCount)
    }

    // MARK: - Selected Day Status

    var selectedDayStatus: LearningDayStatus? {

        days[dayStart(selectedDate)]?.status
    }

    // MARK: - Button Conditions

    var canLogLearned: Bool {

        guard plan != nil, goalResult == nil else {
            return false
        }

        return selectedDate <= today &&
        selectedDayStatus == nil
    }

    var canFreeze: Bool {

        guard plan != nil, goalResult == nil else {
            return false
        }

        return selectedDate <= today &&
        selectedDayStatus == nil &&
        frozenCount < maxFreezes
    }

    // MARK: - Log Learned

    func logLearned() {

        guard canLogLearned else { return }

        recordDay(status: .learned)
    }

    // MARK: - Freeze Day

    func freezeDay() {

        guard canFreeze else { return }

        recordDay(status: .frozen)
    }

    // MARK: - Record Day

    private func recordDay(status: LearningDayStatus) {

        let currentTime = now()

        let date = dayStart(selectedDate)

        // Check the 32-hour rule

        if let lastActivityAt {

            let difference = currentTime.timeIntervalSince(
                lastActivityAt
            )

            if difference > maximumGap {

                streak = 1

                didFailGoal = true

            } else if !calendar.isDate(
                lastActivityAt,
                inSameDayAs: currentTime
            ) {

                streak += 1
            }

        } else {

            streak = 1
        }

        // Save the day

        let learningDay = LearningDay(
            date: date,
            status: status,
            loggedAt: currentTime
        )

        days[date] = learningDay

        lastActivityAt = currentTime

        checkGoalCompletion()
    }

    // MARK: - Refresh Clock

    func refreshClock() {

        guard plan != nil else { return }

        if let lastActivityAt {

            let difference = now().timeIntervalSince(
                lastActivityAt
            )

            if difference > maximumGap {

                streak = 0

                didFailGoal = true
            }
        }

        checkGoalCompletion()
    }

    // MARK: - Goal Completion

    func checkGoalCompletion() {

        guard let plan else { return }

        guard goalResult == nil else { return }

        if now() >= plan.endDate {

            refreshStreakBeforeCompletion()

            goalResult = !didFailGoal &&
            lastActivityAt != nil
        }
    }

    private func refreshStreakBeforeCompletion() {

        guard let lastActivityAt else { return }

        if now().timeIntervalSince(lastActivityAt) > maximumGap {

            streak = 0

            didFailGoal = true
        }
    }

    // MARK: - Weekly Dates

    var weekDates: [Date] {

        let weekday = calendar.component(
            .weekday,
            from: selectedDate
        )

        let offset = weekday - calendar.firstWeekday

        let start = calendar.date(
            byAdding: .day,
            value: -offset,
            to: dayStart(selectedDate)
        ) ?? selectedDate

        return (0..<7).compactMap {

            calendar.date(
                byAdding: .day,
                value: $0,
                to: start
            )
        }
    }

    // MARK: - Monthly Dates

    /// أسابيع الشهر الحالي (الخانات الفاضية = أيام من شهر ثاني)
    var monthWeeks: [[Date?]] {

        guard let interval = calendar.dateInterval(
            of: .month,
            for: selectedDate
        ) else { return [] }

        let first = interval.start

        let dayCount = calendar.range(
            of: .day,
            in: .month,
            for: first
        )?.count ?? 30

        let offset = (
            calendar.component(.weekday, from: first)
            - calendar.firstWeekday + 7
        ) % 7

        var cells: [Date?] = Array(repeating: nil, count: offset)

        for day in 0..<dayCount {

            cells.append(
                calendar.date(
                    byAdding: .day,
                    value: day,
                    to: first
                )
            )
        }

        while cells.count % 7 != 0 {
            cells.append(nil)
        }

        return stride(from: 0, to: cells.count, by: 7).map {
            Array(cells[$0..<$0 + 7])
        }
    }

    // MARK: - Move Selected Date

    func moveSelectedDate(
        _ component: Calendar.Component,
        by value: Int
    ) {

        if let newDate = calendar.date(
            byAdding: component,
            value: value,
            to: selectedDate
        ) {

            selectedDate = dayStart(newDate)
        }
    }

    // MARK: - Date Comparison

    func isSelected(_ date: Date) -> Bool {

        calendar.isDate(
            date,
            inSameDayAs: selectedDate
        )
    }

    // MARK: - All Learning Days

    func allLearningDays() -> [LearningDay] {

        days.values.sorted {
            $0.date < $1.date
        }
    }
}
