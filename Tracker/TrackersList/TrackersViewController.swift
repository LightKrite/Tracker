import UIKit

final class TrackersListViewController: UIViewController {
    
    // MARK: - Properties for CoreData
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    //MARK: - Properties for CollectionView
    private var trackersArray: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var selectedCategoryRow: Int?
    private var currentDate = Date()
    private var completedTrackers: [TrackerRecord] = []
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private let cellIdentifier = "Cell"
    private let headerIdentifier = "Header"
    
    // MARK: - Properties for Empty Trackers Page
    private let emptyTrackersBackground: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(named: "YP White")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let emptyTrackersImageView: UIImageView = {
        var image = UIImage(named: "TrackersEmpty")
        var imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let emptyTrackersLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("emptyTrackersLabel", comment: "Info text")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties for NavigationBar
    private let datePicker: UIDatePicker = {
        var datePicker = UIDatePicker()
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.calendar.locale = Locale(identifier: "ru_RU")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    private var trackersLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("trackersLabel", comment: "Trackers")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let navBar: UINavigationBar = {
        var bar = UINavigationBar()
        bar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 182)
        return bar
    }()
    private lazy var searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = NSLocalizedString("searchBar.placeholder", comment: "SearchBar placeholder")
        searchBar.sizeToFit()
        searchBar.isTranslucent = true
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    private lazy var plusButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "PlusButton") ?? UIImage(),
            target: self,
            action: #selector(didTapPlusButton)
        )
        button.tintColor = UIColor(named: "YP Black")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toggleAppearance(isDark: TabBarController().isDark)
        self.accessibilityLabel = "TrackersViewController"
        view.backgroundColor = .white
        addTopBar()
        collectionViewConfig()
        hideKeyboardWhenTappedAround()
        
        // MARK: - CoreData
        
        trackerStore.delegate = self
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self

        reloadVisibleCategories()
    }
}

extension TrackersListViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        reloadVisibleCategories()
        // TODO: - PerformBatchUpdates
    }
}

extension TrackersListViewController: TrackerCategoryStoreDelegate {

    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        // TODO: - Categories update
    }
}

extension TrackersListViewController: TrackerRecordStoreDelegate {

    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        reloadVisibleCategories()
    }
}

extension TrackersListViewController {
    
    // MARK: - Reload
    private func reloadVisibleCategories() {
        
        completedTrackers = trackerRecordStore.completedTrackers
        
        let filterWeekDay = datePicker.date.dayOfWeek()
        let filterText = (searchBar.text ?? "").lowercased()

        
        var filteredCategories: [TrackerCategory] = []
        
        filteredCategories = trackerCategoryStore.categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                tracker.name.lowercased().contains(filterText)
                let dateCondition = tracker.schedule.days.contains { WeekDay in
                    WeekDay.rawValue == filterWeekDay
                }
                return textCondition && dateCondition
            }
            return TrackerCategory(
                name: category.name,
                trackers: trackers)
            
        }
        
        visibleCategories = filteredCategories.filter { $0.trackers.count != 0 }
        
        collectionView.reloadData()
        showOrHideEmptyTrackersInfo()
    }
    
    private func showOrHideEmptyTrackersInfo() {
        if visibleCategories.count == 0 {
            showEmptyTrackersInfo()
        } else {
            hideEmptyTrackersInfo()
        }
    }
    
    // MARK: - Objective-C functions
    @objc
    func didTapPlusButton() {
        let vc = TrackerTypeViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
}

// MARK: - ThirdViewController Delegate
extension TrackersListViewController: TrackerCardViewControllerDelegate {
    func sendTrackerToTrackersListViewController(newTracker: Tracker, categoriesNames: [String]?, selectedCategoryRow: Int?) {
        
        try? trackerStore.addNewTracker(newTracker, selectedCategoryRow: selectedCategoryRow)
        
        dismiss(animated: true)
    }
}

extension TrackersListViewController {
    // MARK: - Date Picker
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = datePicker.date
        searchBar.text = ""
        searchBar.endEditing(true)
        reloadVisibleCategories()
    }
}

// MARK: - UISearchBarDelegate
extension TrackersListViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadVisibleCategories()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideEmptyTrackersInfo()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.endEditing(true)
        reloadVisibleCategories()
    }
}

// MARK: - CollectionViewDataSource (NumberOfItemsInSection, CellForItemAt)
extension TrackersListViewController: UICollectionViewDataSource {
    /// Number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
        //return 1
    }
    /// Number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard visibleCategories[section].trackers.count != 0 else { return 0 }
        return visibleCategories[section].trackers.count
    }
    
    /// Cell for item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackersListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.configure(
            with: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath
        )
        
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDate = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.id == id && isSameDate
    }
}

extension TrackersListViewController: TrackersListCollectionViewCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        
        let isNotFutureDate: Bool = (
            Calendar.current.isDate(Date(), inSameDayAs: datePicker.date) ||
            Date().distance(to: datePicker.date) < 0
        )
        if isNotFutureDate {
            try? trackerRecordStore.addNewTrackerRecord(trackerRecord)
        } else {
            return
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        
        completedTrackers.enumerated().forEach { (index, trackerRecord) in
            if isSameTrackerRecord(trackerRecord: trackerRecord, id: id) {
                try? trackerRecordStore.removeTrackerRecord(trackerRecord)
            }
        }
        
    }
}

// MARK: - CollectionViewDelegate
extension TrackersListViewController: UICollectionViewDelegate {
    
    /// Switch between header and (footer removed)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = headerIdentifier
        default:
            id = ""
        }
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        guard visibleCategories.count != 0 else { return view }
        view.changeTitle(title: "\(visibleCategories[indexPath.section].name)")
        return view
    }
}

// MARK: - CollectionViewDelegateFlowLayout
extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
    /// Set layout width and height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 5, height: 148)
    }
    /// Set layout horizontal spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    /// Set layout vertical spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    /// Set header size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: 46
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultHigh)
    }
}

// MARK: - Configure constraints
private extension TrackersListViewController {
    func collectionViewConfig() {
        /// Create collectionView with custom layout
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        /// Make VC a dataSource of collectionView, to config Cell
        collectionView.dataSource = self
        /// Register Cell
        collectionView.register(TrackersListCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        /// Make VC a delegate of collectionView, to config Header and Footer
        collectionView.delegate = self
        /// Register Header
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        /// disable multiple selection
        collectionView.allowsMultipleSelection = false
    }
    func addTopBar() {
        // NavBar
        view.addSubview(navBar)
        // DatePicker
        navBar.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            datePicker.centerYAnchor.constraint(equalTo: navBar.centerYAnchor, constant: -datePicker.frame.size.height/2),
            datePicker.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16)
        ])
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        // PlusButton
        view.addSubview(plusButton)
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 16),
            plusButton.topAnchor.constraint(equalTo: navBar.topAnchor, constant: 49),
            plusButton.widthAnchor.constraint(equalToConstant: 42),
            plusButton.heightAnchor.constraint(equalToConstant: 42)
        ])
        // TrackersLabel
        navBar.addSubview(trackersLabel)
        NSLayoutConstraint.activate([
            trackersLabel.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -53),
            trackersLabel.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 16)
        ])
        // SearchBar
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
        searchBar.delegate = self
    }
    func showEmptyTrackersInfo() {
        view.addSubview(emptyTrackersBackground)
        view.addSubview(emptyTrackersImageView)
        view.addSubview(emptyTrackersLabel)
        NSLayoutConstraint.activate([
            emptyTrackersBackground.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            emptyTrackersBackground.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            emptyTrackersBackground.widthAnchor.constraint(equalToConstant: view.frame.width),
            emptyTrackersBackground.heightAnchor.constraint(equalToConstant: view.frame.height),
            emptyTrackersImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -40),
            emptyTrackersImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -40),
            emptyTrackersLabel.topAnchor.constraint(equalTo: emptyTrackersImageView.bottomAnchor, constant: 8),
            emptyTrackersLabel.widthAnchor.constraint(equalToConstant: 343),
            emptyTrackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -171.5)
        ])
    }
    func hideEmptyTrackersInfo() {
        emptyTrackersBackground.removeFromSuperview()
        emptyTrackersImageView.removeFromSuperview()
        emptyTrackersLabel.removeFromSuperview()
    }
}
