
import SwiftUI

struct ContentView: View {

    // MARK: - ViewModels

    @StateObject private var learningViewModel =
        LearningViewModel()

    @StateObject private var activityViewModel =
        ActivityViewModel()

    // MARK: - Navigation

    @State private var showActivity = false

    @State private var isEditing = false

    // MARK: - Colors

    private let orange = Color(
        red: 1,
        green: 0.53,
        blue: 0.12
    )

    // MARK: - Body

    var body: some View {

        Group {

            if showActivity && !isEditing {

                ActivityView(
                    viewModel: activityViewModel,
                    onEditGoal: openGoalEditor,
                    onSetGoal: openGoalEditor
                )

            } else {

                goalForm
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Goal Form

    private var goalForm: some View {

        ZStack {

            Color.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // Logo

                Image(systemName: "flame.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(orange)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 45)

                Spacer()
                    .frame(height: 75)

                // Title

                VStack(alignment: .leading, spacing: 5) {

                    HStack(spacing: 5) {

                        Text("Hello")
                            .font(.system(size: 32))

                        Text("Learner")
                            .font(.system(
                                size: 32,
                                weight: .bold
                            ))
                    }

                    Text("This app will help you learn everyday!")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }

                // Topic

                VStack(alignment: .leading, spacing: 15) {

                    Text("I want to learn")
                        .font(.system(size: 16))

                    TextField(
                        "Enter a topic",
                        text: $learningViewModel.topic
                    )
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    Rectangle()
                        .fill(.gray.opacity(0.35))
                        .frame(height: 1)
                }
                .padding(.top, 35)

                // Duration

                VStack(alignment: .leading, spacing: 12) {

                    Text("I want to learn it in a")
                        .font(.system(size: 16))

                    HStack(spacing: 12) {

                        ForEach(
                            LearningDuration.allCases
                        ) { duration in

                            durationButton(duration)
                        }
                    }
                }
                .padding(.top, 28)

                Spacer()

                // Start / Update Button

                Button {

                    saveGoal()

                } label: {

                    Text(
                        isEditing
                        ? "Update Goal"
                        : "Start Learning"
                    )
                    .font(.system(
                        size: 16,
                        weight: .medium
                    ))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .frame(height: 46)
                    .background(orange)
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)

                Text("You can edit your desire later")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 22)
            }
            .padding(.horizontal, 17)

            // Back Button

            if isEditing {

                VStack {

                    HStack {

                        Button {

                            isEditing = false

                        } label: {

                            Image(systemName: "chevron.left")
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Color(white: 0.12),
                                    in: Circle()
                                )
                        }

                        Spacer()
                    }

                    Spacer()
                }
                .padding(.horizontal, 17)
                .padding(.top, 10)
            }
        }
    }

    // MARK: - Duration Button

    private func durationButton(
        _ duration: LearningDuration
    ) -> some View {

        let isSelected =
            learningViewModel.selectedDuration == duration

        return Button {

            learningViewModel.selectedDuration = duration

        } label: {

            Text(duration.title)
                .font(.system(size: 16))
                .foregroundStyle(
                    isSelected
                    ? .white
                    : .white.opacity(0.3)
                )
                .padding(.horizontal, 20)
                .frame(height: 46)
                .background(
                    isSelected
                    ? orange
                    : Color(white: 0.10)
                )
                .clipShape(Capsule())
                .overlay {

                    Capsule()
                        .stroke(
                            .gray.opacity(0.35),
                            lineWidth: 1
                        )
                }
        }
    }

    // MARK: - Open Goal Editor

    private func openGoalEditor() {

        if let currentPlan = activityViewModel.plan {

            learningViewModel.loadPlan(currentPlan)
        }

        isEditing = true
    }

    // MARK: - Save Goal

    private func saveGoal() {

        guard let newPlan = learningViewModel.saveGoal()
        else {
            return
        }

        // Start a new goal and reset the streak

        activityViewModel.startNewGoal(newPlan)

        showActivity = true

        isEditing = false
    }
}

#Preview {

    ContentView()
}

