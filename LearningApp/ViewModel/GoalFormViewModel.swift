import Foundation

/// نموذج كتابة الهدف (شاشة Hello Learner + شاشة Learning Goal)
@Observable
final class GoalFormViewModel {
    var topic = ""                     // يبدأ فاضي كل مرة
    var duration: GoalDuration
    var isShowingUpdateAlert = false   // تنبيه Update goal
    let placeholder: String            // الهدف الحالي يطلع رمادي
    private let currentTopic: String?

    init(goal: LearningGoal? = nil) {
        currentTopic = goal?.topic
        placeholder = goal?.topic ?? "Swift"
        duration = goal?.duration ?? .week
    }

    /// اللي كتبه المستخدم، ولو ما كتب شي نستخدم الهدف الحالي
    var finalTopic: String {
        let typed = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        return typed.isEmpty ? (currentTopic ?? "") : typed
    }

    var isValid: Bool { !finalTopic.isEmpty }

    func hasChanges(from goal: LearningGoal?) -> Bool {
        finalTopic != goal?.topic || duration != goal?.duration
    }

    // MARK: - الحفظ (زر ✓)

    /// يرجّع true لو لازم الشاشة تتسكّر
    func save(learning: LearningViewModel) -> Bool {
        if learning.goalState != .active {          // الهدف انتهى → Set a goal مباشرة
            apply(to: learning)
            return true
        }
        if hasChanges(from: learning.goal) {        // الهدف شغّال وتغيّر → تنبيه Update goal
            isShowingUpdateAlert = true
            return false
        }
        return true                                 // ما تغيّر شي
    }

    /// يطبّق الهدف الجديد (العدادات تتصفر)
    func apply(to learning: LearningViewModel) {
        isShowingUpdateAlert = false
        learning.startGoal(topic: finalTopic, duration: duration)
    }

    func cancelUpdate() {
        isShowingUpdateAlert = false
    }
}
