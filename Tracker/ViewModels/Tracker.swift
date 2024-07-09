import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Schedule
    let isPinned: Bool
    let pinnedFrom: String?
}

struct TrackerForCoreData: Identifiable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: String
    let isPinned: Bool
    let pinnedFrom: String?
}
