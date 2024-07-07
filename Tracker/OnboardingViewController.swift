import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private let userDefaults: UserDefaults = .standard
    
    private var firstPage: UIViewController = {
        let page = UIViewController()
        let imageView = UIImageView(image: UIImage(named: "On First"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        page.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: page.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: page.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: page.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: page.view.bottomAnchor)
        ])
        return page
    }()
    
    private var secondPage: UIViewController = {
        let page = UIViewController()
        let imageView = UIImageView(image: UIImage(named: "On Second"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        page.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: page.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: page.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: page.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: page.view.bottomAnchor)
        ])
        return page
    }()
    
    private lazy var pages: [UIViewController] = {
        return [firstPage, secondPage]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = UIColor(named: "YP Black")
        pageControl.pageIndicatorTintColor = UIColor(named: "YP Black")?.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapActionButton(sender: ))
        )
        button.setTitle(NSLocalizedString("actionButton.title", comment: "Action button title"), for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.backgroundColor = UIColor(named: "YP Black")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var mainLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(named: "YP Black")
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        configConstraints()
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        switchMainTitleText()
    }
    
    private func switchMainTitleText() {
        if pageControl.currentPage == 0 {
            mainLabel.text = NSLocalizedString("mainLabel.text.first", comment: "First info text for onboarding")
        } else {
            mainLabel.text = NSLocalizedString("mainLabel.text.second", comment: "Second info text for onboarding")
        }
    }
    
    // MARK: - Objective-C functions
    @objc
    func didTapActionButton(sender: UIButton) {
        userDefaults.isNotFirstRun = true
        setTabBarControllerAsRoot()
    }
    
    private func setTabBarControllerAsRoot() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration of switchToTabBarController") }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
}

//MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
        
        switchMainTitleText()
    }
}

// MARK: - Configure constraints
extension OnboardingViewController {
    private func configConstraints() {
        view.addSubview(mainLabel)
        view.addSubview(pageControl)
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
