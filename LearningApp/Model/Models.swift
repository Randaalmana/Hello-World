import Foundation

/// مدة الهدف
enum GoalDuration: String, Codable, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    /// عدد أيام التعلّم المطلوبة (التجميد ما ينحسب منها)
    var days: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .year: 365
        }
    }

    /// عدد التجميدات المسموحة
    var freezeLimit: Int {
        switch self {
        case .week: 2
        case .month: 8
        case .year: 96
        }
    }
}

/// هدف التعلّم
struct LearningGoal: Codable, Equatable {
    var topic: String
    var duration: GoalDuration
    var startDate: Date
}

/// حالة اليوم
enum DayStatus: String, Codable {
    case learned   // تعلّم (برتقالي)
    case freezed   // جمّد (أزرق)
    case missed    // ضاع بعد 32 ساعة (أحمر) — التسليم الثانوي بس
}

/// سجل يوم واحد
struct DayRecord: Codable {
    let date: Date
    let status: DayStatus
}

/// حالة خسارة الـ streak (التسليم الثانوي بس)
enum StreakLoss: String, Codable {
    case waiting   // خسر الـ streak وينتظر يختار: Continue أو Not now
    case gaveUp    // اختار Not now → You didn't reach
}

/// كل بيانات التطبيق اللي نحفظها
struct AppData: Codable {
    var goal: LearningGoal?
    var records: [DayRecord] = []
    var streakStart: Date = .now   // بداية الـ streak الحالي
    var lastLogDate: Date?         // آخر Learned أو Freeze
    var streakLoss: StreakLoss?    // nil = الـ streak شغّال طبيعي
}

/// خانة في التقويم: فيها يوم، أو فاضية (قبل أول يوم في الشهر)
struct CalendarCell: Identifiable {
    let id: Int
    let date: Date?
}
