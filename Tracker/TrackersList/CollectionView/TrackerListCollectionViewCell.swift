import UIKit

protocol TrackersListCollectionViewCellDelegate: AnyObject {
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
    func completeTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackersListCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: TrackersListCollectionViewCellDelegate?
    
    let cellBackgroundSquare: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cellBackgroundRound: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cellPinnedImageView: UIImageView = {
        let image = UIImage(named: "Pinned")
        let imageView = UIImageView(image: image)
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.ypWhite
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cellEmojiLabel: UILabel = {
       var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cellTrackerLabel: UILabel = {
       var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.addInterlineSpacing(spacingValue: 6)
        label.textColor = UIColor.ypWhite
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cellPlusButton: UIButton = {
        let resizedImage = (UIImage(named: "PlusButton") ?? UIImage()).resized(to: CGSize(width: 10, height: 10))
        let button = UIButton.systemButton(
            with: resizedImage,
            target: self,
            action: #selector(didTapCellPlusButton)
        )
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        button.layer.borderWidth = 4
        button.tintColor = UIColor.ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cellDaysCounterLabel: UILabel = {
       var label = UILabel()
        label.text = "0 days"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.ypWhite
        cellBackgroundRound.backgroundColor = UIColor.ypWhite
        cellBackgroundRound.alpha = 0.3
        addSubviews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath,
        isPinned: Bool,
        isDark: Bool
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        cellTrackerLabel.text = tracker.name
        cellEmojiLabel.text = tracker.emoji
        cellBackgroundSquare.backgroundColor = tracker.color
        cellPlusButton.backgroundColor = tracker.color
        cellPlusButton.alpha = isCompletedToday ? 0.7 : 1
        cellPlusButton.layer.borderColor = UIColor.ypWhite.cgColor
        cellPinnedImageView.alpha = isPinned ? 1 : 0
        
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of completed days"),
            completedDays
        )
        
        cellDaysCounterLabel.text = daysString
        
        changeCellPlussButtonImage(changeValue: isCompletedToday)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @objc
    func didTapCellPlusButton() {
        guard
            let trackerId = trackerId,
                let indexPath = indexPath
        else { return }
        if isCompletedToday {
            self.delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            self.delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
    
    private func changeCellPlussButtonImage(changeValue: Bool) {
        if changeValue {
            let resizedImage = (UIImage(named: "Checkmark") ?? UIImage()).resized(to: CGSize(width: 10, height: 10))
            cellPlusButton.setImage(resizedImage, for: .normal)
        } else {
            let resizedImage = (UIImage(named: "PlusButton") ?? UIImage()).resized(to: CGSize(width: 10, height: 10))
            cellPlusButton.setImage(resizedImage, for: .normal)
        }
    }
    
    
    // MARK: - Configure Constraints
    private func addSubviews() {
        addSubview(cellBackgroundSquare)
        addSubview(cellPlusButton)
        addSubview(cellDaysCounterLabel)
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            cellBackgroundSquare.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            cellBackgroundSquare.heightAnchor.constraint(equalToConstant: 90),
            cellBackgroundSquare.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellBackgroundSquare.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellBackgroundSquare.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        configureInsideElements(
            backgroundView: cellBackgroundSquare,
            roundView: cellBackgroundRound,
            emojiLabel: cellEmojiLabel,
            trackerLabel: cellTrackerLabel,
            pinnedImageViw: cellPinnedImageView
        )
        
        configureOutsideElements(backgroundView: cellBackgroundSquare)
        
    }
    
    func configureInsideElements(backgroundView: UIView, roundView: UIView, emojiLabel: UILabel, trackerLabel: UILabel, pinnedImageViw: UIImageView) {
        
        backgroundView.addSubview(roundView)
        backgroundView.addSubview(emojiLabel)
        backgroundView.addSubview(trackerLabel)
        backgroundView.addSubview(pinnedImageViw)
        
        NSLayoutConstraint.activate([
            roundView.widthAnchor.constraint(equalToConstant: 24),
            roundView.heightAnchor.constraint(equalToConstant: 24),
            roundView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
            roundView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 12),

            emojiLabel.widthAnchor.constraint(equalToConstant: 16),
            emojiLabel.leadingAnchor.constraint(equalTo: roundView.centerXAnchor, constant: -8),
            emojiLabel.heightAnchor.constraint(equalToConstant: 22),
            emojiLabel.topAnchor.constraint(equalTo: roundView.centerYAnchor, constant: -11),
            
            trackerLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -12),
            trackerLabel.topAnchor.constraint(equalTo: roundView.bottomAnchor, constant: 8),
            
            pinnedImageViw.widthAnchor.constraint(equalToConstant: 24),
            pinnedImageViw.heightAnchor.constraint(equalToConstant: 24),
            pinnedImageViw.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
            pinnedImageViw.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -4)
        ])
    }
    
    private func configureOutsideElements(backgroundView: UIView) {
        NSLayoutConstraint.activate([
            cellPlusButton.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 4),
            cellPlusButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
            cellPlusButton.widthAnchor.constraint(equalToConstant: 42),
            cellPlusButton.heightAnchor.constraint(equalToConstant: 42),
            
            cellDaysCounterLabel.leadingAnchor.constraint(equalTo: cellBackgroundRound.leadingAnchor),
            cellDaysCounterLabel.centerYAnchor.constraint(equalTo: cellPlusButton.centerYAnchor)
        ])
    }
    
    
}
