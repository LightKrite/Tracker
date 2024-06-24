import UIKit

// MARK: - TrackerScheduleViewControllerDelegate
protocol TrackerScheduleViewControllerDelegate: AnyObject {
    func sendArray(array: [WeekDay])
}

// MARK: - TrackerScheduleViewController
final class TrackerScheduleViewController: UIViewController {
    
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
    
    var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Schedule"
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
        table.separatorColor = UIColor(named: "YP LightGrey")?.withAlphaComponent(0.3)
        table.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        return table
    }()
    
    private lazy var acceptScheduleButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapAcceptScheduleButton)
        )
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.backgroundColor = UIColor(named: "YP Black")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP White")
        titleConfig()
        acceptScheduleButtonConfig()
        tableViewConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Objective-C functions
    
    @objc
    func didTapAcceptScheduleButton() {
        self.delegate?.sendArray(array: newWeekDaysNamesArray)
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
        let cellViewModel = TrackerScheduleTableViewCellViewModel(
            scheduleView: TrackerScheduleTableViewCell.scheduleView,
            scheduleSwitch: TrackerScheduleTableViewCell.scheduleSwitch,
            scheduleLabel: TrackerScheduleTableViewCell.scheduleLabel,
            scheduleFooterView:
                TrackerScheduleTableViewCell.scheduleFooterView)
        configCell(at: indexPath, cell: cellViewModel)
        return TrackerScheduleTableViewCell
    }
    func configCell(at indexPath: IndexPath, cell: TrackerScheduleTableViewCellViewModel) {
        let items = TrackerScheduleTableViewCellViewModel(
            scheduleView: cell.scheduleView,
            scheduleSwitch: cell.scheduleSwitch,
            scheduleLabel: cell.scheduleLabel,
            scheduleFooterView: cell.scheduleFooterView)
        let cornersArray: [CACornerMask] = [[.layerMinXMinYCorner, .layerMaxXMinYCorner],[],[],[],[],[],[.layerMinXMaxYCorner, .layerMaxXMaxYCorner]]
        items.scheduleView.layer.maskedCorners = cornersArray[indexPath.row]
        let daysArray: [WeekDay] = WeekDay.allCases
        items.scheduleLabel.text = daysArray[indexPath.row].rawValue
        items.scheduleSwitch.isOn = (newWeekDaysNamesArray[indexPath.row] != .empty)
        let alpha = [1.0,1.0,1.0,1.0,1.0,1.0,0]
        items.scheduleFooterView.alpha = alpha[indexPath.row]
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

// MARK: - TrackerScheduleTableViewCellDelegate (protocol)
protocol TrackerScheduleTableViewCellDelegate: AnyObject {
    func TrackerScheduleTableViewCellSwitchDidChange(_ cell: TrackerScheduleTableViewCell)
}

// MARK: - TrackerScheduleTableViewCell
final class TrackerScheduleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TrackerScheduleTableViewCell"
    weak var delegate: TrackerScheduleTableViewCellDelegate?
    
    var scheduleView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "YP LightGrey")?.withAlphaComponent(0.3)
        return view
    }()
    
    var scheduleSwitch: UISwitch = {
        let sswitch = UISwitch()
        sswitch.setOn(false, animated: false)
        sswitch.tintColor = UIColor(named: "YP Grey")
        sswitch.onTintColor = UIColor(named: "YP Blue")
        sswitch.thumbTintColor = UIColor(named: "YP Whtite")
        sswitch.translatesAutoresizingMaskIntoConstraints = false
        return sswitch
    }()
    
    var scheduleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(named: "YP Black")
        label.text = "Monday"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var scheduleFooterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "YP Grey")
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: "YP White")
        addSubviews()
        configureConstraints()
        scheduleSwitch.addTarget(self, action: #selector(switchChanged(sender: )), for: UIControl.Event.valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func switchChanged(sender: UISwitch) {
        delegate?.TrackerScheduleTableViewCellSwitchDidChange(self)
    }
    
    func addSubviews() {
        addSubview(scheduleView)
        addSubview(scheduleFooterView)
        scheduleView.addSubview(scheduleLabel)
        contentView.addSubview(scheduleSwitch)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            scheduleView.topAnchor.constraint(equalTo: topAnchor),
            scheduleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scheduleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scheduleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scheduleLabel.heightAnchor.constraint(equalToConstant: 22),
            scheduleLabel.topAnchor.constraint(equalTo: scheduleView.centerYAnchor, constant: -11),
            scheduleLabel.leadingAnchor.constraint(equalTo: scheduleView.leadingAnchor, constant: 16),
            scheduleFooterView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scheduleFooterView.heightAnchor.constraint(equalToConstant: 0.5),
            scheduleFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            scheduleFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
        NSLayoutConstraint.activate([
            scheduleSwitch.topAnchor.constraint(equalTo: scheduleView.centerYAnchor, constant: -15.5),
            scheduleSwitch.trailingAnchor.constraint(equalTo: scheduleView.trailingAnchor, constant: -16),
            scheduleSwitch.heightAnchor.constraint(equalToConstant: 31),
            scheduleSwitch.widthAnchor.constraint(equalToConstant: 51)
        ])
    }
}

// MARK: - TrackerScheduleTableViewCellViewModel
struct TrackerScheduleTableViewCellViewModel {
    var scheduleView: UIView
    var scheduleSwitch: UISwitch
    var scheduleLabel: UILabel
    var scheduleFooterView: UIView
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

