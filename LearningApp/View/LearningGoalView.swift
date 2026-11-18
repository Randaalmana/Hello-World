import SwiftUI

/// Task 4: Change Learning goal (و Set a goal من Task 3)
struct LearningGoalView: View {
    @Environment(LearningViewModel.self) private var learning
    @Environment(\.dismiss) private var dismiss
    @State private var form: GoalFormViewModel

    init(goal: LearningGoal?) {
        _form = State(initialValue: GoalFormViewModel(goal: goal))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            NavHeader(title: "Learning Goal",
                      onBack: { dismiss() },
                      onConfirm: save,
                      isConfirmEnabled: form.isValid)

            GoalFormFields(form: form)

            Spacer()
        }
        .padding()
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if form.isShowingUpdateAlert {
                ConfirmAlert(title: "Update goal",
                             message: "If you update now, your streak will start over.",
                             cancelTitle: "Dismiss",
                             confirmTitle: "Update",
                             confirmColor: .appOrange,
                             onCancel: form.cancelUpdate,
                             onConfirm: confirmUpdate)
            }
        }
        .animation(.spring(duration: 0.3), value: form.isShowingUpdateAlert)
    }

    private func save() {
        if form.save(learning: learning) { dismiss() }
    }

    private func confirmUpdate() {
        form.apply(to: learning)
        dismiss()
    }
}
