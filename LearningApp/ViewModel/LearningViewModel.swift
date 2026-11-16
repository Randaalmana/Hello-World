
import Foundation
import Combine

final class LearningViewModel: ObservableObject {

    // MARK: - Variables

    @Published var topic = "Swift"

    @Published var selectedDuration: LearningDuration = .week

    @Published private(set) var plan: LearningPlan?

    // MARK: - Load Existing Goal

    func loadPlan(_ plan: LearningPlan) {

        self.plan = plan

        topic = plan.topic

        selectedDuration = plan.duration
    }

    // MARK: - Save Goal

    func saveGoal(now: Date = Date()) -> LearningPlan? {

        let cleanTopic = topic.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTopic.isEmpty else {
            return nil
        }

        let newPlan = LearningPlan(
            topic: cleanTopic,
            duration: selectedDuration,
            startDate: now
        )

        plan = newPlan

        return newPlan
    }
}

