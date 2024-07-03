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
        case .monday: return NSLocalizedString("monday", comment: "Localized monday")
        case .tuesday: return NSLocalizedString("tuesday", comment: "Localized tuesday")
        case .wednesday: return NSLocalizedString("wednesday", comment: "Localized wednesday")
        case .thursday: return NSLocalizedString("thursday", comment: "Localized thursday")
        case .friday: return NSLocalizedString("friday", comment: "Localized friday")
        case .saturday: return NSLocalizedString("saturday", comment: "Localized saturday")
        case .sunday: return NSLocalizedString("sunday", comment: "Localized sunday")
        case .empty: return ""
        }
    }
}
