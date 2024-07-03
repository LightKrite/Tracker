import UIKit

protocol TrackerCategoryViewControllerDelegate: AnyObject {
    func sendSelectedCategoryNameToTrackerCard(arrayWithCategoriesNames: [String], selectedCategoryRow: Int)
}

final class TrackerCategoryViewController: UIViewController {
    
    // MARK: - MVVM property:
    private var viewModel: TrackerCategoryViewModel?
    
    // MARK: - Delegate property:
    weak var delegate: TrackerCategoryViewControllerDelegate?
    
    // MARK: - Mutable properties:
    private let titleBackground: UIView = {
        var background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        return background
    }()
    
    private let titleLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("trackerCategory.title", comment: "Category")
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
        
        table.separatorColor = UIColor(named: "YP LightGrey")?.withAlphaComponent(0.3)
        table.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        return table
    }()
    
    private lazy var addNewCategoryButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapAddNewCategoryButton)
        )
        button.setTitle(NSLocalizedString("trackerCategory.addNewCategoryButton", comment: "Add new category"), for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.backgroundColor = UIColor(named: "YP Black")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var cornersArray: [CACornerMask] = []
    private var alpha: [CGFloat] = []
    
    private var categoriesNames: [String] { didSet { computeTableViewStyle() } }
    private var selectedCategoryRow: Int?
    
    private var selectionArray: [CGFloat] = [] { didSet { tableView.reloadData() } }
    
    // MARK: - Properties for Empty Categories Page
    private let emptyCategoriesBackground: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(named: "YP White")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let emptyCategoriesImageView: UIImageView = {
        var image = UIImage(named: "TrackersEmpty")
        var imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let emptyCategoriesLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("trackerCategory.emptyCategoriesLabel", comment: "Info text if categories is empty")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(array: [String], selectedCategoryRow: Int?) {
        self.categoriesNames = array
        self.selectedCategoryRow = selectedCategoryRow
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toggleAppearance(isDark: TabBarController().isDark)
        view.backgroundColor = UIColor(named: "YP White")
        titleConfig()
        addNewCategoryButtonConfig()
        viewModel = TrackerCategoryViewModel()
        categoriesNames = getCategoriesNamesFromStore()
        
        viewModel?.$categories.bind { [weak self] _ in
            guard let self = self else { return }
            self.categoriesNames = self.getCategoriesNamesFromStore()
        }
        
        computeTableViewStyle()
        tableViewConfig()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let viewModel = viewModel else { return }
        if viewModel.categories.isEmpty {
            showEmptyCategoriesInfo()
        } else {
            hideEmptyCategoriesInfo()
        }
    }
    
    private func getCategoriesNamesFromStore() -> [String] {
        guard let viewModel = viewModel else { return [] }
        let categoriesFromStore = viewModel.getSortedCategories()
        var categoriesNamesFromStore: [String] = []
        categoriesFromStore.forEach { categoriesFromStore in
            categoriesNamesFromStore.append(categoriesFromStore.name)
        }
        return categoriesNamesFromStore
    }
    
    // MARK: - Objective-C functions
    @objc
    func didTapAddNewCategoryButton() {
        let vc = TrackerCategoryNameViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    private func computeTableViewStyle() {
        /// create and change selectionArray for selection of category button
        var selectionArray = self.selectionArray
        if selectionArray.count == 0 && categoriesNames.count > 0 {
            for _ in 0 ..< categoriesNames.count {
                selectionArray.append(0)
            }
        } else {
            selectionArray.append(0)
        }
        /// set selectedCategory if it is not nil
        if let selectedCategoryRow = selectedCategoryRow {
            selectionArray.remove(at: selectedCategoryRow)
            selectionArray.insert(1.0, at: selectedCategoryRow)
        }
        self.selectionArray = selectionArray
        
        cornersArray = getCornersArray(categoriesCount: categoriesNames.count)
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
            for _ in 0 ..< (categoriesNames.count-2) {
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
            self.delegate?.sendSelectedCategoryNameToTrackerCard(arrayWithCategoriesNames: categoriesNames, selectedCategoryRow: i)
        }
    }
    
}

// MARK: - TrackerCategoryNameViewControllerDelegate
extension TrackerCategoryViewController: TrackerCategoryNameViewControllerDelegate {
    func dismissTrackerCategoryNameViewController() {
        dismiss(animated: true, completion: { })
        clearTableViewSelection()
        hideEmptyCategoriesInfo()
    }
}

// MARK: - UITableViewDelegate
extension TrackerCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if categoriesNames.count == 0 {
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
extension TrackerCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoriesNames.count
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
            categoriesNames: categoriesNames,
            alpha: alpha,
            selectionArray: selectionArray)
        return TrackerCategoryTableViewCell
    }
}

// MARK: - Private methods

private extension TrackerCategoryViewController {
    
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
    
    func addNewCategoryButtonConfig() {
        view.addSubview(addNewCategoryButton)
        NSLayoutConstraint.activate([
            addNewCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addNewCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func tableViewConfig() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleBackground.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addNewCategoryButton.topAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackerCategoryTableViewCell.self, forCellReuseIdentifier: TrackerCategoryTableViewCell.reuseIdentifier)
    }
    
    func showEmptyCategoriesInfo() {
        view.addSubview(emptyCategoriesBackground)
        view.addSubview(emptyCategoriesImageView)
        view.addSubview(emptyCategoriesLabel)
        NSLayoutConstraint.activate([
            emptyCategoriesBackground.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            emptyCategoriesBackground.topAnchor.constraint(equalTo: titleBackground.bottomAnchor),
            emptyCategoriesBackground.widthAnchor.constraint(equalToConstant: view.frame.width),
            emptyCategoriesBackground.bottomAnchor.constraint(equalTo: addNewCategoryButton.topAnchor),
            emptyCategoriesImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -40),
            emptyCategoriesImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -40),
            emptyCategoriesLabel.topAnchor.constraint(equalTo: emptyCategoriesImageView.bottomAnchor, constant: 8),
            emptyCategoriesLabel.widthAnchor.constraint(equalToConstant: 343),
            emptyCategoriesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -171.5)
        ])
    }
    func hideEmptyCategoriesInfo() {
        emptyCategoriesBackground.removeFromSuperview()
        emptyCategoriesImageView.removeFromSuperview()
        emptyCategoriesLabel.removeFromSuperview()
    }
}
