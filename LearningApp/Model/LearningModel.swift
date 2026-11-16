import Foundation

// MARK: - البيانات

enum GoalDuration: String, Codable, CaseIterable {
    case week = "Week", month = "Month", year = "Year"

    var days: Int {
        switch self { case .week: 7; case .month: 30; case .year: 365 }
    }

    var freezeLimit: Int {
        switch self { case .week: 2; case .month: 8; case .year: 96 }
    }
}

struct LearningGoal: Codable, Equatable {
    var topic: String
    var duration: GoalDuration
    var startDate: Date
}

enum DayStatus: String, Codable {
    case learned, freezed
}

struct DayRecord: Codable {
    let date: Date
    let status: DayStatus
}

struct AppData: Codable {
    var goal: LearningGoal?
    var records: [DayRecord] = []
    var streakStart: Date = .now   // بداية الـ streak الحالي
    var lastLogDate: Date?         // آخر Learned أو Freeze
}

/// شكل دائرة اليوم
enum DayStyle {
    case learned, freezed, today, normal
}

// MARK: - الحفظ

struct Storage {
    private let key = "learningData"

    func load() -> AppData {
        guard let saved = UserDefaults.standard.data(forKey: key),
              let data = try? JSONDecoder().decode(AppData.self, from: saved)
        else { return AppData() }
        return data
    }

    func save(_ data: AppData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

// MARK: - وضع التجربة

/// أول هدف يبدأ بأيام قديمة جاهزة، وكل شي بعدها بالأزرار العادية
/// Week  → اليوم آخر يوم + التجميدات خلصت → Log → Will done!
/// Month → اليوم آخر يوم + فيه أيام ضايعة → Log → You didn't reach
/// Year  → نص الهدف → جرّبي Log و Freeze + التقويم
enum TestData {
    static let isEnabled = true   // خليه false للاستخدام الحقيقي

    static func makeData(topic: String, duration: GoalDuration, now: Date = .now) -> AppData {
        let calendar = Calendar.app

        func day(_ offset: Int) -> Date {
            calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: now)!)
        }
        func evening(_ offset: Int) -> Date {   // الساعة 8 مساءً
            calendar.date(byAdding: .hour, value: 20, to: day(offset))!
        }

        let pastDays: Int            // كم يوم مضى من الهدف
        let missedDays: Set<Int>     // أيام ما سجّل فيها شي (الـ streak ينقطع)
        let freezeDays: Set<Int>     // أيام مجمّدة

        switch duration {
        case .week:
            pastDays = 6
            missedDays = []
            freezeDays = [-4, -2]                  // 2 من 2
        case .month:
            pastDays = 29
            missedDays = [-15, -14]
            freezeDays = [-25, -20, -8, -3]        // 4 من 8
        case .year:
            pastDays = 100
            missedDays = [-22, -21]
            freezeDays = [-90, -60, -40, -7]       // 4 من 96
        }

        var records: [DayRecord] = []
        for offset in -pastDays ... -1 where !missedDays.contains(offset) {
            let status: DayStatus = freezeDays.contains(offset) ? .freezed : .learned
            records.append(DayRecord(date: evening(offset), status: status))
        }

        // لو فيه أيام ضايعة، الـ streak يبدأ من بعدها
        let streakStart = missedDays.isEmpty ? day(-pastDays) : day(missedDays.max()! + 1)

        return AppData(goal: LearningGoal(topic: topic, duration: duration, startDate: day(-pastDays)),
                       records: records,
                       streakStart: streakStart,
                       lastLogDate: evening(-1))
    }
}

// MARK: - أدوات التاريخ

extension Calendar {
    /// ميلادي بالإنجليزي، الأسبوع يبدأ الأحد
    static let app: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 1
        return calendar
    }()

    func weekDays(containing date: Date) -> [Date] {
        guard let start = dateInterval(of: .weekOfYear, for: date)?.start else { return [] }
        return (0..<7).compactMap { self.date(byAdding: .day, value: $0, to: start) }
    }

    /// أيام الشهر مع خانات فاضية (nil) قبل أول يوم
    func monthGrid(for month: Date) -> [Date?] {
        guard let start = dateInterval(of: .month, for: month)?.start,
              let count = range(of: .day, in: .month, for: month)?.count
        else { return [] }
        let emptyCells = (component(.weekday, from: start) - firstWeekday + 7) % 7
        let days = (0..<count).compactMap { self.date(byAdding: .day, value: $0, to: start) }
        return Array(repeating: nil, count: emptyCells) + days
    }
}

extension Date {
    var headerTitle: String { formatted(with: "EEEE, d MMMM") }   // Thursday, 24 October
    var monthTitle: String { formatted(with: "MMMM yyyy") }       // January 2026
    var dayNumber: String { "\(Calendar.app.component(.day, from: self))" }
    var weekdayLetter: String {
        Calendar.app.veryShortWeekdaySymbols[Calendar.app.component(.weekday, from: self) - 1]
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
