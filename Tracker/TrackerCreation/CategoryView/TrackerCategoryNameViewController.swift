import UIKit

protocol TrackerCategoryNameViewControllerDelegate: AnyObject {
    func dismissTrackerCategoryNameViewController()
}

final class TrackerCategoryNameViewController: UIViewController {
    
    // MARK: - Properties for CoreData
    private let trackerCategoryStore = TrackerCategoryStore()
    
    // MARK: - Properties
    weak var delegate: TrackerCategoryNameViewControllerDelegate?
    
    private var newCategoryName: String = ""
    
    // MARK: - Mutable properties:
    
    private var titleBackground: UIView = {
        var background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        return background
    }()
    
    var titleLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("trackerCategoryName.title", comment: "Category title")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var textField: UITextField = {
        let textField = TextFieldWithPadding()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: "YP LightGrey")?.withAlphaComponent(0.3)
        textField.placeholder = NSLocalizedString("trackerCategoryName.textField.placeholder", comment: "TextField placeholder")

        textField.clearButtonMode = .whileEditing
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        return textField
    }()
    
    private lazy var createNewCategoryButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapCreateNewCategoryButton)
        )
        button.setTitle( NSLocalizedString("createNewCategoryButton", comment: "Category creation button title"), for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.backgroundColor = UIColor(named: "YP Black")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toggleAppearance(isDark: TabBarController().isDark)
        view.backgroundColor = UIColor(named: "YP White")
        titleConfig()
        textFieldConfig()
        hideKeyboardWhenTappedAround()
        textField.delegate = self
        createNewCategoryButtonConfig()
        createNewCategoryButtonIsActive(newCategoryName.count > 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Objective-C functions
    @objc
    func didTapCreateNewCategoryButton() {
        let newCategory = TrackerCategory(name: newCategoryName, trackers: [])
        try? trackerCategoryStore.addNewTrackerCategory(newCategory)
        self.delegate?.dismissTrackerCategoryNameViewController()
    }
}

// MARK: - UITextFieldDelegate
extension TrackerCategoryNameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        guard let updatedString = updatedString else { return false }
        newCategoryName = updatedString
        createNewCategoryButtonIsActive(newCategoryName.count > 0)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        createNewCategoryButtonIsActive(false)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createNewCategoryButtonIsActive(newCategoryName.count > 0)
        textField.endEditing(true)
        return true
    }
    
    func createNewCategoryButtonIsActive(_ bool: Bool) {
        if bool {
            createNewCategoryButton.isEnabled = true
            createNewCategoryButton.backgroundColor = UIColor(named: "YP Black")
        } else {
            createNewCategoryButton.isEnabled = false
            createNewCategoryButton.backgroundColor = UIColor(named: "YP Grey")
        }
    }
}

extension TrackerCategoryNameViewController {
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
    
    func textFieldConfig() {
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleBackground.bottomAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32)
        ])
    }
    
    func createNewCategoryButtonConfig() {
        view.addSubview(createNewCategoryButton)
        NSLayoutConstraint.activate([
            createNewCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            createNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createNewCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

