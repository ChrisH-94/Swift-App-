import Foundation

// MARK: - GradeLevel
enum GradeLevel: String, CaseIterable, Codable, Identifiable {
    case beginner = "beginner"
    case grade1 = "grade1"
    case grade2 = "grade2"
    case grade3 = "grade3"
    case grade4 = "grade4"
    case grade5 = "grade5"
    case grade6 = "grade6"
    case grade7 = "grade7"
    case grade8 = "grade8"
    case diploma = "diploma"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .grade1:   return "Grade 1"
        case .grade2:   return "Grade 2"
        case .grade3:   return "Grade 3"
        case .grade4:   return "Grade 4"
        case .grade5:   return "Grade 5"
        case .grade6:   return "Grade 6"
        case .grade7:   return "Grade 7"
        case .grade8:   return "Grade 8"
        case .diploma:  return "Diploma"
        }
    }

    var isAdvanced: Bool {
        switch self {
        case .grade5, .grade6, .grade7, .grade8, .diploma:
            return true
        default:
            return false
        }
    }

    var sortOrder: Int {
        switch self {
        case .beginner: return 0
        case .grade1:   return 1
        case .grade2:   return 2
        case .grade3:   return 3
        case .grade4:   return 4
        case .grade5:   return 5
        case .grade6:   return 6
        case .grade7:   return 7
        case .grade8:   return 8
        case .diploma:  return 9
        }
    }
}
