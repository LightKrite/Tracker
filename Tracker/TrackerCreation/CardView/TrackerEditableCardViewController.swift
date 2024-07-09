import UIKit

protocol TrackerEditableCardViewControllerDelegate: AnyObject {
    func sendEditedTrackerToTrackersListViewController(editedTracker: Tracker, selectedCategoryName: String)
}

// MARK: - TrackerCardViewController
final class TrackerEditableCardViewController: UIViewController {
    
    weak var delegate: TrackerEditableCardViewControllerDelegate?
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private let trackerCardViewController = TrackerCardViewController()
    private let analyticsService = AnalyticsService()
    
    private let categoryButtonTitle = NSLocalizedString("categoryButtonTitle", comment: "Categoty button title")
    private let scheduleButtonTitle = NSLocalizedString("scheduleButtonTitle", comment: "Schedule button title")
    
    
    // MARK: - Category properties
    private var categories: [TrackerCategory]?
    private var newCategoriesNames: [String]?
    private var selectedCategoryRow: Int?
    
    // MARK: - CollectionView properties
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private let cellIdentifier = "Cell"
    private let secondCellIdentifier = "SecondCell"
    private let headerIdentifier = "Header"
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.contentSize = contentSize
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.frame.size = contentSize
        return view
    }()
    
    private lazy var contentSize: CGSize = CGSize(width: view.frame.width, height: regularTracker ? 781 : 706)
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tracker Edit"
        return label
    }()
    
    private var titleBackground: UIView = {
        var background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        return background
    }()
    
    private var daysCounterTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textLabel.textAlignment = .center
        return textLabel
    }()
    
    private var textField: UITextField = {
        let textField = TextFieldWithPadding()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor.ypLightGray.withAlphaComponent(0.3)
        textField.clearButtonMode = .whileEditing
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapCategoryButton)
        )
        button.setTitle(categoryButtonTitle, for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.contentHorizontalAlignment = .left
        button.setTitleColor(UIColor.ypGray, for: .normal)
        button.backgroundColor = UIColor.ypLightGray.withAlphaComponent(0.3)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 26, left: 16, bottom: 26, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapScheduleButton)
        )
        button.setTitle(scheduleButtonTitle, for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.contentHorizontalAlignment = .left
        button.setTitleColor(UIColor.ypGray, for: .normal)
        button.backgroundColor = UIColor.ypLightGray.withAlphaComponent(0.3)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 26, left: 16, bottom: 26, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var categoryButtonArrowImageView: UIImageView = {
        let image = UIImage(named: "ArrowRight")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var scheduleButtonArrowImageView: UIImageView = {
        let image = UIImage(named: "ArrowRight")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var buttonBottomDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapCancelButton)
        )
        button.setTitle(NSLocalizedString("trackerCard.cancelButton", comment: "Title for cancel button"), for: .normal)
        button.setTitleColor(UIColor.ypRed, for: .normal)
        button.backgroundColor = UIColor.ypWhite
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var saveTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapSaveTrackerButton)
        )
        button.setTitle(NSLocalizedString("trackerCard.saveTrackerButton", comment: "Title for creation button"), for: .normal)
        button.setTitleColor(UIColor.ypWhite, for: .normal)
        button.backgroundColor = UIColor.ypGray
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private var emojieSelectedAt: Int?
    private var previousEmojiWas: Int?
    
    private var colorSelectedAt: Int?
    private var previousColorWas: Int?
    
    private var regularTracker: Bool
    
    private var trackerID: UUID
    private var trackerName: String
    private var trackerColor: UIColor
    private var trackerEmoji: String
    private var trackerDays: [WeekDay]
    private var isPinned: Bool
    private var pinnedFrom: String?
    private var completedDays: Int

    init(regularTracker: Bool,
         trackerID: UUID,
         trackerName: String,
         trackerColor: UIColor,
         trackerEmoji: String,
         trackerDays: [WeekDay],
         isPinned: Bool,
         pinnedFrom: String?,
         categories: [TrackerCategory],
         selectedCategoryRow: Int,
         completedDays: Int
    ) {
        self.regularTracker = regularTracker
        self.trackerID = trackerID
        self.trackerName = trackerName
        self.trackerColor = trackerColor
        self.trackerEmoji = trackerEmoji
        self.trackerDays = trackerDays
        self.isPinned = isPinned
        self.pinnedFrom = pinnedFrom
        self.categories = categories
        self.selectedCategoryRow = selectedCategoryRow
        self.completedDays = completedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.ypWhite
        titleConfig()
        horizontalStackViewConfig()
        scrollViewConfig()
        textFieldConfig()
        textField.delegate = self
        collectionView.delegate = self
        
        emojieSelectedAt = trackerCardViewController.emojies.firstIndex(of: trackerEmoji)
        trackerCardViewController.colors.forEach { color in
            if color.isEqual(color: trackerColor) {
                colorSelectedAt = trackerCardViewController.colors.firstIndex(of: color)
            }
        }
        
        textField.text = trackerName
        
        saveTrackerButtonIsActive(trackerName.count > 0)
        
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of completed days"),
            completedDays
        )
        daysCounterTextLabel.text = daysString
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.viewWillAppear(on: AnalyticsScreens.card.rawValue)
        newCategoriesNames = getCategoriesNamesFromStore()
        if !regularTracker {
            verticalStackView.removeFromSuperview()
            buttonBottomDivider.removeFromSuperview()
            categoryButtonConfig()
        } else {
            categoryButton.removeFromSuperview()
            verticalStackViewConfig()
            scheduleButtonTitleTextConfig()
            contentSize = CGSize(width: view.frame.width, height: 781)
        }
        categoryButtonTitleTextConfig()
        collectionViewConfig()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.viewWillDisappear(from: AnalyticsScreens.edit.rawValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSelectedEmoji()
        setSelectedColor()
    }
    
    private func getCategoriesNamesFromStore() -> [String] {
        let categoriesFromStore = trackerCategoryStore.getSortedCategories()
        var categoriesNamesFromStore: [String] = []
        categoriesFromStore.forEach { categoriesFromStore in
            if categoriesFromStore.name != "pinnedCategoryName".localized() {
                categoriesNamesFromStore.append(categoriesFromStore.name)
            }
        }
        return categoriesNamesFromStore
    }
}

extension TrackerEditableCardViewController {
    // MARK: - SaveTracker
    private func saveTracker() -> Tracker {
        
        if let emojieSelectedAt = emojieSelectedAt {
            trackerEmoji = trackerCardViewController.emojies[emojieSelectedAt]
        } else {
            trackerEmoji = trackerCardViewController.emojies.randomElement() ?? "X"
        }
        
        if let colorSelectedAt = colorSelectedAt {
            trackerColor = trackerCardViewController.colors[colorSelectedAt]
        } else {
            trackerColor = trackerCardViewController.colors.randomElement() ?? .black
        }
        
        let schedule = Schedule(days: trackerDays)
        
        if let selectedCategoryRow = selectedCategoryRow,
           let newCategoriesNames = newCategoriesNames {
            let newTracker: Tracker = Tracker(
                    id: trackerID,
                    name: trackerName,
                    color: trackerColor,
                    emoji: trackerEmoji,
                    schedule: schedule,
                    isPinned: isPinned,
                    pinnedFrom: newCategoriesNames[selectedCategoryRow])
                return newTracker
        } else {
            let newTracker: Tracker = Tracker(
                    id: trackerID,
                    name: trackerName,
                    color: trackerColor,
                    emoji: trackerEmoji,
                    schedule: schedule,
                    isPinned: isPinned,
                    pinnedFrom: pinnedFrom)
                return newTracker
        }
        
        
    }
    
    // MARK: - Set category and schedule buttons titles
    private func categoryButtonTitleTextConfig() {
        var categoryButtonTitleText = "\(categoryButtonTitle)"
        if let selectedCategory = selectedCategoryRow,
           let newCategoriesNames = newCategoriesNames {
                categoryButtonTitleText = "\(categoryButtonTitle)\n\(newCategoriesNames[selectedCategory])"
        }
        let mutableString = createMutableString(from: categoryButtonTitleText, forButtonWithTitle: categoryButtonTitle)
        categoryButton.setAttributedTitle(mutableString, for: .normal)
    }
    
    private func scheduleButtonTitleTextConfig() {
        
        var stringArray: [String] = []
        for item in 0..<trackerDays.count {
            let value = trackerDays[item].rawValue
            stringArray.append(value)
        }
        
        let weekEnds: [WeekDay] = [.empty, .empty, .empty, .empty, .empty, .saturday,.sunday]
        let weekDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .empty, .empty]
        let empty: [WeekDay] = [.empty, .empty, .empty, .empty, .empty, .empty, .empty]
        
        var scheduleButtonTitleText: String = ""
        switch trackerDays {
        case WeekDay.allCases.filter { $0 != WeekDay.empty }:
            scheduleButtonTitleText = "\(scheduleButtonTitle)\n\(NSLocalizedString("trackerCard.scheduleButtonTitleText.allCases", comment: "Schedule all cases - everyday"))"
        case weekDays:
            scheduleButtonTitleText = "\(scheduleButtonTitle)\n\(NSLocalizedString("trackerCard.scheduleButtonTitleText.weekDays", comment: "Schedule all cases - week days"))"
        case weekEnds:
            scheduleButtonTitleText = "\(scheduleButtonTitle)\n\(NSLocalizedString("trackerCard.scheduleButtonTitleText.weekEnds", comment: "Schedule all cases - week ends"))"
        case empty:
            scheduleButtonTitleText = scheduleButtonTitle
        default:
            let filteredAndShuffledArray = stringArray.filter({ $0 != "" })
            let prefixedArray = filteredAndShuffledArray.map { $0.prefix(3) }
            let joinedString = prefixedArray.joined(separator: ", ")
            let replacedStringMon = joinedString.replacingOccurrences(of: "Mon", with: NSLocalizedString("mondayPrefixed", comment: "Monday prefixed"))
            let replacedStringTue = replacedStringMon.replacingOccurrences(of: "Tue", with: NSLocalizedString("tuesdayPrefixed", comment: "Tuesday prefixed"))
            let replacedStringWed = replacedStringTue.replacingOccurrences(of: "Wed", with: NSLocalizedString("wednesdayPrefixed", comment: "Wednesday prefixed"))
            let replacedStringThu = replacedStringWed.replacingOccurrences(of: "Thu", with: NSLocalizedString("thursdayPrefixed", comment: "Thursday prefixed"))
            let replacedStringFri = replacedStringThu.replacingOccurrences(of: "Fri", with: NSLocalizedString("fridayPrefixed", comment: "Friday prefixed"))
            let replacedStringSat = replacedStringFri.replacingOccurrences(of: "Sat", with: NSLocalizedString("saturdayPrefixed", comment: "Saturday prefixed"))
            let replacedStringSun = replacedStringSat.replacingOccurrences(of: "Sun", with: NSLocalizedString("sundayPrefixed", comment: "Sunday prefixed"))
            scheduleButtonTitleText = "\(scheduleButtonTitle)\n\(replacedStringSun)"
        }
        let mutableString = createMutableString(from: scheduleButtonTitleText, forButtonWithTitle: scheduleButtonTitle)
        scheduleButton.setAttributedTitle(mutableString, for: .normal)
    }
    
    private func createMutableString(from string: String, forButtonWithTitle buttonTitle: String) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(string: string)
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.ypBlack, range: NSRange(location: 0, length: buttonTitle.count))
        return mutableString
    }
    
    // MARK: - Objective-C functions
    
    @objc
    func didTapCategoryButton() {
            let categories = self.categories ?? []
            var categoriesNames: [String] = []
            if categories.count != 0 {
                for category in 0 ..< categories.count {
                    categoriesNames.append(categories[category].name)
                }
            } else {
                categoriesNames = []
            }
            if let newCategoriesNames = newCategoriesNames {
                for item in 0 ..< newCategoriesNames.count {
                    if item > (categoriesNames.count - 1) && !categoriesNames.contains(newCategoriesNames[item]) {
                        categoriesNames.append(newCategoriesNames[item])
                    }
                }
            }
            let vc = TrackerCategoryViewController(array: categoriesNames, selectedCategoryRow: selectedCategoryRow ?? nil)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
    }
    
    @objc
    func didTapScheduleButton() {
        let vc = TrackerScheduleViewController(newWeekDaysNamesArray: trackerDays)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc
    func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc
    func didTapSaveTrackerButton() {
        let newTracker = saveTracker()
        guard let selectedCategoryRow = selectedCategoryRow,
              let newCategoriesNames = newCategoriesNames
        else {
            return
        }
        self.delegate?.sendEditedTrackerToTrackersListViewController(editedTracker: newTracker, selectedCategoryName: newCategoriesNames[selectedCategoryRow])
    }
    
    func saveTrackerButtonIsActive(_ bool: Bool) {
        let empty: [WeekDay] = [.empty, .empty, .empty, .empty, .empty, .empty, .empty]
        if bool && trackerDays != empty || !regularTracker {
            saveTrackerButton.isEnabled = true
            saveTrackerButton.backgroundColor = UIColor.ypBlack
        } else {
            saveTrackerButton.isEnabled = false
            saveTrackerButton.backgroundColor = UIColor.ypGray
        }
    }
}

// MARK: - UITextFieldDelegate
extension TrackerEditableCardViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        guard let updatedString = updatedString else { return false }
        trackerName = updatedString
        saveTrackerButtonIsActive(trackerName.count > 0 && selectedCategoryRow != nil)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        saveTrackerButtonIsActive(false)
        textField.text = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
}

// MARK: - TrackerCard Delegate
extension TrackerEditableCardViewController: TrackerCategoryViewControllerDelegate {
    func sendSelectedCategoryNameToTrackerCard(arrayWithCategoriesNames: [String], selectedCategoryRow: Int, selectedName: String) {
        saveTrackerButtonIsActive(trackerName.count > 0)
        /// if current categories array is nil we need to set categories names
        if self.newCategoriesNames == nil {
            /// create empty array with categories
            var emptyCategoriesNames: [String] = []
            /// start for loop if array with categories names not empty
            for item in 0 ..< arrayWithCategoriesNames.count {
                emptyCategoriesNames.append(arrayWithCategoriesNames[item])
            }
            /// make current categories array equal to empty array (alredy with names)
            self.newCategoriesNames = emptyCategoriesNames
        } else {
            /// force unwrap optional current categories
            guard let newCategoriesNames = newCategoriesNames else { return }
            /// if user added new categories, we need to append them to the current categories
            if arrayWithCategoriesNames.count > newCategoriesNames.count {
                /// start for loop array with names
                for item in 0 ..< arrayWithCategoriesNames.count {
                    /// if index of name is bigger then current array count, append in it new category with new name
                    if item > (newCategoriesNames.count-1) {
                        self.newCategoriesNames?.append(arrayWithCategoriesNames[item])
                    }
                }
            }
        }
        /// set selected category index
        self.selectedCategoryRow = selectedCategoryRow
        categoryButtonTitleTextConfig()
        
        dismiss(animated: true, completion: { })
    }
}

// MARK: - TrackerSchedule Delegate
extension TrackerEditableCardViewController: TrackerScheduleViewControllerDelegate {
    func sendScheduleToTrackerCardViewController(array: [WeekDay]) {
        trackerDays = array
        scheduleButtonTitleTextConfig()
        saveTrackerButtonIsActive(trackerDays.count > 0)
    }
}

// MARK: - CollectionViewDataSource
extension TrackerEditableCardViewController: UICollectionViewDataSource {
    /// Number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    /// Number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        18
    }
    
    /// Cell for item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCardCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(
                indexPath: indexPath,
                emojiLabel: trackerCardViewController.emojies[indexPath.row],
                backgroundColor: UIColor.ypWhite
            )
            if indexPath.row == emojieSelectedAt {
                trackerEmoji = trackerCardViewController.emojies[indexPath.row]
                cell.changeCellBackgroundColor(color: UIColor.ypLightGray)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: secondCellIdentifier, for: indexPath) as? TrackerCardCollectionViewSecondCell else {
                return UICollectionViewCell()
            }
            cell.configure(
                indexPath: indexPath,
                color: trackerCardViewController.colors[indexPath.row],
                borderWidth: 0,
                alpha: 0
            )
            if indexPath.row == colorSelectedAt {
                trackerColor = trackerCardViewController.colors[indexPath.row]
                cell.changeCellBackground(borderWidth: 3, alpha: 0.3)
            }
            return cell
        }
    }
    
    private func setSelectedEmoji() {
        /// get selected emoji index and set it to colletion view
        guard let emojieSelectedAt = emojieSelectedAt else { return }
        let firstIndexPath = IndexPath(row: emojieSelectedAt, section: 0)
        setSelectedEmoji(for: firstIndexPath)
    }
    
    private func setSelectedColor() {
        guard let colorSelectedAt = colorSelectedAt else { return }
        let secondIndexPath = IndexPath(row: colorSelectedAt, section: 0)
        setSelectedColor(for: secondIndexPath)
    }
}

// MARK: - UICollectionViewDelegate
extension TrackerEditableCardViewController: UICollectionViewDelegate {
    
    /// Did selecet cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            setSelectedEmoji(for: indexPath)
        } else {
            setSelectedColor(for: indexPath)
        }
    }
    
    private func setSelectedEmoji(for indexPath: IndexPath) {
            guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCardCollectionViewCell else {
                //assertionFailure("No cell")
                return
            }
            if emojieSelectedAt == nil {
                previousEmojiWas = indexPath.row
                emojieSelectedAt = indexPath.row
            } else {
                previousEmojiWas = emojieSelectedAt
                emojieSelectedAt = indexPath.row
                if previousEmojiWas != emojieSelectedAt {
                    guard let previousEmojiWas = previousEmojiWas else { return }
                    let previousIndexPath = IndexPath(row: previousEmojiWas, section: 0)
                    collectionView.reloadItems(at: [previousIndexPath])
                }
            }
            trackerEmoji = trackerCardViewController.emojies[indexPath.row]
        cell.changeCellBackgroundColor(color: UIColor.ypLightGray)
    }
    
    private func setSelectedColor(for indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCardCollectionViewSecondCell else {
            //assertionFailure("No cell")
            return
        }
        
        if colorSelectedAt == nil {
            previousColorWas = indexPath.row
            colorSelectedAt = indexPath.row
        } else {
            previousColorWas = colorSelectedAt
            colorSelectedAt = indexPath.row
            if previousColorWas != colorSelectedAt {
                guard let previousColorWas = previousColorWas else { return }
                let previousIndexPath = IndexPath(row: previousColorWas, section: 1)
                collectionView.reloadItems(at: [previousIndexPath])
            }
        }
        trackerColor = trackerCardViewController.colors[indexPath.row]
        cell.changeCellBackground(borderWidth: 3, alpha: 0.3)
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
        view.changeTitle(title: indexPath.section == 0 ? NSLocalizedString("trackerCard.collectionView.titles.first", comment: "Emoji title") : NSLocalizedString("trackerCard.collectionView.titles.second", comment: "Color title"))
        return view
    }
}

// MARK: - CollectionViewDelegateFlowLayout
extension TrackerEditableCardViewController: UICollectionViewDelegateFlowLayout {
    /// Set layout width and height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 6 - 5, height: 52)
    }
    /// Set layout horizontal spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
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
                height: 81
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .required)
    }
}

// MARK: - Constraints configuration
private extension TrackerEditableCardViewController {
    func titleConfig() {
        view.addSubview(titleBackground)
        NSLayoutConstraint.activate([
            titleBackground.topAnchor.constraint(equalTo: view.topAnchor),
            titleBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleBackground.heightAnchor.constraint(equalToConstant: 159)
        ])
        titleBackground.addSubview(daysCounterTextLabel)
        NSLayoutConstraint.activate([
            daysCounterTextLabel.bottomAnchor.constraint(equalTo: titleBackground.bottomAnchor, constant: -40),
            daysCounterTextLabel.leadingAnchor.constraint(equalTo: titleBackground.leadingAnchor),
            daysCounterTextLabel.trailingAnchor.constraint(equalTo: titleBackground.trailingAnchor),
            daysCounterTextLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
        titleBackground.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: daysCounterTextLabel.topAnchor, constant: -38),
            titleLabel.widthAnchor.constraint(equalToConstant: view.frame.width),
            titleLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.frame.width/2)
        ])
    }
    
    func horizontalStackViewConfig() {
        view.addSubview(horizontalStackView)
        NSLayoutConstraint.activate([
            horizontalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            horizontalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        horizontalStackView.addArrangedSubview(cancelButton)
        horizontalStackView.addArrangedSubview(saveTrackerButton)
    }
    
    func scrollViewConfig() {
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleBackground.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: horizontalStackView.topAnchor)
        ])
        
        scrollView.addSubview(contentView)
    }
    
    private func textFieldConfig() {
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32)
        ])
    }
    
    func categoryButtonConfig() {
        contentView.addSubview(categoryButton)
        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            categoryButton.heightAnchor.constraint(equalToConstant: 75)
        ])
        categoryButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        addCategoryButtonArrow()
    }
    
    func addCategoryButtonArrow() {
        categoryButton.addSubview(categoryButtonArrowImageView)
        NSLayoutConstraint.activate([
            categoryButtonArrowImageView.topAnchor.constraint(equalTo: categoryButton.centerYAnchor, constant: -12),
            categoryButtonArrowImageView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
            categoryButtonArrowImageView.heightAnchor.constraint(equalToConstant: 24),
            categoryButtonArrowImageView.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func verticalStackViewConfig() {
        contentView.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            verticalStackView.heightAnchor.constraint(equalToConstant: 150)
        ])
        verticalStackView.addArrangedSubview(categoryButton)
        verticalStackView.addArrangedSubview(scheduleButton)
        
        categoryButton.addSubview(categoryButtonArrowImageView)
        categoryButton.addSubview(buttonBottomDivider)
        NSLayoutConstraint.activate([
            categoryButtonArrowImageView.topAnchor.constraint(equalTo: categoryButton.centerYAnchor, constant: -12),
            categoryButtonArrowImageView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
            categoryButtonArrowImageView.heightAnchor.constraint(equalToConstant: 24),
            categoryButtonArrowImageView.widthAnchor.constraint(equalToConstant: 24),
            
            buttonBottomDivider.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            buttonBottomDivider.heightAnchor.constraint(equalToConstant: 0.5),
            buttonBottomDivider.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
            buttonBottomDivider.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16)
        ])
        categoryButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        scheduleButton.addSubview(scheduleButtonArrowImageView)
        NSLayoutConstraint.activate([
            scheduleButtonArrowImageView.topAnchor.constraint(equalTo: scheduleButton.centerYAnchor, constant: -12),
            scheduleButtonArrowImageView.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -16),
            scheduleButtonArrowImageView.heightAnchor.constraint(equalToConstant: 24),
            scheduleButtonArrowImageView.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - CollectionView configure
    func collectionViewConfig() {
        let bottomAnchorItem = !regularTracker ? categoryButton : verticalStackView
        /// Create collectionView with custom layout
        scrollView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: bottomAnchorItem.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        /// Make VC a dataSource of collectionView, to config Cell
        collectionView.dataSource = self
        /// Register Cells
        collectionView.register(TrackerCardCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(TrackerCardCollectionViewSecondCell.self, forCellWithReuseIdentifier: secondCellIdentifier)
        /// Disable scroll
        collectionView.isScrollEnabled = false
        /// Make VC a delegate of collectionView, to config Header and Footer
        collectionView.delegate = self
        /// Register Header
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        /// disable multiple selection
        collectionView.allowsMultipleSelection = false
    }
}

