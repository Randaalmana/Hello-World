import Foundation

/// منطق شاشة التقويم (عرض فقط)
@Observable
final class ActivitiesViewModel {
    let learning: LearningViewModel
    let weekdaySymbols = Calendar.app.shortWeekdaySymbols.map { $0.uppercased() }   // SUN MON ...
    private let calendar = Calendar.app

    init(learning: LearningViewModel) {
        self.learning = learning
    }

    /// السنة كاملة (يناير → ديسمبر)، ولو فيه أيام من سنة قبل نعرضها بعد
    var months: [Date] {
        let thisYear = calendar.component(.year, from: learning.now)
        var firstYear = thisYear
        if let firstDay = learning.firstRecordDate {
            firstYear = min(thisYear, calendar.component(.year, from: firstDay))
        }

        var result: [Date] = []
        for year in firstYear...thisYear {
            for month in 1...12 {
                if let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) {
                    result.append(date)
                }
            }
        }
        return result
    }

    /// الشهر الحالي (التقويم يفتح عليه)
    var currentMonth: Date {
        calendar.dateInterval(of: .month, for: learning.now)!.start
    }

    func title(for month: Date) -> String { month.monthTitle }
    func cells(in month: Date) -> [CalendarCell] { calendar.monthCells(for: month) }
    func style(for day: Date) -> DayStyle { learning.style(for: day) }
}
