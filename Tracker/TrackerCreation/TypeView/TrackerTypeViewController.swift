import UIKit



// MARK: - TrackerTypeViewController
final class TrackerTypeViewController: UIViewController {
    
    weak var delegate: TrackerCardViewControllerDelegate?
    
    // MARK: - Mutable properties
    private var titleBackground: UIView = {
        var background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        return background
    }()
    
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("trackerType.title", comment: "Tracker creation title")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var regularTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapRegularTrackerButton)
        )
        button.setTitle(NSLocalizedString("regularTrackerButton", comment: "Regular button title"), for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.backgroundColor = UIColor(named: "YP Black")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var unregularTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapUnregularTrackerButton)
        )
        button.setTitle(NSLocalizedString("unregularTrackerButton", comment: "Unregular button title"), for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.backgroundColor = UIColor(named: "YP Black")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toggleAppearance(isDark: TabBarController().isDark)
        view.backgroundColor = UIColor(named: "YP White")
        titleConfig()
        stackViewConfig()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Objective-C functions
    
    
    @objc
    func didTapRegularTrackerButton() {
        regularOrUnregularTrackersChoosen(type: true)
    }
    
    @objc
    func didTapUnregularTrackerButton() {
        regularOrUnregularTrackersChoosen(type: false)
    }
    
    private func regularOrUnregularTrackersChoosen(type: Bool) {
        let vc = TrackerCardViewController()
        vc.delegate = self.delegate
        vc.regularTracker = type
        present(vc, animated: true)
    }
}

// MARK: - Constraints configuration
private extension TrackerTypeViewController {
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
    
    func stackViewConfig() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -68),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 136)
        ])
        stackView.addArrangedSubview(regularTrackerButton)
        stackView.addArrangedSubview(unregularTrackerButton)
    }
}




