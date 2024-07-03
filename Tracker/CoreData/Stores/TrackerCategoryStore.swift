import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidName
    case decodingErrorInvalidTrackers
    case encodingErrorInvalidTrackers
}

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(
        _ store: TrackerCategoryStore,
        didUpdate update: TrackerCategoryStoreUpdate
    )
}

final class TrackerCategoryStore: NSObject {
    
    private let trackerStore = TrackerStore()
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?

    weak var delegate: TrackerCategoryStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    var categories: [TrackerCategory] {
        guard let objects = self.fetchedResultsController?.fetchedObjects
        else { return []}
        let sortedObjects = objects.sorted(by: { $0.categoryId > $1.categoryId } )
        guard let categories = try? sortedObjects.map({ try self.category(from: $0) })
        else { return [] }
        return categories
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
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.objectID, ascending: true)
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
    
    private func category(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = trackerCategoryCoreData.name else {
            throw TrackerCategoryStoreError.decodingErrorInvalidName
        }
        guard let trackers = try? self.trackers(from: trackerCategoryCoreData) else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        return TrackerCategory(
            name: name,
            trackers: trackers
        )
    }
    
    private func trackers(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> [Tracker] {
        guard let trackersFromCoreData = trackerCategoryCoreData.trackers else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        guard let trackers = try? trackersFromCoreData.map({ try trackerStore.tracker(from: $0 as? TrackerCoreData ?? TrackerCoreData()) }) else {
            return []
        }
        return trackers
    }

    func addNewTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExistingTrackerCategories(trackerCategoryCoreData, with: trackerCategory)
        try context.save()
    }

    private func updateExistingTrackerCategories(_ trackerCategoryCoreData: TrackerCategoryCoreData, with trackerCategory: TrackerCategory) {
        let category = TrackerCategory(
            name: trackerCategory.name,
            trackers: trackerCategory.trackers
        )
        trackerCategoryCoreData.name = category.name
        trackerCategoryCoreData.categoryId = Int32(categories.count)
    }
    
    func getSortedCategories() -> [TrackerCategory]{
        guard let objects = fetchAllCategories(with: context)
        else { return [] }
        let sortedObjects = objects.sorted(by: { $0.categoryId < $1.categoryId } )
        guard let categories = try? sortedObjects.map({ try self.category(from: $0) })
        else { return [] }
        return categories
    }
    
    private func fetchAllCategories(with context: NSManagedObjectContext) -> [TrackerCategoryCoreData]? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "categoryId", ascending: false)]
        let objects = try? context.fetch(request)
        return objects
    }
    
    func deleteAll() throws {
        guard let objects = fetchAllCategories(with: context) else {
            return
        }
        for object in objects {
            context.delete(object)
        }
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerCategoryStoreUpdate(
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


