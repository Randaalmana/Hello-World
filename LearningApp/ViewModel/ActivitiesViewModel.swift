import Foundation

/// منطق شاشة التقويم (عرض فقط)
@Observable
final class ActivitiesViewModel {
    let learning: LearningViewModel
    let weekdaySymbols = Calendar.app.shortWeekdaySymbols.map { $0.uppercased() }   // SUN MON ...

    init(learning: LearningViewModel) {
        self.learning = learning
    }

    /// كل الشهور من أول يوم مسجّل إلى الشهر الحالي
    var months: [Date] {
        let calendar = Calendar.app
        let firstDay = learning.firstRecordDate ?? learning.now
        guard var month = calendar.dateInterval(of: .month, for: firstDay)?.start else { return [] }

        var result: [Date] = []
        while month <= learning.now {
            result.append(month)
            month = calendar.date(byAdding: .month, value: 1, to: month)!
        }
        return result
    }

    func title(for month: Date) -> String { month.monthTitle }
    func days(in month: Date) -> [Date?] { Calendar.app.monthGrid(for: month) }
    func style(for day: Date) -> DayStyle { learning.style(for: day) }
}
