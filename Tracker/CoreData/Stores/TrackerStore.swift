import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidID
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedule
    case initError
}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject {
    
    private let uiColorMarshalling = UIColorMarshalling()
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?

    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let trackers = try? objects.map({ try self.tracker(from: $0) })
        else { return [] }
        return trackers
    }
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate init error")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        fetch()
    }
    
    private func fetch() {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.objectID, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try? controller.performFetch()
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else {
            throw TrackerStoreError.decodingErrorInvalidID
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let color = trackerCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let scheduleString = trackerCoreData.schedule else {
            throw TrackerStoreError.decodingErrorInvalidSchedule
        }
        
        let schedule = Schedule(days: weekDays(from: scheduleString))
        return Tracker(
            id: id,
            name: name,
            color: uiColorMarshalling.color(from:color),
            emoji: emoji,
            schedule: schedule
        )
    }
    
    private func weekDays(from scheduleString: String) -> [WeekDay] {
        var weekDays: [WeekDay] = []
        scheduleString.components(separatedBy: ",").forEach{ day in
            switch day {
            case WeekDay.monday.rawValue: return weekDays.append(WeekDay.monday)
            case WeekDay.tuesday.rawValue: weekDays.append(WeekDay.tuesday)
            case WeekDay.wednesday.rawValue: weekDays.append(WeekDay.wednesday)
            case WeekDay.thursday.rawValue: weekDays.append(WeekDay.thursday)
            case WeekDay.friday.rawValue: weekDays.append(WeekDay.friday)
            case WeekDay.saturday.rawValue: weekDays.append(WeekDay.saturday)
            case WeekDay.sunday.rawValue: weekDays.append(WeekDay.sunday)
            default: weekDays.append(WeekDay.empty)
            }
        }
        return weekDays
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        try context.save()
    }
    
    private func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = trackerForCoreData(from: tracker).id
        trackerCoreData.name = trackerForCoreData(from: tracker).name
        trackerCoreData.color = trackerForCoreData(from: tracker).color
        trackerCoreData.emoji = trackerForCoreData(from: tracker).emoji
        trackerCoreData.schedule = trackerForCoreData(from: tracker).schedule
        
        let categories = fetchCategory(with: context)
        trackerCoreData.category = categories
    }
    
    private func fetchCategory(with context: NSManagedObjectContext) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.fetchLimit = 1
        let object = try? context.fetch(request).first
        return object
    }
    
    private func trackerForCoreData(from tracker: Tracker) -> TrackerForCoreData {
        let id = tracker.id
        let name = tracker.name
        let color = uiColorMarshalling.hexString(from: tracker.color)
        let emoji = tracker.emoji
        let schedule = scheduleString(from: tracker.schedule)
        return TrackerForCoreData(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule)
    }
    
    private func scheduleString(from schedule: Schedule) -> String {
        var scheduleString: [String] = []
        schedule.days.forEach { day in
                    let string = day.rawValue
                    scheduleString.append(string)
        }
        return scheduleString.joined(separator: ",")
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet(),
                movedIndexes: movedIndexes ?? Set()
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}




