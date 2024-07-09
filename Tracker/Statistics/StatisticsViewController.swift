import UIKit

final class StatisticsViewController: UIViewController {
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let analyticsService = AnalyticsService()

    private let emptyStatisticsImageView: UIImageView = {
        var image = UIImage(named: "StatisticsEmpty")
        var imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStatisticsLabel: UILabel = {
       var label = UILabel()
        label.text = NSLocalizedString("emptyStatisticsLabel", comment: "Nothing to analize")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let navBar: UINavigationBar = {
        var bar = UINavigationBar()
        bar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 182)
        return bar
    }()
    
    private var statisticsLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("statisticsLabel", comment: "Statistics Label")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var firstGradientView: UIView = createUIViewForGradient()
    private lazy var firstCounterLabel: UILabel = createCounterLabel()
    private lazy var firstInfoLabel: UILabel = createInfoLabel()
    
    private lazy var secondGradientView: UIView = createUIViewForGradient()
    private lazy var secondCounterLabel: UILabel = createCounterLabel()
    private lazy var secondInfoLabel: UILabel = createInfoLabel()
    
    private lazy var thirdGradientView: UIView = createUIViewForGradient()
    private lazy var thirdCounterLabel: UILabel = createCounterLabel()
    private lazy var thirdInfoLabel: UILabel = createInfoLabel()
    
    private lazy var fourthGradientView: UIView = createUIViewForGradient()
    private lazy var fourthCounterLabel: UILabel = createCounterLabel()
    private lazy var fourthInfoLabel: UILabel = createInfoLabel()
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(String(describing: type(of: self)), forKey: "LastViewController")
        self.accessibilityLabel = "StatisticsViewController"
        // NavBar
        view.addSubview(navBar)
        
        // StatisticsLabel
        navBar.addSubview(statisticsLabel)
        NSLayoutConstraint.activate([
            statisticsLabel.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -53),
            statisticsLabel.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 16)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.viewWillAppear(on: AnalyticsScreens.statistics.rawValue)
        if trackerStore.trackers.count == 0 {
            verticalStackView.removeFromSuperview()
            showEmptyStatisticsInfo()
        } else {
            hideEmptyStatisticsInfo()
            verticalStackViewConfig()
            configureTextForLabels()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstGradientView.addGradientBorder(colors: [UIColor.red, UIColor.green, UIColor.blue], width: 1)
        secondGradientView.addGradientBorder(colors: [UIColor.red, UIColor.green, UIColor.blue], width: 1)
        thirdGradientView.addGradientBorder(colors: [UIColor.red, UIColor.green, UIColor.blue], width: 1)
        fourthGradientView.addGradientBorder(colors: [UIColor.red, UIColor.green, UIColor.blue], width: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.viewWillDisappear(from: AnalyticsScreens.filters.rawValue)
    }
    
    private func configureTextForLabels() {
        firstInfoLabel.text = NSLocalizedString("statistics.firstInfoLabel", comment: "Best period")
        secondInfoLabel.text = NSLocalizedString("statistics.secondInfoLabel", comment: "Ideal days")
        thirdInfoLabel.text = NSLocalizedString("statistics.thirdInfoLabel", comment: "Trackers completed")
        fourthInfoLabel.text = NSLocalizedString("statistics.fourthInfoLabel", comment: "Average value")
        
        thirdCounterLabel.text = "\(trackerRecordStore.completedTrackers.count)"
        
        
    }
    
    private func createUIViewForGradient() -> UIView {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func createCounterLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.ypBlack
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        return label
    }
    
    private func createInfoLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.ypBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Info text for replace"
        return label
    }
    
    // MARK: - Configure constraints
    private func showEmptyStatisticsInfo() {
        view.addSubview(emptyStatisticsLabel)
        view.addSubview(emptyStatisticsImageView)
        NSLayoutConstraint.activate([
            emptyStatisticsImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -40),
            emptyStatisticsImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -40),
            emptyStatisticsLabel.topAnchor.constraint(equalTo: emptyStatisticsImageView.bottomAnchor, constant: 8),
            emptyStatisticsLabel.widthAnchor.constraint(equalToConstant: 343),
            emptyStatisticsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -171.5)
        ])
    }
    
    private func hideEmptyStatisticsInfo() {
        emptyStatisticsLabel.removeFromSuperview()
        emptyStatisticsImageView.removeFromSuperview()
    }
    
    private func verticalStackViewConfig() {
        view.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            verticalStackView.heightAnchor.constraint(equalToConstant: 396)
        ])
        verticalStackView.addArrangedSubview(firstGradientView)
        verticalStackView.addArrangedSubview(secondGradientView)
        verticalStackView.addArrangedSubview(thirdGradientView)
        verticalStackView.addArrangedSubview(fourthGradientView)
        NSLayoutConstraint.activate([
            firstGradientView.heightAnchor.constraint(equalToConstant: 90),
            secondGradientView.heightAnchor.constraint(equalToConstant: 90),
            thirdGradientView.heightAnchor.constraint(equalToConstant: 90),
            fourthGradientView.heightAnchor.constraint(equalToConstant: 90)
        ])
        configureLabels(inside: firstGradientView, counterLabel: firstCounterLabel, infoLabel: firstInfoLabel)
        configureLabels(inside: secondGradientView, counterLabel: secondCounterLabel, infoLabel: secondInfoLabel)
        configureLabels(inside: thirdGradientView, counterLabel: thirdCounterLabel, infoLabel: thirdInfoLabel)
        configureLabels(inside: fourthGradientView, counterLabel: fourthCounterLabel, infoLabel: fourthInfoLabel)
    }
    
    private func configureLabels(inside gradientView: UIView, counterLabel: UILabel, infoLabel: UILabel) {
        gradientView.addSubview(counterLabel)
        gradientView.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 12),
            counterLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -12),
            counterLabel.heightAnchor.constraint(equalToConstant: 41),
            
            infoLabel.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 7),
            infoLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 12),
            infoLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -12),
            infoLabel.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
    
}
