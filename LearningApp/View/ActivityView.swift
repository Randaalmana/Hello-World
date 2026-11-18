import SwiftUI

/// Task 2 و Task 3
struct ActivityView: View {
    @State private var viewModel: ActivityViewModel

    // ننشئ الـ ViewModel مرة وحدة بس للشاشة
    init(learning: LearningViewModel) {
        _viewModel = State(initialValue: ActivityViewModel(learning: learning))
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            weekStrip
            cards

            if viewModel.goalState == .active {
                logActions
            } else {
                goalFinished
            }
        }
        .padding(.horizontal)
        .toolbar(.hidden, for: .navigationBar)
        .overlay { alerts }
        .animation(.spring(duration: 0.3), value: viewModel.isConfirmingFreeze)
        .animation(.spring(duration: 0.3), value: viewModel.isConfirmingContinue)
    }

    // MARK: - العنوان

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                CircleButton(icon: "chevron.left", action: viewModel.backToStart)

                Text("Activity")
                    .font(.system(size: 34, weight: .bold))

                Spacer()

                CircleLink(icon: "calendar", route: .calendar)
                CircleLink(icon: "pencil.and.outline", route: .goal)
            }

            Text(viewModel.dateTitle)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - الأسبوع الحالي

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekDays, id: \.self) { day in
                VStack(spacing: 8) {
                    Text(day.weekdayLetter)
                        .font(.footnote.weight(.semibold))
                    DayCircle(day: day, style: viewModel.style(for: day), size: 44)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - البطاقات

    private var cards: some View {
        HStack(spacing: 13) {
            if viewModel.isStreakLost {
                LostStreakCard(onRefresh: viewModel.askToContinue)
            } else {
                StatCard(icon: "flame.fill", color: .appOrange,
                         value: viewModel.learnedText, title: "Learned")
            }
            StatCard(icon: "snowflake", color: .appCyan,
                     value: viewModel.freezedText, title: "Freezed")
        }
    }

    // MARK: - Task 2: الأزرار

    private var logActions: some View {
        VStack {
            Spacer()

            // الدائرة الكبيرة: برتقالية لما تكون مفعّلة، غامقة لما تتعطل
            Button(action: viewModel.logAsLearned) {
                Text(viewModel.logButtonTitle)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(viewModel.canLogLearned ? .primary : .secondary)
                    .frame(width: 274, height: 274)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.tint(viewModel.canLogLearned ? .appOrange : Color(white: 0.12)).interactive(),
                         in: .circle)
            .disabled(!viewModel.canLogLearned)

            Spacer()

            VStack(spacing: 16) {
                Button(action: viewModel.askToFreeze) {
                    Text(viewModel.freezeButtonTitle)
                        .foregroundStyle(viewModel.canFreeze ? .white : .secondary)
                        .frame(width: 274, height: 48)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(viewModel.canFreeze ? Color.appCyan : nil).interactive(),
                             in: .capsule)
                .disabled(!viewModel.canFreeze)

                Text(viewModel.freezesText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 24)
        }
    }

    // MARK: - Task 3: نهاية الهدف

    private var goalFinished: some View {
        VStack(spacing: 8) {
            Spacer()

            Image(systemName: viewModel.finishedIcon)
                .font(.system(size: 40))
                .foregroundStyle(viewModel.isGoalCompleted ? Color.yellow : Color.appOrange)
                .padding(.bottom, 8)

            Text(viewModel.finishedTitle)
                .font(.headline)
            Text(viewModel.finishedSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            NavigationLink(value: Route.goal) {
                Label("Set a goal", systemImage: "pencil.and.outline")
                    .frame(height: 36)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.glassProminent)
            .padding(.top, 40)

            Spacer()
            Spacer()
        }
    }

    // MARK: - التنبيهات

    @ViewBuilder
    private var alerts: some View {
        if viewModel.isConfirmingFreeze {
            ConfirmAlert(title: "Freeze today?",
                         message: viewModel.freezeAlertMessage,
                         cancelTitle: "Cancel",
                         confirmTitle: "Freeze",
                         confirmColor: .appCyan,
                         onCancel: viewModel.cancelFreeze,
                         onConfirm: viewModel.confirmFreeze)
        }

        if viewModel.isConfirmingContinue {
            ConfirmAlert(title: "Continue learning?",
                         message: "Your streak starts over, but your learned days are saved. Missed days count against your goal.",
                         cancelTitle: "Not now",
                         confirmTitle: "Continue",
                         confirmColor: .appOrange,
                         onCancel: viewModel.giveUp,
                         onConfirm: viewModel.continueLearning,
                         onBackgroundTap: viewModel.closeContinueAlert)
        }
    }
}
