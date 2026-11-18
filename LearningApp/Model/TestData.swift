import Foundation

/// وضع التجربة: أول هدف يبدأ بأيام قديمة جاهزة
///   أيام Learned = أيام الهدف - 1   (Week 6 ، Month 29 ، Year 364)
///   أيام Freezed = حد التجميد - 1   (Week 1 ، Month 7  ، Year 95)
/// اليوم: Log as Learned → Will done!   أو   Freeze → آخر تجميد
enum TestData {
    ////////////////////////////////////////////////////////////////
    static let isEnabled = false       // التسليم الأساسي: السطرين false
    static let showMissedGoal = false  // true → Streak lost و You didn't reach

    static func makeData(topic: String, duration: GoalDuration, now: Date = .now) -> AppData {
        if showMissedGoal {
            return missedGoal(topic: topic, duration: duration, now: now)
        }

        let learnedBefore = duration.days - 1          // يبقى يوم تعلّم واحد لليوم
        let freezesBefore = duration.freezeLimit - 1   // يبقى تجميد واحد لليوم
        let pastDays = learnedBefore + freezesBefore   // كل الأيام قبل اليوم
        let gap = pastDays / duration.freezeLimit      // كل كم يوم نحط يوم تجميد

        var records: [DayRecord] = []
        var freezesPlaced = 0

        for i in 1...pastDays {
            let offset = i - pastDays - 1               // من أقدم يوم لين أمس
            let isFreezeDay = i % gap == 0 && freezesPlaced < freezesBefore
            if isFreezeDay { freezesPlaced += 1 }

            let status: DayStatus = isFreezeDay ? .freezed : .learned
            records.append(DayRecord(date: evening(offset, from: now), status: status))
        }

        let start = day(-pastDays, from: now)
        return AppData(goal: LearningGoal(topic: topic, duration: duration, startDate: start),
                       records: records,
                       streakStart: start,
                       lastLogDate: evening(-1, from: now))
    }

    /// سيناريو خسارة الـ streak (اختاري Week):
    /// 5 أيام تعلّم ← أمس ضايع (أحمر) ← اليوم: Streak lost + زر ↻
    private static func missedGoal(topic: String, duration: GoalDuration, now: Date) -> AppData {
        var records: [DayRecord] = []
        for offset in -6 ... -2 {
            records.append(DayRecord(date: evening(offset, from: now), status: .learned))
        }
        records.append(DayRecord(date: noon(-1, from: now), status: .missed))   // أمس ضايع

        let start = day(-6, from: now)
        return AppData(goal: LearningGoal(topic: topic, duration: duration, startDate: start),
                       records: records,
                       streakStart: start,
                       lastLogDate: evening(-2, from: now),
                       streakLoss: .waiting)
    }

    // MARK: - مساعدات

    /// بداية يوم يبعد offset يوم عن اليوم (‎-1 = أمس)
    private static func day(_ offset: Int, from now: Date) -> Date {
        let calendar = Calendar.app
        return calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: now)!)
    }

    /// الساعة 8 مساءً في ذلك اليوم
    private static func evening(_ offset: Int, from now: Date) -> Date {
        Calendar.app.date(byAdding: .hour, value: 20, to: day(offset, from: now))!
    }

    /// الساعة 12 الظهر في ذلك اليوم
    private static func noon(_ offset: Int, from now: Date) -> Date {
        Calendar.app.date(byAdding: .hour, value: 12, to: day(offset, from: now))!
    }
}
