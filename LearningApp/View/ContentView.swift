import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = LearningViewModel()

    private let orange = Color(
        red: 1,
        green: 0.53,
        blue: 0.12
    )

    var body: some View {

        NavigationStack {

            ZStack {

                Color.black.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {

                    // Logo
                    Image(systemName: "flame.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(orange)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 45)

                    Spacer().frame(height: 75)

                    // Title
                    VStack(alignment: .leading, spacing: 5) {

                        HStack(spacing: 5) {

                            Text("Hello")
                                .font(.system(size: 32))

                            Text("Learner")
                                .font(.system(size: 32, weight: .bold))
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
                            text: $viewModel.topic
                        )
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.4))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                        Rectangle()
                            .fill(.gray.opacity(0.35))
                            .frame(height: 1)
                    }
                    .padding(.top, 35)

                    // Period
                    VStack(alignment: .leading, spacing: 12) {

                        Text("I want to learn it in a")
                            .font(.system(size: 16))

                        HStack(spacing: 12) {

                            PeriodButtonView(
                                title: "Week",
                                isSelected: viewModel.selectedPeriod == "Week"
                            ) {
                                viewModel.selectPeriod("Week")
                            }

                            PeriodButtonView(
                                title: "Month",
                                isSelected: viewModel.selectedPeriod == "Month"
                            ) {
                                viewModel.selectPeriod("Month")
                            }

                            PeriodButtonView(
                                title: "Year",
                                isSelected: viewModel.selectedPeriod == "Year"
                            ) {
                                viewModel.selectPeriod("Year")
                            }
                        }
                    }
                    .padding(.top, 28)

                    Spacer()

                    // Start Button
                    NavigationLink {
                        ActivityView()
                    } label: {

                        Text("Start Learning")
                            .font(.system(size: 16, weight: .medium))
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
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

// Reusable Period Button
private struct PeriodButtonView: View {

    let title: String

    let isSelected: Bool

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

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(
                    isSelected ? .white : .white.opacity(0.3)
                )
                .padding(.horizontal, 20)
                .frame(height: 46)
                .background(
                    isSelected ? orange : Color(white: 0.10)
                )
                .clipShape(Capsule())
                .overlay {

                    Capsule()
                        .stroke(.gray.opacity(0.35), lineWidth: 1)
                }
        }
    }
}

#Preview {
    ContentView()
}

