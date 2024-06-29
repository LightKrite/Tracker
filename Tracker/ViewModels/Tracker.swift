import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Schedule
}

struct TrackerForCoreData: Identifiable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: String
}
