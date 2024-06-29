import Foundation

struct Schedule: Codable {
    let days: [WeekDay]
}

enum WeekDay: String, CaseIterable, Codable, CustomStringConvertible {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    case empty = ""
    
    var description: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        case .empty: return ""
        }
    }
}
