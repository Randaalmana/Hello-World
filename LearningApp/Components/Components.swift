import SwiftUI

// MARK: - زر دائري (سهم رجوع، ✓)

struct CircleButton: View {
    let icon: String
    var tint: Color? = nil   // nil = زجاجي عادي
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(tint).interactive(), in: .circle)
    }
}

// MARK: - زر دائري ينقل لشاشة (التقويم، تعديل الهدف)

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

// MARK: - شريط العنوان (سهم رجوع + عنوان + ✓ اختياري)

struct NavHeader: View {
    let title: String
    let onBack: () -> Void
    var onConfirm: (() -> Void)? = nil   // nil = بدون زر ✓
    var isConfirmEnabled = true

    var body: some View {
        ZStack {
            Text(title)
                .font(.headline)

            HStack {
                CircleButton(icon: "chevron.left", action: onBack)
                Spacer()
                if let onConfirm {
                    CircleButton(icon: "checkmark", tint: .appOrange, action: onConfirm)
                        .disabled(!isConfirmEnabled)
                }
            }
        }
    }
}

// MARK: - مربع Learned / Freezed

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

// MARK: - مربع Streak lost (فيه زر ↻)

struct LostStreakCard: View {
    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(Color.appRed)
            Text("Streak lost")
                .font(.headline)
            Text("Tap ↻ to continue")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .contentShape(.rect)
        .onTapGesture(perform: onRefresh)
        .glassEffect(in: .rect(cornerRadius: 34))
        .overlay(alignment: .topTrailing) {
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.tint(.appOrange).interactive(), in: .circle)
            .padding(10)
        }
    }
}

// MARK: - دائرة اليوم (صف الأيام + التقويم)

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

// MARK: - تنبيه بتصميم التطبيق (Update goal / Freeze / Continue)

struct ConfirmAlert: View {
    let title: String
    let message: String
    let cancelTitle: String
    let confirmTitle: String
    let confirmColor: Color
    let onCancel: () -> Void
    let onConfirm: () -> Void
    var onBackgroundTap: (() -> Void)? = nil   // الضغط برا التنبيه (nil = نفس زر الإلغاء)

    var body: some View {
        ZStack {
            // تغميق الخلفية
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    if let onBackgroundTap {
                        onBackgroundTap()
                    } else {
                        onCancel()
                    }
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    alertButton(cancelTitle, tint: nil, action: onCancel)
                    alertButton(confirmTitle, tint: confirmColor, action: onConfirm)
                }
                .padding(.top, 12)
            }
            .padding(20)
            .frame(width: 300)
            .glassEffect(in: .rect(cornerRadius: 34))
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
    }

    private func alertButton(_ title: String, tint: Color?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(tint).interactive(), in: .capsule)
    }
}

// MARK: - حقول الهدف (Hello Learner + Learning Goal)

struct GoalFormFields: View {
    // @Bindable: يربط خانة الكتابة والأزرار بالـ ViewModel
    @Bindable var form: GoalFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("I want to learn")
            TextField(form.placeholder, text: $form.topic)   // فاضي، والهدف الحالي يطلع رمادي
            Divider()

            Text("I want to learn it in a")
                .padding(.top, 12)

            HStack(spacing: 8) {
                ForEach(GoalDuration.allCases, id: \.self) { duration in
                    DurationChip(title: duration.rawValue, isSelected: form.duration == duration) {
                        form.duration = duration
                    }
                }
            }
        }
    }
}

// MARK: - زر Week / Month / Year

struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundStyle(isSelected ? .white : .secondary)
                .frame(width: 97, height: 48)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(isSelected ? Color.appOrange : nil).interactive(), in: .capsule)
    }
}
