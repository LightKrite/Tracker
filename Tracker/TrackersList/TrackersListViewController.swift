import UIKit

final class TrackersListViewController: UIViewController {
    
    // MARK: - MVVM property:
    private var viewModel: TrackersListViewModel?
    
    // MARK: - Analytics
    private let analyticsService = AnalyticsService()
    
    //MARK: - Properties for CollectionView
    private var categories: [TrackerCategory] = [] {
        didSet {
            reloadVisibleCategories()
        }
    }
    private var trackersArray: [Tracker] = [] {
        didSet {
            reloadVisibleCategories()
        }
    }
    private var completedTrackers: [TrackerRecord] = [] {
        didSet {
            reloadVisibleCategories()
        }
    }
    private var visibleCategories: [TrackerCategory] = []
    private var selectedCategoryRow: Int?
    private var currentDate = Date()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    private let cellIdentifier = "Cell"
    private let headerIdentifier = "Header"
    
    // MARK: - Properties for Empty Trackers Page
    private let emptyTrackersBackground: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.ypWhite
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
        label.text = "emptyTrackersLabel".localized()
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
        label.text = "trackersLabel".localized()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let navBar: UINavigationBar = {
        var bar = UINavigationBar()
        bar.layer.backgroundColor = UIColor.clear.cgColor
        bar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 182)
        return bar
    }()
    private lazy var searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = "searchBar.placeholder".localized()
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
        button.tintColor = UIColor.ypBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapFilterButton)
        )
        button.backgroundColor = UIColor.ypBlue
        button.setTitle("filterButton".localized(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(UIColor.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var selectedFilterRow: Int = 1 {
        didSet {
            reloadVisibleCategories()
        }
    }
    
    private var isDark: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accessibilityLabel = "TrackersViewController"
        view.backgroundColor = UIColor.ypWhite
        
        addTopBar()
        collectionViewConfig()
        hideKeyboardWhenTappedAround()
        
        viewModel = TrackersListViewModel()
        guard let viewModel = viewModel else { return }
        
        self.categories = viewModel.categories
        self.trackersArray = viewModel.trackersArray
        self.completedTrackers = viewModel.completedTrackers
        
        viewModel.$categories.bind { _ in
            self.categories = viewModel.categories
        }
        viewModel.$trackersArray.bind { _ in
            self.trackersArray = viewModel.trackersArray
        }
        viewModel.$completedTrackers.bind { _ in
            self.completedTrackers = viewModel.completedTrackers
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.viewWillAppear(on: AnalyticsScreens.main.rawValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.viewWillDisappear(from: AnalyticsScreens.main.rawValue)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        isDark = self.isDarkMode
    }
}

extension TrackersListViewController {
    
    // MARK: - Reload
    private func reloadVisibleCategories() {
        
        let filterText = (searchBar.text ?? "").lowercased()
        
        var filteredCategories: [TrackerCategory] = []
        
        var completedTrackersIDs: [UUID] = []
        completedTrackers.forEach { record in
            let isSameDayAs = Calendar.current.isDate(record.date, inSameDayAs: datePicker.date)
            if isSameDayAs {
                completedTrackersIDs.append(record.id)
            }
        }
        let uniqueIDs = Array(Set(completedTrackersIDs))
        
        filteredCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                tracker.name.lowercased().contains(filterText)
                let filterCondition = filterCondition(for: tracker, completedIDs: uniqueIDs)
                
                return textCondition && filterCondition
            }
            return TrackerCategory(
                name: category.name,
                trackers: trackers)
            
        }
        
        visibleCategories = filteredCategories.filter { $0.trackers.count != 0 }
        
        visibleCategories = visibleCategories.filter { $0.name == "pinnedCategoryName".localized()} + visibleCategories.filter { $0.name != "pinnedCategoryName".localized()}
        collectionView.reloadData()
        showOrHideEmptyTrackersInfo()
    }
    
    private func filterCondition(for tracker: Tracker, completedIDs: [UUID]) -> Bool {
        
        let filterWeekDay = datePicker.date.dayOfWeek()
        
        let dateCondition = tracker.schedule.days.contains { weekDay in
            weekDay.rawValue == filterWeekDay
        }
        
        let completeCondition = completedIDs.contains(where: { trackerID in
            trackerID == tracker.id
        })
        
        enum Filters: Int  {
            case allTrackers = 0
            case todayTrackers = 1
            case completeTrackers = 2
            case uncompletedTrackers = 3
        }
        
        switch selectedFilterRow {
        case Filters.allTrackers.rawValue:
            return dateCondition
        case Filters.todayTrackers.rawValue:
            return dateCondition
        case Filters.completeTrackers.rawValue:
            return completeCondition && dateCondition
        case Filters.uncompletedTrackers.rawValue:
            return !completeCondition && dateCondition
        default:
            return true
        }
    }
    
    private func showOrHideEmptyTrackersInfo() {
        if visibleCategories.count == 0 {
            showEmptyTrackersInfo()
            if trackersArray.count > 0 {
                emptyTrackersLabel.text = "emptyTrackersLabel.nothingFound".localized()
                addFilterButton()
            } else {
                emptyTrackersLabel.text = "emptyTrackersLabel".localized()
            }
        } else {
            hideEmptyTrackersInfo()
            filterButton.removeFromSuperview()
            addFilterButton()
        }
    }
    
    // MARK: - Objective-C functions
    @objc
    func didTapPlusButton() {
        analyticsService.didTap(AnalyticsItems.add.rawValue, AnalyticsScreens.main.rawValue)
        
        let vc = TrackerTypeViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc
    func didTapFilterButton() {
        analyticsService.didTap(AnalyticsItems.filter.rawValue, AnalyticsScreens.main.rawValue)
        
        let vc = TrackersFiltersViewController(selectedFilterRow: selectedFilterRow)
        vc.delegate = self
        present(vc, animated: true)
    }
}

extension TrackersListViewController: TrackersFiltersViewControllerDelegate {
    func sendSelectedFilterToTrackersListViewController(selectedFilterRow: Int) {
        if selectedFilterRow == 1 {
            datePicker.date = Date()
        }
        self.selectedFilterRow = selectedFilterRow
        dismiss(animated: true)
    }
}

// MARK: - ThirdViewController Delegate
extension TrackersListViewController: TrackerCardViewControllerDelegate {
    func sendTrackerToTrackersListViewController(newTracker: Tracker, selectedCategoryName: String) {
        changeDatePickerDateForTracker(tracker: newTracker)
        guard let viewModel = viewModel else { return }
        viewModel.addNew(tracker: newTracker, with: selectedCategoryName)
        dismiss(animated: true)
    }
    
    private func changeDatePickerDateForTracker(tracker: Tracker) {
        if tracker.schedule.days.contains(where: { $0 == WeekDay.empty }) {
            let trackerDay = tracker.schedule.days.first { $0 != WeekDay.empty}?.description.lowercased()
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let dayOfWeek = calendar.component(.weekday, from: today)
            if let weekDays = calendar.range(of: .weekday, in: .weekOfYear, for: today) {
                let days = (weekDays.lowerBound ..< weekDays.upperBound).compactMap {
                    calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today)
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                let formattedDays = days.map { day in formatter.string(from: day)}
                if let selectedDayIndex = formattedDays.firstIndex(where: { day in
                    day.lowercased() == trackerDay
                }) {
                    datePicker.date = days[selectedDayIndex]
                    selectedFilterRow = 0
                }
            }
        }
        
    }
}

// MARK: - TrackerEditableCardViewController Delegate
extension TrackersListViewController: TrackerEditableCardViewControllerDelegate {
    func sendEditedTrackerToTrackersListViewController(editedTracker: Tracker, selectedCategoryName: String) {
        changeDatePickerDateForTracker(tracker: editedTracker)
        guard let viewModel = viewModel else { return }
        viewModel.delete(tracker: editedTracker)
        viewModel.addNew(tracker: editedTracker, with: selectedCategoryName)
        if editedTracker.isPinned {
            pin(tracker: editedTracker)
        }
        dismiss(animated: true)
    }
}

extension TrackersListViewController {
    // MARK: - Date Picker
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        searchBar.text = ""
        searchBar.endEditing(true)
        currentDate = datePicker.date
        if !Calendar.current.isDate(sender.date, inSameDayAs: Date()) && selectedFilterRow < 2 {
            selectedFilterRow = 0
        }
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
            indexPath: indexPath,
            isPinned: tracker.isPinned,
            isDark: isDark
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
        
        analyticsService.didTap(AnalyticsItems.track.rawValue, AnalyticsScreens.main.rawValue)
        
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        
        let isNotFutureDate: Bool = (
            Calendar.current.isDate(Date(), inSameDayAs: datePicker.date) ||
            Date().distance(to: datePicker.date) < 0
        )
        if isNotFutureDate {
            guard let viewModel = viewModel else { return }
            viewModel.addNew(record: trackerRecord)
        } else {
            print("impossible to complete tracker in future")
            return
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        
        analyticsService.didTap(AnalyticsItems.track.rawValue, AnalyticsScreens.main.rawValue)
        
        completedTrackers.enumerated().forEach { (index, trackerRecord) in
            if isSameTrackerRecord(trackerRecord: trackerRecord, id: id) {
                guard let viewModel = viewModel else { return }
                viewModel.remove(record: trackerRecord)
            }
        }
        
    }
}

// MARK: - CollectionViewDelegate
extension TrackersListViewController: UICollectionViewDelegate {
    // Context menu configuration
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersListCollectionViewCell else {
            return nil
        }
        
        return UITargetedPreview(view: cell.cellBackgroundSquare)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPaths.count > 0 else {
            return nil
        }
        let indexPath = indexPaths[0]
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        let identifier = NSString(string: "\(tracker.id)")
        
        let config = UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil
        ) { _ in
            
            let pin = UIAction(
                title: tracker.isPinned ? "trackerList.unpin".localized() : "trackerList.pin".localized(),
                image: UIImage(),
                identifier: nil,
                discoverabilityTitle: nil,
                state: .off
            ) { [weak self] _ in
                
                if tracker.isPinned {
                    self?.unpinTracker(indexPath: indexPath)
                } else {
                    self?.pinTracker(indexPath: indexPath)
                }
            }
            
            let edit = UIAction(
                title: "trackerList.edit".localized(),
                image: UIImage(),
                identifier: nil,
                discoverabilityTitle: nil,
                state: .off
            ) { [weak self] _ in
                self?.editTracker(indexPath: indexPath)
            }
            
            let deleteAction = UIAction(title: "trackerList.delete".localized()) { [weak self] _ in
                self?.deleteTracker(indexPath: indexPath)
            }
            let attributedString = NSAttributedString(string: "trackerList.delete".localized(), attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.red
            ])
            deleteAction.setValue(attributedString, forKey: "attributedTitle")
            
            return UIMenu(
                title: "",
                identifier: nil,
                children: [pin, edit, deleteAction]
            )
        }
        return config
    }
    
    private func unpinTracker(indexPath: IndexPath) {
        let unpinnedFrom = visibleCategories[indexPath.section]
        let trackerToUnpin = unpinnedFrom.trackers[indexPath.row]
        guard let categoryName = trackerToUnpin.pinnedFrom else {
            return
        }
        let unpinnedTracker = Tracker(
            id: trackerToUnpin.id,
            name: trackerToUnpin.name,
            color: trackerToUnpin.color,
            emoji: trackerToUnpin.emoji,
            schedule: trackerToUnpin.schedule,
            isPinned: false,
            pinnedFrom: nil)
        guard let viewModel = viewModel else { return }
        viewModel.delete(tracker: trackerToUnpin)
        viewModel.addNew(tracker: unpinnedTracker, with: categoryName)
    }
    
    private func pinTracker(indexPath: IndexPath) {
        let pinned = "pinnedCategoryName".localized()
        guard let viewModel = viewModel else { return }
        if viewModel.getCategoryRow(for: pinned) != nil {
            savePinnedTracker(at: indexPath, pinnedCategoryName: pinned)
        } else {
            let pinnedCategory = TrackerCategory(name: pinned, trackers: [])
            viewModel.addNew(category: pinnedCategory)
            if viewModel.getCategoryRow(for: pinned) != nil {
                savePinnedTracker(at: indexPath, pinnedCategoryName: pinned)
            }
        }
    }
    
    private func pin(tracker: Tracker) {
        guard let viewModel = viewModel else { return }
        let pinnedFrom = viewModel.getCategoryName(for: tracker)
        let pinnedTracker = Tracker(
            id: tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            isPinned: true,
            pinnedFrom: pinnedFrom)
        viewModel.delete(tracker: tracker)
        viewModel.addNew(tracker: pinnedTracker, with: "pinnedCategoryName".localized())
    }
    
    private func savePinnedTracker(at indexPath: IndexPath, pinnedCategoryName: String) {
        let pinnedFrom = visibleCategories[indexPath.section]
        let trackerToPin = pinnedFrom.trackers[indexPath.row]
        let pinnedTracker = Tracker(
            id: trackerToPin.id,
            name: trackerToPin.name,
            color: trackerToPin.color,
            emoji: trackerToPin.emoji,
            schedule: trackerToPin.schedule,
            isPinned: true,
            pinnedFrom: pinnedFrom.name)
        guard let viewModel = viewModel else { return }
        viewModel.delete(tracker: trackerToPin)
        viewModel.addNew(tracker: pinnedTracker, with: pinnedCategoryName)
    }
    
    private func editTracker(indexPath: IndexPath) {
        let trackerToEdit = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        analyticsService.didTap(AnalyticsItems.edit.rawValue, AnalyticsScreens.main.rawValue)
        guard let viewModel = viewModel else { return }
        
        let isTrackerRegular = true
        
        let selectedCategoryName = viewModel.getCategoryName(for: trackerToEdit)
        let categories = viewModel.getSortedCetagoriesForTrackersListVC()
        let selectedCategoryRow = Int(categories.firstIndex { category in
            category.name == selectedCategoryName
        } ?? 0)
        var categoriesNames: [String] = []
        categories.forEach { category in
            categoriesNames.append(category.name)
        }
        
        let completedDays = completedTrackers.filter { $0.id == trackerToEdit.id }.count
        
        var pinnedFromCategoryRow: Int = 0
        if let pinnedFrom = trackerToEdit.pinnedFrom {
            
            pinnedFromCategoryRow = viewModel.getCategoryRow(for: pinnedFrom) ?? 0
            let categoriesFiltered = categories.filter { $0.name != "pinnedCategoryName".localized()
            }
            var categoriesNamesFiltered: [String] = []
            categoriesFiltered.forEach { category in
                categoriesNamesFiltered.append(category.name)
            }
            if pinnedFromCategoryRow > categoriesNamesFiltered.count-1 {
                pinnedFromCategoryRow = selectedCategoryRow
            }
        }
        
        let vc = TrackerEditableCardViewController(
            regularTracker: isTrackerRegular,
            trackerID: trackerToEdit.id,
            trackerName: trackerToEdit.name,
            trackerColor: trackerToEdit.color,
            trackerEmoji: trackerToEdit.emoji,
            trackerDays: trackerToEdit.schedule.days,
            isPinned: trackerToEdit.isPinned,
            pinnedFrom: trackerToEdit.pinnedFrom,
            categories: categories,
            selectedCategoryRow: trackerToEdit.isPinned ? pinnedFromCategoryRow : selectedCategoryRow,
            completedDays: completedDays
        )
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func deleteTracker(indexPath: IndexPath) {
        let selectedTracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        analyticsService.didTap(AnalyticsItems.delete.rawValue, AnalyticsScreens.main.rawValue)
        
        guard let viewModel = viewModel else { return }
        viewModel.delete(tracker: selectedTracker)
        viewModel.deleteRecords(for: selectedTracker)
    }
    
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
        return CGSize(width: (collectionView.bounds.width / 2 - 5) - 16, height: 148)
    }
    /// Set layout horizontal spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    /// Set layout vertical spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: section == (visibleCategories.count-1) ? 100 : 0, right: 16)
        return sectionInsets
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
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
    
    func addFilterButton() {
        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
