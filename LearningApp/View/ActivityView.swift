import SwiftUI

/// Task 2 و Task 3
struct ActivityView: View {
    @State private var viewModel: ActivityViewModel

    init(learning: LearningViewModel) {
        _viewModel = State(initialValue: ActivityViewModel(learning: learning))
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            weekStrip

            HStack(spacing: 13) {
                StatCard(icon: "flame.fill", color: .appOrange, value: viewModel.learnedText, title: "Learned")
                StatCard(icon: "snowflake", color: .appCyan, value: viewModel.freezedText, title: "Freezed")
            }

            if viewModel.goalState == .active {
                logActions
            } else {
                goalFinished
            }
        }
        .padding(.horizontal)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - العنوان

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Activity")
                    .font(.system(size: 34, weight: .bold))
                Spacer()
                CircleLink(icon: "calendar", route: .calendar)
                CircleLink(icon: "pencil.and.outline", route: .goal)
            }

            HStack {
                Text(viewModel.dateTitle)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Previous week", systemImage: "chevron.left", action: viewModel.previousWeek)
                Button("Next week", systemImage: "chevron.right", action: viewModel.nextWeek)
            }
            .labelStyle(.iconOnly)
            .tint(.blue)
        }
    }

    // MARK: - الأسبوع

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

    // MARK: - Task 2: الأزرار

    private var logActions: some View {
        VStack {
            Spacer()

            Button(action: viewModel.logAsLearned) {
                Text(viewModel.logButtonTitle)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(viewModel.isLearnedToday ? .secondary : .primary)
                    .frame(width: 274, height: 274)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.tint(viewModel.isLearnedToday ? Color(white: 0.12) : .appOrange).interactive(),
                         in: .circle)
            .disabled(!viewModel.canLogLearned)

            Spacer()

            VStack(spacing: 16) {
                Button(action: viewModel.freezeDay) {
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
}

// MARK: - قطع صغيرة

struct CircleLink: View {
    let icon: String
    let route: Route

    var body: some View {
        NavigationLink(value: route) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

struct StatCard: View {
    let icon: String
    let color: Color
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .glassEffect(in: .rect(cornerRadius: 34))
    }
}

/// دائرة اليوم — تُستخدم هنا وفي التقويم (بدون تفاعل)
struct DayCircle: View {
    let day: Date
    let style: DayStyle
    let size: CGFloat

    var body: some View {
        Text(day.dayNumber)
            .font(.system(size: size * 0.45, weight: style == .today ? .bold : .medium))
            .foregroundStyle(style.textColor)
            .frame(width: size, height: size)
            .background(Circle().fill(style.background))
    }
}
