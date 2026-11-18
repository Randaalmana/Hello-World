import SwiftUI
public import Combine

/// الشاشات اللي ننتقل لها من Activity
enum Route: Hashable {
    case goal       // Learning Goal
    case calendar   // Activities
}

/// تختار الشاشة: Hello Learner أو Activity
struct ContentView: View {
    // @Environment: ياخذ الـ ViewModel اللي أرسلناه من LearningApp
    @Environment(LearningViewModel.self) private var learning
    @Environment(\.scenePhase) private var scenePhase

    // كل دقيقة نحدّث الوقت (عشان الأزرار تتفعّل 12AM وقاعدة الـ 32 ساعة)
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if learning.goal == nil {
                OnboardingView()
            } else {
                NavigationStack {
                    ActivityView(learning: learning)
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .goal:
                                LearningGoalView(goal: learning.goal)
                            case .calendar:
                                ActivitiesView(viewModel: ActivitiesViewModel(learning: learning))
                            }
                        }
                }
            }
        }
        .onAppear { learning.refresh() }
        .onReceive(timer) { _ in learning.refresh() }
        .onChange(of: scenePhase) {
            if scenePhase == .active { learning.refresh() }
        }
    }
}
