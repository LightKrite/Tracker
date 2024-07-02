import UIKit

final class TrackerCardCollectionViewCell: UICollectionViewCell {
    
    private let cellBackgroundRound: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cellEmojiLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 38)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(named: "YP White")
        addSubviews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        indexPath: IndexPath,
        emojiLabel: String,
        backgroundColor: UIColor
    ) {
        self.cellEmojiLabel.text = emojiLabel
        self.indexPath = indexPath
        self.cellBackgroundRound.backgroundColor = backgroundColor
    }
    
    func changeCellBackgroundColor(color: UIColor) {
        cellBackgroundRound.backgroundColor = color
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Configure Constraints
    private func addSubviews() {
        addSubview(cellBackgroundRound)
        addSubview(cellEmojiLabel)
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            cellBackgroundRound.widthAnchor.constraint(equalToConstant: 52),
            cellBackgroundRound.heightAnchor.constraint(equalToConstant: 52),
            cellBackgroundRound.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellBackgroundRound.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            cellEmojiLabel.widthAnchor.constraint(equalToConstant: 52),
            cellEmojiLabel.leadingAnchor.constraint(equalTo: cellBackgroundRound.centerXAnchor, constant: -26),
            cellEmojiLabel.heightAnchor.constraint(equalToConstant: 52),
            cellEmojiLabel.topAnchor.constraint(equalTo: cellBackgroundRound.centerYAnchor, constant: -26)
        ])
    }
}
