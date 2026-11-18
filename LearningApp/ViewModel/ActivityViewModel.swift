import Foundation

/// كل اللي تحتاجه شاشة Activity جاهز للعرض
@Observable
final class ActivityViewModel {
    let learning: LearningViewModel
    var isConfirmingFreeze = false     // تنبيه Freeze today?
    var isConfirmingContinue = false   // تنبيه Continue learning?

    init(learning: LearningViewModel) {
        self.learning = learning
    }

    // MARK: - العنوان والأسبوع

    var dateTitle: String { learning.now.headerTitle }
    var weekDays: [Date] { Calendar.app.weekDays(containing: learning.now) }

    func style(for day: Date) -> DayStyle { learning.style(for: day) }

    /// السهم → شاشة Hello Learner
    func backToStart() { learning.backToStart() }

    // MARK: - البطاقات

    var learnedText: String { learning.learnedCount.daysText }
    var freezedText: String { learning.freezedCount.daysText }
    var isStreakLost: Bool { learning.isStreakLost }

    // MARK: - الأزرار

    var goalState: GoalState { learning.goalState }
    var isLearnedToday: Bool { learning.todayStatus == .learned }
    var canLogLearned: Bool { learning.canLogLearned }
    var canFreeze: Bool { learning.canFreeze }

    var logButtonTitle: String { isLearnedToday ? "Logged as Learned" : "Log as Learned" }

    var freezeButtonTitle: String {
        learning.todayStatus == .freezed ? "Freezed for a day" : "Freeze for a day"
    }

    var freezesText: String {
        "\(learning.freezesUsed) out of \(learning.freezeLimit) Freezes used"
    }

    func logAsLearned() { learning.logAsLearned() }

    // MARK: - تنبيه التجميد

    var freezeAlertMessage: String {
        let left = learning.freezeLimit - learning.freezesUsed
        let word = left == 1 ? "freeze" : "freezes"
        return "Your streak stays safe. This uses 1 of your \(left) remaining \(word)."
    }

    func askToFreeze() { isConfirmingFreeze = true }
    func cancelFreeze() { isConfirmingFreeze = false }

    func confirmFreeze() {
        learning.freezeDay()
        isConfirmingFreeze = false
    }

    // MARK: - تنبيه إكمال التعلّم (Streak lost)

    func askToContinue() { isConfirmingContinue = true }
    func closeContinueAlert() { isConfirmingContinue = false }

    func continueLearning() {
        learning.continueLearning()
        isConfirmingContinue = false
    }

    func giveUp() {
        learning.giveUp()
        isConfirmingContinue = false
    }

    // MARK: - نهاية الهدف

    var isGoalCompleted: Bool { goalState == .completed }
    var finishedIcon: String { isGoalCompleted ? "hands.and.sparkles.fill" : "xmark.seal.fill" }
    var finishedTitle: String { isGoalCompleted ? "Will done!" : "You didn't reach your goal this time." }
    var finishedSubtitle: String { isGoalCompleted ? "Ready for your next goal?" : "Want to set another goal?" }
}
