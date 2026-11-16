import Foundation

enum GoalState {
    case active, completed, failed
}

/// المنطق المشترك لكل التطبيق
@Observable
final class LearningViewModel {
    private(set) var now = Date()
    private var data: AppData { didSet { storage.save(data) } }

    private let storage: Storage
    private let calendar = Calendar.app
    private let streakLimit: TimeInterval = 32 * 60 * 60   // 32 ساعة

    init(storage: Storage = Storage()) {
        self.storage = storage
        data = storage.load()
    }

    // MARK: - قراءة

    var goal: LearningGoal? { data.goal }
    var todayStatus: DayStatus? { status(on: now) }
    var firstRecordDate: Date? { data.records.map(\.date).min() }

    var learnedCount: Int { count(.learned, since: data.streakStart) }
    var freezedCount: Int { count(.freezed, since: data.streakStart) }
    var freezesUsed: Int {
        guard let goal = data.goal else { return 0 }
        return count(.freezed, since: calendar.startOfDay(for: goal.startDate))
    }
    var freezeLimit: Int { data.goal?.duration.freezeLimit ?? 0 }

    /// يقدر يسجّل Learned حتى لو جمّد اليوم
    var canLogLearned: Bool { todayStatus != .learned }
    /// التجميد يتعطل إذا سجّل اليوم أو خلصت التجميدات
    var canFreeze: Bool { todayStatus == nil && freezesUsed < freezeLimit }

    /// الهدف ينتهي إذا خلصت مدته، أو كان اليوم آخر يوم وسجّله
    var goalState: GoalState {
        guard let goal = data.goal else { return .active }
        let start = calendar.startOfDay(for: goal.startDate)
        let days = (0..<goal.duration.days).map { calendar.date(byAdding: .day, value: $0, to: start)! }
        let lastDay = days.last!
        let end = calendar.date(byAdding: .day, value: 1, to: lastDay)!

        let lastDayLogged = calendar.isDate(now, inSameDayAs: lastDay) && todayStatus != nil
        guard now >= end || lastDayLogged else { return .active }

        let allDaysLogged = days.allSatisfy { status(on: $0) != nil }
        return allDaysLogged ? .completed : .failed
    }

    func status(on day: Date) -> DayStatus? {
        data.records.last { calendar.isDate($0.date, inSameDayAs: day) }?.status
    }

    func style(for day: Date) -> DayStyle {
        switch status(on: day) {
        case .learned: .learned
        case .freezed: .freezed
        case nil: calendar.isDate(day, inSameDayAs: now) ? .today : .normal
        }
    }

    // MARK: - أفعال

    func logAsLearned() {
        guard canLogLearned else { return }
        now = .now
        // لو اليوم مجمّد نشيل التجميد (ويرجع له) ونسجّله Learned
        data.records.removeAll { calendar.isDate($0.date, inSameDayAs: now) }
        log(.learned)
    }

    func freezeDay() {
        guard canFreeze else { return }
        log(.freezed)
    }

    /// أول هدف من شاشة Start Learning
    func startFirstGoal(topic: String, duration: GoalDuration) {
        if TestData.isEnabled {
            now = .now
            data = TestData.makeData(topic: topic, duration: duration, now: now)
        } else {
            startGoal(topic: topic, duration: duration)
        }
    }

    /// هدف جديد أو تعديل الهدف → الـ streak يبدأ من جديد (من اليوم)
    func startGoal(topic: String, duration: GoalDuration) {
        now = .now
        data = AppData(goal: LearningGoal(topic: topic, duration: duration, startDate: now),
                       records: data.records,                    // نحتفظ بالأيام عشان التقويم
                       streakStart: calendar.startOfDay(for: now),
                       lastLogDate: now)                         // نبدأ عدّ الـ 32 ساعة من الآن
    }

    func refresh() {
        now = .now
        resetStreakIfNeeded()
    }

    // MARK: - داخلي

    private func log(_ status: DayStatus) {
        guard todayStatus == nil else { return }
        now = .now
        data.records.append(DayRecord(date: now, status: status))
        data.lastLogDate = now
    }

    /// أكثر من 32 ساعة بدون Learned أو Freeze → الـ streak يرجع صفر
    private func resetStreakIfNeeded() {
        guard data.goal != nil, goalState == .active else { return }
        let lastActivity = data.lastLogDate ?? data.streakStart
        if now.timeIntervalSince(lastActivity) > streakLimit {
            data.streakStart = now
            data.lastLogDate = nil
        }
    }

    private func count(_ status: DayStatus, since date: Date) -> Int {
        data.records.filter { $0.status == status && $0.date >= date }.count
    }
}

/// نموذج كتابة الهدف (Onboarding و Learning Goal)
@Observable
final class GoalFormViewModel {
    var topic: String
    var duration: GoalDuration

    init(goal: LearningGoal? = nil) {
        topic = goal?.topic ?? ""
        duration = goal?.duration ?? .week
    }

    var trimmedTopic: String { topic.trimmingCharacters(in: .whitespacesAndNewlines) }
    var isValid: Bool { !trimmedTopic.isEmpty }

    func hasChanges(from goal: LearningGoal?) -> Bool {
        trimmedTopic != goal?.topic || duration != goal?.duration
    }
}
