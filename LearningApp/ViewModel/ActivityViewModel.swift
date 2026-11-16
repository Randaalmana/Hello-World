import Foundation

/// كل اللي تحتاجه شاشة Activity جاهز للعرض
@Observable
final class ActivityViewModel {
    let learning: LearningViewModel
    private(set) var weekOffset = 0

    init(learning: LearningViewModel) {
        self.learning = learning
    }

    // MARK: - العنوان والأسبوع

    var dateTitle: String { learning.now.headerTitle }

    var weekDays: [Date] {
        let date = Calendar.app.date(byAdding: .weekOfYear, value: weekOffset, to: learning.now)!
        return Calendar.app.weekDays(containing: date)
    }

    func style(for day: Date) -> DayStyle { learning.style(for: day) }
    func previousWeek() { weekOffset -= 1 }
    func nextWeek() { weekOffset += 1 }

    // MARK: - البطاقات

    var learnedText: String { learning.learnedCount.daysText }
    var freezedText: String { learning.freezedCount.daysText }

    // MARK: - الأزرار

    var goalState: GoalState { learning.goalState }
    var isLearnedToday: Bool { learning.todayStatus == .learned }
    var canLogLearned: Bool { learning.canLogLearned }
    var canFreeze: Bool { learning.canFreeze }

    var logButtonTitle: String { isLearnedToday ? "Logged as Learned" : "Log as Learned" }
    var freezeButtonTitle: String {
        learning.todayStatus == .freezed ? "Freezed for a day" : "Freeze for a day"
    }
    var freezesText: String { "\(learning.freezesUsed) out of \(learning.freezeLimit) Freezes used" }

    func logAsLearned() { learning.logAsLearned() }
    func freezeDay() { learning.freezeDay() }

    // MARK: - نهاية الهدف

    var isGoalCompleted: Bool { goalState == .completed }
    var finishedIcon: String { isGoalCompleted ? "hands.and.sparkles.fill" : "xmark.seal.fill" }
    var finishedTitle: String { isGoalCompleted ? "Will done!" : "You didn't reach your goal this time." }
    var finishedSubtitle: String { isGoalCompleted ? "Ready for your next goal?" : "Want to set another goal?" }
}
