import Foundation

/// حالة الهدف
enum GoalState {
    case active      // شغّال
    case completed   // Will done!
    case failed      // You didn't reach your goal this time.
}

/// المنطق المشترك لكل التطبيق
/// @Observable: أي شاشة تقرأ منه تتحدث لحالها لما تتغير البيانات
@Observable
final class LearningViewModel {
    private(set) var now: Date
    private var data: AppData { didSet { storage.save(data) } }   // أي تغيير ينحفظ تلقائي

    // الأشياء اللي نعطيها للـ ViewModel من برا (عشان نقدر نختبره)
    private let storage: any DataStore   // وين نحفظ
    private let clock: () -> Date        // كم الساعة الحين
    private let testMode: Bool           // true = التسليم الثانوي (أيام جاهزة + Streak lost)

    private let calendar = Calendar.app
    private let streakLimit: TimeInterval = 32 * 60 * 60   // 32 ساعة

    init(storage: any DataStore = Storage(),
         clock: @escaping () -> Date = { Date() },
         testMode: Bool = TestData.isEnabled) {
        self.storage = storage
        self.clock = clock
        self.testMode = testMode
        self.now = clock()
        self.data = storage.load()
    }

    // MARK: - قراءة

    var goal: LearningGoal? { data.goal }
    var todayStatus: DayStatus? { status(on: now) }
    var firstRecordDate: Date? { data.records.map(\.date).min() }

    var learnedCount: Int { count(.learned, since: data.streakStart) }
    var freezedCount: Int { count(.freezed, since: data.streakStart) }
    var freezeLimit: Int { data.goal?.duration.freezeLimit ?? 0 }

    var freezesUsed: Int {
        guard let goal = data.goal else { return 0 }
        return count(.freezed, since: calendar.startOfDay(for: goal.startDate))
    }

    /// خسر الـ streak وينتظر يختار Continue أو Not now (التسليم الثانوي بس)
    var isStreakLost: Bool { data.streakLoss == .waiting }

    /// زر واحد في اليوم، والأزرار تتعطل لو الـ streak خسران
    var canLogLearned: Bool { todayStatus == nil && !isStreakLost }
    var canFreeze: Bool { todayStatus == nil && !isStreakLost && freezesUsed < freezeLimit }

    var goalState: GoalState {
        guard let goal = data.goal else { return .active }
        return testMode ? recoveryGoalState(goal) : basicGoalState(goal)
    }

    func status(on day: Date) -> DayStatus? {
        let record = data.records.last { calendar.isDate($0.date, inSameDayAs: day) }
        return record?.status
    }

    /// شكل دائرة اليوم (لون)
    func style(for day: Date) -> DayStyle {
        switch status(on: day) {
        case .learned: .learned
        case .freezed: .freezed
        case .missed: .missed
        case nil: calendar.isDate(day, inSameDayAs: now) ? .today : .normal
        }
    }

    // MARK: - أفعال

    func logAsLearned() {
        guard canLogLearned else { return }
        log(.learned)
    }

    func freezeDay() {
        guard canFreeze else { return }
        log(.freezed)
    }

    /// أول هدف من شاشة Hello Learner
    func startFirstGoal(topic: String, duration: GoalDuration) {
        if testMode {
            now = clock()
            data = TestData.makeData(topic: topic, duration: duration, now: now)
        } else {
            startGoal(topic: topic, duration: duration)
        }
    }

    /// Update goal أو Set a goal → بداية جديدة من اليوم (0 و 0)
    func startGoal(topic: String, duration: GoalDuration) {
        now = clock()
        data = AppData(goal: LearningGoal(topic: topic, duration: duration, startDate: now),
                       records: [],
                       streakStart: now,
                       lastLogDate: now)   // نبدأ عدّ الـ 32 ساعة من الآن
    }

    /// Continue: الـ streak يبدأ من 0، وأيام التعلّم القديمة تبقى محفوظة للهدف
    func continueLearning() {
        now = clock()
        markMissedDays(from: data.streakStart)
        data.streakLoss = nil
        data.streakStart = now
        data.lastLogDate = now
    }

    /// Not now → You didn't reach your goal this time.
    func giveUp() {
        data.streakLoss = .gaveUp
    }

    /// السهم: يرجع لشاشة Hello Learner (يمسح كل شي)
    func backToStart() {
        now = clock()
        data = AppData()
    }

    /// يتنادى عند فتح التطبيق وكل دقيقة
    func refresh() {
        now = clock()
        resetStreakIfNeeded()
    }

    // MARK: - حالة الهدف

    /// التسليم الأساسي (الشغل القديم)
    private func basicGoalState(_ goal: LearningGoal) -> GoalState {
        if learnedCount >= goal.duration.days { return .completed }   // Will done!
        if data.streakStart > goal.startDate { return .failed }        // الـ streak انقطع
        return .active
    }

    /// التسليم الثانوي: أيام التعلّم + الأيام الضايعة = أيام الهدف
    private func recoveryGoalState(_ goal: LearningGoal) -> GoalState {
        if data.streakLoss == .gaveUp { return .failed }

        let start = calendar.startOfDay(for: goal.startDate)
        let learnedDays = count(.learned, since: start)
        let missedDays = count(.missed, since: start)

        if learnedDays + missedDays < goal.duration.days { return .active }
        return missedDays == 0 ? .completed : .failed
    }

    // MARK: - داخلي

    private func log(_ status: DayStatus) {
        now = clock()
        data.records.append(DayRecord(date: now, status: status))
        data.lastLogDate = now
    }

    /// أكثر من 32 ساعة بدون Learned أو Freeze → الـ streak يرجع صفر
    private func resetStreakIfNeeded() {
        guard data.goal != nil, goalState == .active, data.streakLoss == nil else { return }

        let lastActivity = data.lastLogDate ?? data.streakStart
        let timePassed = now.timeIntervalSince(lastActivity)
        guard timePassed > streakLimit else { return }

        if testMode {
            markMissedDays(from: lastActivity)   // الأيام الضايعة تصير حمراء
            data.streakLoss = .waiting           // يطلع مربع Streak lost
        }
        data.streakStart = now
        data.lastLogDate = nil
    }

    /// كل يوم من تاريخ معيّن لين أمس ما فيه تسجيل → يصير ضايع (أحمر)
    private func markMissedDays(from start: Date) {
        var day = calendar.startOfDay(for: start)
        let today = calendar.startOfDay(for: now)

        while day < today {
            if status(on: day) == nil {
                let noon = calendar.date(byAdding: .hour, value: 12, to: day)!
                data.records.append(DayRecord(date: noon, status: .missed))
            }
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
    }

    private func count(_ status: DayStatus, since date: Date) -> Int {
        data.records.filter { $0.status == status && $0.date >= date }.count
    }
}
