import SwiftUI

/// Task 5: التقويم — السنة كاملة بالسكرول، عرض فقط
struct ActivitiesView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ActivitiesViewModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            NavHeader(title: "Activities", onBack: { dismiss() })
                .padding(.horizontal)
                .padding(.bottom, 8)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.months, id: \.self) { month in
                            monthView(month)
                                .id(month)
                            Divider()
                        }
                    }
                    .padding()
                }
                .onAppear {
                    proxy.scrollTo(viewModel.currentMonth, anchor: .top)   // يفتح على الشهر الحالي
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
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

                ForEach(viewModel.cells(in: month)) { cell in
                    if let day = cell.date {
                        DayCircle(day: day, style: viewModel.style(for: day), size: 40)
                    } else {
                        Color.clear.frame(height: 40)   // خانة فاضية قبل أول يوم
                    }
                }
            }
        }
    }
}
