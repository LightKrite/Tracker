import UIKit

protocol TrackerScheduleTableViewCellDelegate: AnyObject {
    func TrackerScheduleTableViewCellSwitchDidChange(_ cell: TrackerScheduleTableViewCell)
}

final class TrackerScheduleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TrackerScheduleTableViewCell"
    weak var delegate: TrackerScheduleTableViewCellDelegate?
    
    private var scheduleView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "YP LightGrey")?.withAlphaComponent(0.3)
        return view
    }()
    
    private var scheduleSwitch: UISwitch = {
        let sswitch = UISwitch()
        sswitch.setOn(false, animated: false)
        sswitch.tintColor = UIColor(named: "YP Grey")
        sswitch.onTintColor = UIColor(named: "YP Blue")
        sswitch.thumbTintColor = UIColor(named: "YP Whtite")
        sswitch.translatesAutoresizingMaskIntoConstraints = false
        return sswitch
    }()
    
    private var scheduleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(named: "YP Black")
        label.text = "Monday"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var scheduleFooterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "YP Grey")
        return view
    }()
    
    // MARK: - override init
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
    
    func configCell(
        at indexPath: IndexPath,
        array: [WeekDay]
    ) {
        let items = TrackerScheduleTableViewCellViewModel(
            scheduleView: scheduleView,
            scheduleSwitch: scheduleSwitch,
            scheduleLabel: scheduleLabel,
            scheduleFooterView: scheduleFooterView)
        let cornersArray: [CACornerMask] = [[.layerMinXMinYCorner, .layerMaxXMinYCorner],[],[],[],[],[],[.layerMinXMaxYCorner, .layerMaxXMaxYCorner]]
        items.scheduleView.layer.maskedCorners = cornersArray[indexPath.row]
        let daysArray: [WeekDay] = WeekDay.allCases
        items.scheduleLabel.text = daysArray[indexPath.row].rawValue
        items.scheduleSwitch.isOn = (array[indexPath.row] != .empty)
        let alpha = [1.0,1.0,1.0,1.0,1.0,1.0,0]
        items.scheduleFooterView.alpha = alpha[indexPath.row]
    }
    
    // MARK: - Obj-C methods
    @objc
    func switchChanged(sender: UISwitch) {
        delegate?.TrackerScheduleTableViewCellSwitchDidChange(self)
    }
    
    // MARK: - Configure constraints
    private func addSubviews() {
        addSubview(scheduleView)
        addSubview(scheduleFooterView)
        scheduleView.addSubview(scheduleLabel)
        contentView.addSubview(scheduleSwitch)
    }
    
    private func configureConstraints() {
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
