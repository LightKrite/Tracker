import UIKit

protocol TrackerScheduleViewControllerDelegate: AnyObject {
    func sendScheduleToTrackerCardViewController(array: [WeekDay])
}

final class TrackerScheduleViewController: UIViewController {
    
    private let analyticsService = AnalyticsService()
    
    weak var delegate: TrackerScheduleViewControllerDelegate?
    
    var newWeekDaysNamesArray: [WeekDay]
    
    init(newWeekDaysNamesArray: [WeekDay]) {
        self.newWeekDaysNamesArray = newWeekDaysNamesArray
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Mutable properties:
    
    private var titleBackground: UIView = {
        var background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        return background
    }()
    
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("trackerSchedule.title", comment: "Schedule title")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.allowsMultipleSelection = false
        table.isScrollEnabled = false
        table.allowsSelection = false
        table.separatorColor = UIColor.ypLightGray.withAlphaComponent(0.3)
        table.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        return table
    }()
    
    private lazy var acceptScheduleButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapAcceptScheduleButton)
        )
        button.setTitle(NSLocalizedString("acceptScheduleButton", comment: "Accept schedule button title"), for: .normal)
        button.setTitleColor(UIColor.ypWhite, for: .normal)
        button.backgroundColor = UIColor.ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.ypWhite
        titleConfig()
        acceptScheduleButtonConfig()
        tableViewConfig()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.viewWillAppear(on: AnalyticsScreens.schedule.rawValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.viewWillDisappear(from: AnalyticsScreens.schedule.rawValue)
    }
    
    // MARK: - Objective-C functions
    @objc
    func didTapAcceptScheduleButton() {
        self.delegate?.sendScheduleToTrackerCardViewController(array: newWeekDaysNamesArray)
        dismiss(animated: true, completion: { })
    }
    
}

// MARK: - UITableViewDelegate
extension TrackerScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDataSource
extension TrackerScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackerScheduleTableViewCell.reuseIdentifier, for: indexPath)
        guard let TrackerScheduleTableViewCell = cell as? TrackerScheduleTableViewCell else {
            return UITableViewCell()
        }
        TrackerScheduleTableViewCell.delegate = self
        let localizedArray: [String] = [
            WeekDay.monday.description,
            WeekDay.tuesday.description,
            WeekDay.wednesday.description,
            WeekDay.thursday.description,
            WeekDay.friday.description,
            WeekDay.saturday.description,
            WeekDay.sunday.description,
        ]
        TrackerScheduleTableViewCell.configCell(at: indexPath, array: newWeekDaysNamesArray, localizedArray: localizedArray)
        return TrackerScheduleTableViewCell
    }
    
}

// MARK: - TrackerScheduleTableViewCellDelegate (extension)
extension TrackerScheduleViewController: TrackerScheduleTableViewCellDelegate {
    func TrackerScheduleTableViewCellSwitchDidChange(_ cell: TrackerScheduleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let currentArrayNumber = newWeekDaysNamesArray[indexPath.row]
        if currentArrayNumber != WeekDay.empty {
            newWeekDaysNamesArray[indexPath.row] = WeekDay.empty
            } else {
                switch indexPath.row {
                case 1:
                    newWeekDaysNamesArray[indexPath.row] = .tuesday
                case 2:
                    newWeekDaysNamesArray[indexPath.row] = .wednesday
                case 3:
                    newWeekDaysNamesArray[indexPath.row] = .thursday
                case 4:
                    newWeekDaysNamesArray[indexPath.row] = .friday
                case 5:
                    newWeekDaysNamesArray[indexPath.row] = .saturday
                case 6:
                    newWeekDaysNamesArray[indexPath.row] = .sunday
                default:
                    newWeekDaysNamesArray[indexPath.row] = .monday
                }
            }
    }
}

extension TrackerScheduleViewController {
    // MARK: - Constraints configuration
    
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
    
    func acceptScheduleButtonConfig() {
        view.addSubview(acceptScheduleButton)
        NSLayoutConstraint.activate([
            acceptScheduleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            acceptScheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            acceptScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            acceptScheduleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func tableViewConfig() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleBackground.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: acceptScheduleButton.topAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackerScheduleTableViewCell.self, forCellReuseIdentifier: TrackerScheduleTableViewCell.reuseIdentifier)
    }
}
