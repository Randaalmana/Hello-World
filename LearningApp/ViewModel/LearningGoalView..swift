import SwiftUI

/// Task 4: Change Learning goal  (و Set a goal من Task 3)
struct LearningGoalView: View {
    @Environment(LearningViewModel.self) private var learning
    @Environment(\.dismiss) private var dismiss
    @State private var form: GoalFormViewModel
    @State private var showUpdateAlert = false

    init(goal: LearningGoal?) {
        _form = State(initialValue: GoalFormViewModel(goal: goal))
    }

    var body: some View {
        VStack {
            GoalFormFields(form: form)
            Spacer()
        }
        .padding()
        .navigationTitle("Learning Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark", action: save)
                    .disabled(!form.isValid)
            }
        }
        .alert("Update goal", isPresented: $showUpdateAlert) {
            Button("Dismiss", role: .cancel) {}
            Button("Update", role: .confirm, action: applyGoal)
        } message: {
            Text("If you update now, your streak will start over.")
        }
    }

    private func save() {
        if learning.goalState != .active {
            applyGoal()                  // الهدف انتهى → هدف جديد/نفسه مباشرة
        } else if form.hasChanges(from: learning.goal) {
            showUpdateAlert = true       // الهدف شغّال → تنبيه
        } else {
            dismiss()                    // ما تغيّر شي
        }
    }

    private func applyGoal() {
        learning.startGoal(topic: form.trimmedTopic, duration: form.duration)
        dismiss()
    }
}

/// الحقول المشتركة بين Onboarding و Learning Goal
struct GoalFormFields: View {
    @Bindable var form: GoalFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("I want to learn")
            TextField("Swift", text: $form.topic)
            Divider()

            Text("I want to learn it in a")
                .padding(.top, 12)

            HStack(spacing: 8) {
                ForEach(GoalDuration.allCases, id: \.self) { duration in
                    DurationChip(title: duration.rawValue, isSelected: form.duration == duration) {
                        form.duration = duration
                    }
                }
            }
        }
    }
}

/// زر Week / Month / Year
struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundStyle(isSelected ? .white : .secondary)
                .frame(width: 97, height: 48)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(isSelected ? Color.appOrange : nil).interactive(), in: .capsule)
    }
}
