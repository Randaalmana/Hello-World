//
//  Untitled.swift
//  MyApp
//
//  Created by Randa Alqahtani on 01/06/1448 AH.
//


import SwiftUI

struct ActivityView: View {

    @StateObject private var viewModel: ActivityViewModel

    private let isGlass: Bool

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

    init(
        initialLearnedCount: Int = 0,
        isGlass: Bool = false
    ) {

        _viewModel = StateObject(
            wrappedValue: ActivityViewModel(
                initialLearnedCount: initialLearnedCount
            )
        )

        self.isGlass = isGlass
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {

                VStack(alignment: .leading, spacing: 7) {

                    Text("Activity")
                        .font(.system(size: 32, weight: .bold))

                    Text(viewModel.selectedDate.formatted(
                        .dateTime.weekday(.wide)
                            .day()
                            .month(.wide)
                            .locale(Locale(identifier: "en"))
                    ))
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
                }

                Spacer()

                IconButtonView(icon: "calendar") {
                    viewModel.showCalendar = true
                }

                IconButtonView(icon: "timer") {
                    // Timer action
                }
            }
            .padding(.top, 10)

            // Weekly Calendar
            WeekCalendarView(
                dates: viewModel.weekDates,
                selectedDate: viewModel.selectedDate,
                learnedDates: viewModel.learnedDates,
                frozenDates: viewModel.frozenDates
            ) { date in

                viewModel.selectedDate = date
            }
            .padding(.top, 20)

            // Statistics
            HStack(spacing: 12) {

                StatisticCardView(
                    icon: "flame.fill",
                    color: orange,
                    count: viewModel.learnedCount,
                    title: "Learned"
                )

                StatisticCardView(
                    icon: "snowflake",
                    color: blue,
                    count: viewModel.frozenCount,
                    title: "Freezed"
                )
            }
            .padding(.top, 12)

            Spacer()

            // Log as Learned
            LearningActionButton(isGlass: isGlass) {

                viewModel.logLearned()
            }
            .frame(maxWidth: .infinity)

            Spacer()

            // Freeze Button
            Button {

                viewModel.freezeDay()

            } label: {

                Text("Freeze for a day")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(blue)
                    .clipShape(Capsule())
            }
            .disabled(!viewModel.canFreeze)
            .opacity(viewModel.canFreeze ? 1 : 0.5)

            Text("\(viewModel.frozenCount) out of 2 Freezes used")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 15)
        }
        .padding(.horizontal, 15)
        .foregroundStyle(.white)
        .background(.black)
        .ignoresSafeArea(edges: .bottom)

        // Calendar Sheet
        .sheet(isPresented: $viewModel.showCalendar) {

            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(orange)
            .padding()
            .preferredColorScheme(.dark)
            .presentationDetents([.medium, .large])
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Icon Button

private struct IconButtonView: View {

    let icon: String

    let action: () -> Void

    var body: some View {

        Button {
            action()
        } label: {

            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 45, height: 45)
                .background(
                    Color(white: 0.12),
                    in: Circle()
                )
        }
    }
}

// MARK: - Statistic Card

private struct StatisticCardView: View {

    let icon: String

    let color: Color

    let count: Int

    let title: String

    var body: some View {

        VStack(spacing: 8) {

            Image(systemName: icon)
                .font(.system(size: 19))
                .foregroundStyle(color)

            Text("\(count) days")
                .font(.system(size: 16, weight: .semibold))

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
                .stroke(.gray.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - Weekly Calendar

private struct WeekCalendarView: View {

    let dates: [Date]

    let selectedDate: Date

    let learnedDates: Set<Date>

    let frozenDates: Set<Date>

    let selectDate: (Date) -> Void

    private let calendar = Calendar.current

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

    var body: some View {

        HStack(spacing: 0) {

            ForEach(dates, id: \.self) { date in

                VStack(spacing: 8) {

                    Text(date.formatted(
                        .dateTime.weekday(.narrow)
                    ))
                    .font(.system(size: 13))
                    .foregroundStyle(.white)

                    Button {

                        selectDate(date)

                    } label: {

                        Text(date.formatted(.dateTime.day()))
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background {

                                if calendar.isDate(
                                    date,
                                    inSameDayAs: selectedDate
                                ) {

                                    Circle().fill(orange)

                                } else if frozenDates.contains(
                                    calendar.startOfDay(for: date)
                                ) {

                                    Circle().fill(blue.opacity(0.25))

                                } else if learnedDates.contains(
                                    calendar.startOfDay(for: date)
                                ) {

                                    Circle().fill(orange.opacity(0.5))
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Learning Action Button

private struct LearningActionButton: View {

    let isGlass: Bool

    let action: () -> Void

    private let orange = Color(
        red: 1,
        green: 0.53,
        blue: 0.12
    )

    var body: some View {

        Button {

            action()

        } label: {

            Text("Log as Learned")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 270, height: 270)
                .background {

                    if isGlass {

                        Circle()
                            .fill(.ultraThinMaterial)

                    } else {

                        Circle()
                            .fill(orange)
                    }
                }
                .overlay {

                    Circle()
                        .stroke(
                            .white.opacity(0.35),
                            lineWidth: isGlass ? 1 : 0
                        )
                }
        }
    }
}

#Preview {
    ActivityView()
}

#Preview("Glass Version") {
    ActivityView(
        initialLearnedCount: 5,
        isGlass: true
    )
}
