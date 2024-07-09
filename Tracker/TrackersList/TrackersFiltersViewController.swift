import UIKit

protocol TrackersFiltersViewControllerDelegate: AnyObject {
    func sendSelectedFilterToTrackersListViewController(selectedFilterRow: Int)
}

final class TrackersFiltersViewController: UIViewController {
    
    private let analyticsService = AnalyticsService()
    
    // MARK: - Delegate property:
    weak var delegate: TrackersFiltersViewControllerDelegate?
    
    // MARK: - Mutable properties:
    private let titleBackground: UIView = {
        var background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        return background
    }()
    
    private let titleLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("trackerFilters.titleLabel", comment: "Category")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.allowsMultipleSelection = false
        table.isScrollEnabled = true
        table.allowsSelection = true
        
        table.separatorColor = UIColor.ypLightGray.withAlphaComponent(0.3)
        table.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        return table
    }()
    
    private var cornersArray: [CACornerMask] = []
    private var alpha: [CGFloat] = []
    
    private var filtersNames: [String] = [
        "trackerFilters.all".localized(),
        "trackerFilters.forToday".localized(),
        "trackerFilters.completed".localized(),
        "trackerFilters.uncompleted".localized()
    ]
    private var selectedFilterRow: Int
    
    private var selectionArray: [CGFloat] = [] { didSet { tableView.reloadData() } }
    
    init(selectedFilterRow: Int) {
        self.selectedFilterRow = selectedFilterRow
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
        computeTableViewStyle()
        tableViewConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.viewWillAppear(on: AnalyticsScreens.filters.rawValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.viewWillDisappear(from: AnalyticsScreens.filters.rawValue)
    }
    
    private func computeTableViewStyle() {
        /// create and change selectionArray for selection of category button
        var selectionArray = self.selectionArray
        if selectionArray.count == 0 && filtersNames.count > 0 {
            for _ in 0 ..< filtersNames.count {
                selectionArray.append(0)
            }
        } else {
            selectionArray.append(0)
        }
        selectionArray.remove(at: selectedFilterRow)
        selectionArray.insert(1.0, at: selectedFilterRow)
        self.selectionArray = selectionArray
        cornersArray = getCornersArray(categoriesCount: filtersNames.count)
    }
    
    private func getCornersArray(categoriesCount: Int) -> [CACornerMask] {
        /// switch corners of category button depending on array.count
        let allCornersArray: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        let firstCellCornersArray: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let lastCellCornersArray: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        switch categoriesCount {
        case 0:
            alpha = [0]
            return []
        case 1:
            alpha = [0]
            return [allCornersArray]
        case 2:
            alpha = [1.0,0]
            return [firstCellCornersArray, lastCellCornersArray]
        default:
            var combineArray: [CACornerMask] = [firstCellCornersArray]
            var alphaArray: [CGFloat] = [1.0]
            for _ in 0 ..< (filtersNames.count-2) {
                let emptyArray: CACornerMask = []
                combineArray.append(emptyArray)
                alphaArray.append(1.0)
            }
            combineArray.append(lastCellCornersArray)
            alphaArray.append(0)
            alpha = alphaArray
            return combineArray
        }
    }
    
    private func clearTableViewSelection() {
        if let i = selectionArray.firstIndex(of: 1.0) {
            selectionArray[i] = 0
        }
    }
    
    /// if user selected category we should dismiss and send categories names and selected category to TrackerCardVC
    private func dismissTrackerCategoryViewController() {
        if let i = selectionArray.firstIndex(of: 1.0) {
            self.delegate?.sendSelectedFilterToTrackersListViewController(selectedFilterRow: i)
        }
    }
    
}

// MARK: - UITableViewDelegate
extension TrackersFiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if filtersNames.count == 0 {
            return 0
        } else {
            return 75
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clearTableViewSelection()
        selectionArray[indexPath.row] = 1.0
        dismissTrackerCategoryViewController()
    }
}

// MARK: - UITableViewDataSource
extension TrackersFiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtersNames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackerCategoryTableViewCell.reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        guard let TrackerCategoryTableViewCell = cell as? TrackerCategoryTableViewCell else {
            return UITableViewCell()
        }
        
        TrackerCategoryTableViewCell.configCell(
            at: indexPath,
            cornersArray: cornersArray,
            categoriesNames: filtersNames,
            alpha: alpha,
            selectionArray: selectionArray)
        return TrackerCategoryTableViewCell
    }
}

// MARK: - Private methods

private extension TrackersFiltersViewController {
    
    func titleConfig() {
        view.addSubview(titleBackground)
        NSLayoutConstraint.activate([
            titleBackground.topAnchor.constraint(equalTo: view.topAnchor),
            titleBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleBackground.heightAnchor.constraint(equalToConstant: 57)
        ])
        titleBackground.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: titleBackground.bottomAnchor, constant: -14),
            titleLabel.widthAnchor.constraint(equalToConstant: view.frame.width),
            titleLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.frame.width/2)
        ])
    }
    
    func tableViewConfig() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleBackground.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackerCategoryTableViewCell.self, forCellReuseIdentifier: TrackerCategoryTableViewCell.reuseIdentifier)
    }
}
