
import SwiftUI

struct ActivitiesView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    let days: [LearningDay]

    let startDate: Date

    // MARK: - ViewModel

    @StateObject private var viewModel =
        ActivitiesViewModel()

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

    // MARK: - Columns

    private let columns = Array(
        repeating: GridItem(
            .flexible(),
            spacing: 8
        ),
        count: 7
    )

    // MARK: - History Start Date

    private var historyStartDate: Date {

        days.map(\.date).min() ?? startDate
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                LazyVStack(
                    alignment: .leading,
                    spacing: 20
                ) {

                    ForEach(
                        viewModel.months(
                            from: historyStartDate
                        ),
                        id: \.self
                    ) { month in

                        monthSection(month)
                    }
                }
                .padding(16)
            }
            .background(.black)

            // Navigation

            .navigationTitle("Activities")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button {

                        dismiss()

                    } label: {

                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Color(white: 0.12),
                                in: Circle()
                            )
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Month Section

    private func monthSection(
        _ month: Date
    ) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            // Month Title

            Text(
                month.formatted(
                    .dateTime
                        .month(.wide)
                        .year()
                        .locale(Locale(identifier: "en"))
                )
            )
            .font(.system(
                size: 16,
                weight: .semibold
            ))
            .foregroundStyle(.white)

            // Calendar Grid

            LazyVGrid(
                columns: columns,
                spacing: 12
            ) {

                // Weekday Names

                ForEach(
                    ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"],
                    id: \.self
                ) { day in

                    Text(day)
                        .font(.system(
                            size: 9,
                            weight: .semibold
                        ))
                        .foregroundStyle(.gray)
                }

                // Empty Spaces

                ForEach(
                    0..<viewModel.firstWeekdayOffset(
                        for: month
                    ),
                    id: \.self
                ) { _ in

                    Color.clear
                        .frame(height: 34)
                }

                // Month Days

                ForEach(
                    1...viewModel.numberOfDays(
                        in: month
                    ),
                    id: \.self
                ) { day in

                    if let date = viewModel.date(
                        for: day,
                        in: month
                    ) {

                        calendarDay(date)
                    }
                }
            }

            // Divider

            Rectangle()
                .fill(.gray.opacity(0.25))
                .frame(height: 1)
        }
    }

    // MARK: - Calendar Day

    private func calendarDay(
        _ date: Date
    ) -> some View {

        let status = viewModel.status(
            for: date,
            days: days
        )

        return Text(
            date.formatted(.dateTime.day())
        )
        .font(.system(size: 14))
        .foregroundStyle(dayColor(status))
        .frame(maxWidth: .infinity)
        .frame(height: 34)
        .background {

            if status == .learned {

                Circle()
                    .fill(orange.opacity(0.18))

            } else if status == .frozen {

                Circle()
                    .fill(blue.opacity(0.18))
            }
        }
    }

    // MARK: - Day Color

    private func dayColor(
        _ status: LearningDayStatus?
    ) -> Color {

        switch status {

        case .learned:
            return orange

        case .frozen:
            return blue

        case nil:
            return .white
        }
    }
}

#Preview {

    ActivitiesView(
        days: [],
        startDate: Date()
    )
}

