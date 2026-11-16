import SwiftUI
public import Combine

enum Route: Hashable {
    case goal, calendar
}

/// تختار الشاشة: Onboarding أو Activity
struct ContentView: View {
    @Environment(LearningViewModel.self) private var learning
    @Environment(\.scenePhase) private var scenePhase
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
        .onReceive(timer) { _ in learning.refresh() }   // تفعيل الأزرار 12AM + قاعدة 32 ساعة
        .onChange(of: scenePhase) {
            if scenePhase == .active { learning.refresh() }
        }
    }
}

// MARK: - Task 1: Start learning!

struct OnboardingView: View {
    @Environment(LearningViewModel.self) private var learning
    @State private var form = GoalFormViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.appOrange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("Hello \(Text("Learner").bold())")
                    .font(.system(size: 34))
                Text("This app will help you learn everyday!")
                    .foregroundStyle(.secondary)
            }

            GoalFormFields(form: form)

            Spacer()

            VStack(spacing: 8) {
                Button {
                    learning.startFirstGoal(topic: form.trimmedTopic, duration: form.duration)
                } label: {
                    Text("Start Learning")
                        .font(.headline)
                        .frame(width: 130, height: 36)
                }
                .buttonStyle(.glassProminent)
                .disabled(!form.isValid)

                Text("You can edit your desire later")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

// MARK: - الألوان

extension Color {
    static let appOrange = Color(red: 1.0, green: 0.57, blue: 0.19)
    static let appCyan = Color(red: 0.24, green: 0.81, blue: 0.96)
}

extension DayStyle {
    var textColor: Color {
        switch self {
        case .learned: .appOrange
        case .freezed: .appCyan
        case .today, .normal: .white
        }
    }

    var background: Color {
        switch self {
        case .learned: .appOrange.opacity(0.2)
        case .freezed: .appCyan.opacity(0.2)
        case .today: .appOrange
        case .normal: .clear
        }
    }
}
