import SwiftUI
import Combine

struct ActivityView: View {

    // MARK: - ViewModel

    @ObservedObject var viewModel: ActivityViewModel

    var onEditGoal: () -> Void

    var onSetGoal: () -> Void

    // MARK: - State

    @State private var isCalendarExpanded = false

    @State private var showActivities = false

    // MARK: - Colors

    private let orange = Color(
        red: 1,
        green: 0.53,
        blue: 0.12
    )

    private let blue = Color(
        red: 0.12,
        green: 0.75,
        blue: 0.90
    )

    // MARK: - Body

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            // Header

            header

            // Weekly Calendar

            weeklyCalendar

            // Statistics

            HStack(spacing: 12) {

                statisticCard(
                    icon: "flame.fill",
                    color: orange,
                    count: viewModel.learnedCount,
                    title: "Learned"
                )

                statisticCard(
                    icon: "snowflake",
                    color: blue,
                    count: viewModel.frozenCount,
                    title: "Freezed"
                )
            }
            .padding(.top, 12)

            // Streak

            Text(
                "\(viewModel.streak) " +
                "\(viewModel.streak == 1 ? "Day" : "Days") Streak"
            )
            .font(.system(size: 13))
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity)
            .padding(.top, 12)

            Spacer(minLength: 15)

            // Goal Result OR Learning Actions

            if let result = viewModel.goalResult {

                GoalResultPanel(
                    isSuccess: result,
                    onSetGoal: onSetGoal
                )

            } else {

                learningActions
            }
        }
        .padding(.horizontal, 15)
        .foregroundStyle(.white)
        .background(.black)
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)

        // MARK: - Activities Sheet

        .sheet(isPresented: $showActivities) {

            ActivitiesView(
                days: viewModel.allLearningDays(),
                startDate: viewModel.plan?.startDate ?? Date()
            )
        }

        // MARK: - Refresh Time

        .onAppear {

            viewModel.refreshClock()
        }

        .onReceive(
            Timer.publish(
                every: 60,
                on: .main,
                in: .common
            ).autoconnect()
        ) { _ in

            viewModel.refreshClock()
        }
    }

    // MARK: - Header

    private var header: some View {

        HStack {

            VStack(alignment: .leading, spacing: 7) {

                Text("Activity")
                    .font(.system(
                        size: 32,
                        weight: .bold
                    ))

                Text(
                    viewModel.selectedDate.formatted(
                        .dateTime
                            .weekday(.wide)
                            .day()
                            .month(.wide)
                            .locale(Locale(identifier: "en"))
                    )
                )
                .font(.system(size: 16))
                .foregroundStyle(.gray)
            }

            Spacer()

            // Previous Activities

            Button {

                showActivities = true

            } label: {

                headerIcon("calendar")
            }
            .accessibilityLabel("Previous Activities")

            // Edit Goal

            Button {

                onEditGoal()

            } label: {

                headerIcon("pencil.tip.crop.circle")
            }
            .accessibilityLabel("Change Learning Goal")
        }
        .padding(.top, 10)
    }

    // MARK: - Header Icon Component

    private func headerIcon(
        _ icon: String
    ) -> some View {

        Image(systemName: icon)
            .font(.system(size: 20))
            .foregroundStyle(.white)
            .frame(width: 45, height: 45)
            .background(
                Color(white: 0.12),
                in: Circle()
            )
    }

    // MARK: - Weekly / Monthly Calendar

    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    private var calendarRows: [[Date?]] {

        isCalendarExpanded
        ? viewModel.monthWeeks
        : [viewModel.weekDates.map { Optional($0) }]
    }

    private var weeklyCalendar: some View {

        VStack(spacing: 8) {

            // Weekday Names

            HStack(spacing: 0) {

                ForEach(
                    Array(weekdaySymbols.enumerated()),
                    id: \.offset
                ) { _, symbol in

                    Text(symbol)
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
            }

            // Rows

            ForEach(
                Array(calendarRows.enumerated()),
                id: \.offset
            ) { _, row in

                HStack(spacing: 0) {

                    ForEach(
                        Array(row.enumerated()),
                        id: \.offset
                    ) { _, date in

                        dayCell(date)
                    }
                }
            }
        }
        .padding(.top, 20)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in

                    let horizontal = value.translation.width
                    let vertical = value.translation.height

                    if abs(vertical) > abs(horizontal) {

                        // سحب لتحت = فتح الشهر / سحب لفوق = رجوع للأسبوع

                        withAnimation(.easeInOut(duration: 0.25)) {

                            if vertical > 30 {
                                isCalendarExpanded = true
                            } else if vertical < -30 {
                                isCalendarExpanded = false
                            }
                        }

                    } else if abs(horizontal) > 40 {

                        // سحب يمين/يسار = الأسبوع أو الشهر السابق/التالي

                        let step = horizontal < 0 ? 1 : -1

                        withAnimation(.easeInOut(duration: 0.25)) {

                            viewModel.moveSelectedDate(
                                isCalendarExpanded
                                ? .month
                                : .weekOfYear,
                                by: step
                            )
                        }
                    }
                }
        )
    }

    // MARK: - Day Cell

    @ViewBuilder
    private func dayCell(_ date: Date?) -> some View {

        if let date {

            Button {

                viewModel.selectedDate = date

            } label: {

                Text(
                    date.formatted(.dateTime.day())
                )
                .font(.system(size: 18))
                .foregroundStyle(dayTextColor(date))
                .frame(width: 44, height: 44)
                .background {

                    Circle()
                        .fill(dayBackground(date))
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

        } else {

            Color.clear
                .frame(width: 44, height: 44)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Day Background

    private func dayBackground(
        _ date: Date
    ) -> Color {

        // اليوم المحدد: دائرة برتقالية صريحة

        if viewModel.isSelected(date) {
            return orange
        }

        switch viewModel.days[
            Calendar.current.startOfDay(for: date)
        ]?.status {

        case .learned:
            return orange.opacity(0.18)

        case .frozen:
            return blue.opacity(0.18)

        case nil:
            return .clear
        }
    }

    // MARK: - Day Text Color

    private func dayTextColor(
        _ date: Date
    ) -> Color {

        // اليوم المحدد: رقم أبيض

        if viewModel.isSelected(date) {
            return .white
        }

        switch viewModel.days[
            Calendar.current.startOfDay(for: date)
        ]?.status {

        case .learned:
            return orange

        case .frozen:
            return blue

        case nil:
            return .white
        }
    }

    // MARK: - Statistic Card Component

    private func statisticCard(
        icon: String,
        color: Color,
        count: Int,
        title: String
    ) -> some View {

        VStack(spacing: 8) {

            Image(systemName: icon)
                .font(.system(size: 19))
                .foregroundStyle(color)

            Text(
                "\(count) \(count == 1 ? "Day" : "Days")"
            )
            .font(.system(
                size: 16,
                weight: .semibold
            ))

            Text(title)
                .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            Color(white: 0.10),
            in: RoundedRectangle(cornerRadius: 35)
        )
        .overlay {

            RoundedRectangle(cornerRadius: 35)
                .stroke(
                    .gray.opacity(0.3),
                    lineWidth: 1
                )
        }
    }

    // MARK: - Learning Actions

    private var learningActions: some View {

        VStack(spacing: 0) {

            // Log as Learned

            Button {

                viewModel.logLearned()

            } label: {

                Text(learnedButtonTitle)
                    .font(.system(
                        size: 16,
                        weight: .bold
                    ))
                    .foregroundStyle(.white.opacity(
                        viewModel.canLogLearned ? 1 : 0.35
                    ))
                    .frame(width: 270, height: 270)
                    .background {

                        if viewModel.canLogLearned {

                            Circle()
                                .fill(orange)

                        } else {

                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay {

                                    Circle()
                                        .stroke(
                                            .white.opacity(0.15),
                                            lineWidth: 1
                                        )
                                }
                        }
                    }
            }
            .disabled(!viewModel.canLogLearned)
            .frame(maxWidth: .infinity)

            Spacer()
                .frame(height: 35)

            // Freeze Button

            Button {

                viewModel.freezeDay()

            } label: {

                Text(freezeButtonTitle)
                    .font(.system(
                        size: 16,
                        weight: .medium
                    ))
                    .foregroundStyle(.white.opacity(
                        viewModel.canFreeze ? 1 : 0.35
                    ))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background {

                        if viewModel.canFreeze {

                            blue

                        } else {

                            Color(white: 0.10)
                        }
                    }
                    .clipShape(Capsule())
            }
            .disabled(!viewModel.canFreeze)

            // Freeze Usage

            Text(
                "\(viewModel.frozenCount) out of " +
                "\(viewModel.maxFreezes) Freezes used"
            )
            .font(.system(size: 14))
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity)
            .padding(.top, 14)
            .padding(.bottom, 15)
        }
    }

    // MARK: - Button Titles

    private var learnedButtonTitle: String {

        switch viewModel.selectedDayStatus {

        case .learned:
            return "Logged as Learned"

        case .frozen:
            return "Frozen for a day"

        case nil:
            return "Log as Learned"
        }
    }

    private var freezeButtonTitle: String {

        switch viewModel.selectedDayStatus {

        case .learned:
            return "Logged as Learned"

        case .frozen:
            return "Frozen for a day"

        case nil:
            return "Freeze for a day"
        }
    }
}

// MARK: - Goal Result Component

private struct GoalResultPanel: View {

    let isSuccess: Bool

    let onSetGoal: () -> Void

    private let orange = Color(
        red: 1,
        green: 0.53,
        blue: 0.12
    )

    var body: some View {

        VStack(spacing: 0) {

            Image(
                systemName: isSuccess
                ? "hands.clap.fill"
                : "xmark.seal.fill"
            )
            .font(.system(size: 45))
            .foregroundStyle(
                isSuccess ? .yellow : orange
            )

            Text(
                isSuccess
                ? "Will done!"
                : "You didn't reach your goal this time."
            )
            .font(.system(size: 17, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(.top, 20)

            Text(
                isSuccess
                ? "Ready for your next goal?"
                : "Want to set another goal?"
            )
            .font(.system(size: 14))
            .foregroundStyle(.gray)
            .padding(.top, 8)

            Button {

                onSetGoal()

            } label: {

                HStack(spacing: 8) {

                    Image(systemName: "pencil.circle")

                    Text("Set a goal")
                }
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .frame(height: 48)
                .background(orange)
                .clipShape(Capsule())
            }
            .padding(.top, 65)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 40)
    }
}

#Preview {

    ContentView()
}
