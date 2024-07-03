import UIKit

final class TrackerCategoryViewModel {
    @Observable
    private(set) var categories: [TrackerCategory] = []

    private let trackerCategoryStore: TrackerCategoryStore

    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate init error")
        }
        let trackerCategoryStore = TrackerCategoryStore(
            context: appDelegate.persistentContainer.viewContext)
        self.init(trackerCategoryStore: trackerCategoryStore)
    }

    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerCategoryStore.delegate = self
        categories = getSortedCategories()
    }

    func deleteAll() {
        try? trackerCategoryStore.deleteAll()
    }
    
    func getSortedCategories() -> [TrackerCategory] {
        return trackerCategoryStore.getSortedCategories()
    }
}

extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categories = getSortedCategories()
    }
}
