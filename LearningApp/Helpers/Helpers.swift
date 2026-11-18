import SwiftUI

// MARK: - الألوان

extension Color {
    static let appOrange = Color(red: 1.0, green: 0.57, blue: 0.19)
    static let appCyan = Color(red: 0.24, green: 0.81, blue: 0.96)
    static let appRed = Color(red: 1.0, green: 0.27, blue: 0.23)
}

// MARK: - شكل دائرة اليوم

enum DayStyle {
    case learned   // برتقالي
    case freezed   // أزرق
    case missed    // أحمر
    case today     // دائرة برتقالية + رقم أبيض
    case normal    // بدون دائرة

    var textColor: Color {
        switch self {
        case .learned: .appOrange
        case .freezed: .appCyan
        case .missed: .appRed
        case .today, .normal: .white
        }
    }

    var background: Color {
        switch self {
        case .learned: .appOrange.opacity(0.2)
        case .freezed: .appCyan.opacity(0.2)
        case .missed: .appRed.opacity(0.2)
        case .today: .appOrange
        case .normal: .clear
        }
    }
}

// MARK: - أدوات التاريخ

extension Calendar {
    /// تقويم ميلادي بالإنجليزي، الأسبوع يبدأ الأحد
    static let app: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 1
        return calendar
    }()

    /// الأيام السبعة للأسبوع اللي فيه التاريخ
    func weekDays(containing date: Date) -> [Date] {
        guard let start = dateInterval(of: .weekOfYear, for: date)?.start else { return [] }
        return (0..<7).compactMap { self.date(byAdding: .day, value: $0, to: start) }
    }

    /// خانات الشهر: خانات فاضية قبل أول يوم، بعدها أيام الشهر
    func monthCells(for month: Date) -> [CalendarCell] {
        guard let start = dateInterval(of: .month, for: month)?.start,
              let daysCount = range(of: .day, in: .month, for: month)?.count
        else { return [] }

        // مثلاً الشهر يبدأ يوم الأربعاء → 3 خانات فاضية (أحد، اثنين، ثلاثاء)
        let emptyCount = component(.weekday, from: start) - firstWeekday

        var cells: [CalendarCell] = []
        for i in 0..<emptyCount {
            cells.append(CalendarCell(id: i, date: nil))
        }
        for i in 0..<daysCount {
            let day = date(byAdding: .day, value: i, to: start)
            cells.append(CalendarCell(id: emptyCount + i, date: day))
        }
        return cells
    }
}

extension Date {
    var headerTitle: String { formatted(with: "EEEE, d MMMM") }   // Thursday, 24 October
    var monthTitle: String { formatted(with: "MMMM yyyy") }       // January 2026
    var dayNumber: String { "\(Calendar.app.component(.day, from: self))" }

    var weekdayLetter: String {                                   // S, M, T ...
        let index = Calendar.app.component(.weekday, from: self) - 1
        return Calendar.app.veryShortWeekdaySymbols[index]
    }

    private func formatted(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Int {
    /// 1 → "1 day" ، غير ذلك → "4 days"
    var daysText: String { self == 1 ? "1 day" : "\(self) days" }
}
