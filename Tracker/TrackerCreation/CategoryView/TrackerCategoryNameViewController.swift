import UIKit

protocol TrackerCategoryNameViewControllerDelegate: AnyObject {
    func sendCategoryNameToTrackerCategoryViewController(categoryName: String)
}

final class TrackerCategoryNameViewController: UIViewController {
    
    weak var delegate: TrackerCategoryNameViewControllerDelegate?
    
    private var newCategoryName: String = ""
    
    private var currentCategoriesNames: [String]
    
    init(currentCategoriesNames: [String]) {
        self.currentCategoriesNames = currentCategoriesNames
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
        label.text = "New category"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var textField: UITextField = {
        let textField = TextFieldWithPadding()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: "YP LightGrey")?.withAlphaComponent(0.3)
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Enter category name"
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
        button.setTitle("OK", for: .normal)
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
        textField.delegate = self
        createNewCategoryButtonConfig()
        createNewCategoryButtonIsActive(newCategoryName.count > 0)
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Objective-C functions
    @objc
    func didTapCreateNewCategoryButton() {
        self.delegate?.sendCategoryNameToTrackerCategoryViewController(categoryName: newCategoryName)
    }
}

// MARK: - UITextFieldDelegate
extension TrackerCategoryNameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        guard let updatedString = updatedString else { return false }
        newCategoryName = updatedString
        createNewCategoryButtonIsActive(newCategoryName.count > 0 && !currentCategoriesNames.contains(newCategoryName))
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

