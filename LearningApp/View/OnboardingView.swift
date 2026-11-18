import SwiftUI

/// Task 1: Start learning!
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
                    learning.startFirstGoal(topic: form.finalTopic, duration: form.duration)
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
