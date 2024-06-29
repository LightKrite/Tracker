import UIKit
import CoreData

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidID
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedule
    case contextInitError
}

struct TrackerRecordStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func store(
        _ store: TrackerRecordStore,
        didUpdate update: TrackerRecordStoreUpdate
    )
}

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?

    weak var delegate: TrackerRecordStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordStoreUpdate.Move>?
    
    var completedTrackers: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let trackers = try? objects.map({ try self.trackerRecord(from: $0) })
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
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.objectID, ascending: true)
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
    
    private func trackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id else {
            throw TrackerRecordStoreError.decodingErrorInvalidID
        }
        guard let date = trackerRecordCoreData.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidName
        }
        return TrackerRecord(
            id: id,
            date: date)
    }

    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
        try context.save()
    }

    private func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
        
        let trackers = fetchTrackers(with: context)
        
        trackerRecordCoreData.tracker = trackers?.first(where: {$0.id == trackerRecord.id} )
    }
    
    private func fetchTrackers(with context: NSManagedObjectContext) -> [TrackerCoreData]? {
        let request = TrackerCoreData.fetchRequest()
        let objects = try? context.fetch(request)
        return objects
    }
    
    func removeTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        
        let records = fetchRecords(with: context)
        
        guard let recordToDelete = records?.first(where: {$0.id == trackerRecord.id && $0.date == trackerRecord.date} ) else { return }
        
        context.delete(recordToDelete)
        try context.save()
    }
    
    private func fetchRecords(with context: NSManagedObjectContext) -> [TrackerRecordCoreData]? {
        let request = TrackerRecordCoreData.fetchRequest()
        let objects = try? context.fetch(request)
        return objects
    }
    
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerRecordStoreUpdate.Move>()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerRecordStoreUpdate(
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





