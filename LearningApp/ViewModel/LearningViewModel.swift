import Foundation
import Combine

class LearningViewModel: ObservableObject {

    @Published var topic = "Swift"

    @Published var selectedPeriod = "Week"

    // Change selected period
    func selectPeriod(_ period: String) {
        selectedPeriod = period
    }

    // Create learning plan
    func createPlan() -> LearningPlan {

        return LearningPlan(
            topic: topic,
            period: selectedPeriod
        )
    }
}
