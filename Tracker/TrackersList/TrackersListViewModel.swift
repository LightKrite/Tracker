import UIKit

final class TrackersListViewModel {
    @Observable
    private (set) var categories: [TrackerCategory] = []
    @Observable
    private (set) var trackersArray: [Tracker] = []
    @Observable
    private (set) var completedTrackers: [TrackerRecord] = []

    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let trackerRecordStore: TrackerRecordStore
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate init error")
        }
        let trackerCategoryStore = TrackerCategoryStore(
            context: appDelegate.persistentContainer.viewContext)
        let trackerStore = TrackerStore(
            context: appDelegate.persistentContainer.viewContext)
        let trackerRecordStore = TrackerRecordStore(
            context: appDelegate.persistentContainer.viewContext)
        self.init(
            trackerCategoryStore: trackerCategoryStore,
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore
        )
    }

    init(
        trackerCategoryStore: TrackerCategoryStore,
        trackerStore: TrackerStore,
        trackerRecordStore: TrackerRecordStore
    ) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        
        trackerCategoryStore.delegate = self
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        
        categories = getCategories()
        trackersArray = getTrackers()
        completedTrackers = getTrackerRecors()
    }
    
    func addNew(tracker: Tracker, with categoryName: String) {
        try? trackerStore.addNewTracker(tracker, selectedCategoryName: categoryName)
    }
    
    func addNew(category: TrackerCategory) {
        try? trackerCategoryStore.addNewTrackerCategory(category)
    }
    
    func addNew(record: TrackerRecord) {
        try? trackerRecordStore.addNewTrackerRecord(record)
    }
    
    func delete(tracker: Tracker) {
        try? trackerStore.deleteSelectedTracker(with: tracker.id)
    }
    
    func deleteRecords(for tracker: Tracker) {
        try? trackerStore.deleteSelectedTrackerRecords(with: tracker.id)
    }
    
    func remove(record: TrackerRecord) {
       try? trackerRecordStore.removeTrackerRecord(record)
    }
    
    func getCategoryRow(for name: String) -> Int? {
        return trackerCategoryStore.getCategoryRow(for: name)
    }
    
    func getSortedCetagoriesForTrackersListVC() -> [TrackerCategory] {
        return trackerCategoryStore.getSortedCategories()
    }
    
    func getCategoryName(for tracker: Tracker) -> String {
        return trackerStore.getSelectedTrackerCategoryName(with: tracker.id)
    }
    
    func getCategories() -> [TrackerCategory] {
        return trackerCategoryStore.categories
    }
    
    func getTrackers() -> [Tracker] {
        return trackerStore.trackers
    }
    
    func getTrackerRecors() -> [TrackerRecord] {
        return trackerRecordStore.completedTrackers
    }
}

extension TrackersListViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categories = getCategories()
    }
}

extension TrackersListViewModel: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        trackersArray = getTrackers()
    }
}

extension TrackersListViewModel: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        completedTrackers = getTrackerRecors()
    }
}
