
import Foundation

// MARK: - Learning Duration

enum LearningDuration: String, CaseIterable, Identifiable, Codable {

    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {

        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    var freezeLimit: Int {

        switch self {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }

    var numberOfDays: Int {

        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}

// MARK: - Learning Day Status

enum LearningDayStatus: String, Codable {

    case learned
    case frozen
}

// MARK: - Learning Day

struct LearningDay: Identifiable, Codable {

    var date: Date
    var status: LearningDayStatus
    var loggedAt: Date

    var id: Date { date }
}

// MARK: - Learning Plan

struct LearningPlan: Codable {

    var topic: String
    var duration: LearningDuration
    var startDate: Date

    var endDate: Date {

        Calendar.current.date(
            byAdding: .day,
            value: duration.numberOfDays,
            to: startDate
        ) ?? startDate
    }
}

