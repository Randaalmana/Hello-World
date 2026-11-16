import SwiftUI

/// Task 5: التقويم — عرض فقط
struct ActivitiesView: View {
    let viewModel: ActivitiesViewModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.months, id: \.self) { month in
                    monthView(month)
                    Divider()
                }
            }
            .padding()
        }
        .defaultScrollAnchor(.bottom)   // يفتح على الشهر الحالي
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func monthView(_ month: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.title(for: month))
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ForEach(Array(viewModel.days(in: month).enumerated()), id: \.offset) { _, day in
                    if let day {
                        DayCircle(day: day, style: viewModel.style(for: day), size: 40)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
    }
}
