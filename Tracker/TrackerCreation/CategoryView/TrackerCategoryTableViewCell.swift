import UIKit

final class TrackerCategoryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TrackerCategoryTableViewCell"
    
    private var categoryView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "YP LightGrey")?.withAlphaComponent(0.3)
        return view
    }()
    
    private var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(named: "YP Black")
        label.text = "Monday"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var categoryFooterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "YP Grey")
        return view
    }()
    
    private var categoryCheckMark: UIImageView = {
        let image = UIImage(named: "CategoryCheckmark")
        let imageView = UIImageView(image: image)
        imageView.alpha = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - override init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: "YP White")
        addSubviews()
        configureConstraints()
    }
    
    func configCell(
        at indexPath: IndexPath,
        cornersArray: [CACornerMask],
        categoriesNames: [String],
        alpha: [CGFloat],
        selectionArray: [CGFloat]
    ) {
        let items = TrackerCategoryTableViewCellViewModel(
            categoryView: categoryView,
            categoryLabel: categoryLabel,
            categoryFooterView: categoryFooterView,
            categoryCheckMark: categoryCheckMark)
        items.categoryView.layer.maskedCorners = cornersArray[indexPath.row]
        items.categoryLabel.text = categoriesNames[indexPath.row]
        items.categoryFooterView.alpha = alpha[indexPath.row]
        items.categoryCheckMark.alpha = selectionArray[indexPath.row]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure constraints
    private func addSubviews() {
        addSubview(categoryView)
        addSubview(categoryFooterView)
        categoryView.addSubview(categoryLabel)
        categoryView.addSubview(categoryCheckMark)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            categoryView.topAnchor.constraint(equalTo: topAnchor),
            categoryView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            categoryView.bottomAnchor.constraint(equalTo: bottomAnchor),
            categoryLabel.heightAnchor.constraint(equalToConstant: 22),
            categoryLabel.topAnchor.constraint(equalTo: categoryView.centerYAnchor, constant: -11),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryView.leadingAnchor, constant: 16),
            categoryFooterView.bottomAnchor.constraint(equalTo: bottomAnchor),
            categoryFooterView.heightAnchor.constraint(equalToConstant: 0.5),
            categoryFooterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            categoryFooterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            categoryCheckMark.heightAnchor.constraint(equalToConstant: 14.19),
            categoryCheckMark.widthAnchor.constraint(equalToConstant: 14.3),
            categoryCheckMark.topAnchor.constraint(equalTo: categoryView.centerYAnchor, constant: -7.95),
            categoryCheckMark.trailingAnchor.constraint(equalTo: categoryView.trailingAnchor, constant: -20.7)
        ])
    }
}
