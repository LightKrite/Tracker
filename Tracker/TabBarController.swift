import UIKit

final class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var selectedTabBar: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP White")
        tabBar.backgroundColor = UIColor(named: "YP White")
        tabBar.layer.borderWidth = 0.3
        tabBar.layer.borderColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1).cgColor
        tabBar.clipsToBounds = true
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let firstItem = TrackersListViewController()
        let firstItemIcon = UITabBarItem(title: NSLocalizedString("tabBar.titles.first", comment: "Trackers"), image: UIImage(named: "TabBarRecordOff"), selectedImage: UIImage(named: "TabBarRecordOn"))
        firstItem.tabBarItem = firstItemIcon
        let secondItem = StatisticsViewController()
        let secondItemIcon = UITabBarItem(title: NSLocalizedString("tabBar.titles.second", comment: "Statistics"), image: UIImage(named: "TabBarHareOff"), selectedImage: UIImage(named: "TabBarHareOn"))
        secondItem.tabBarItem = secondItemIcon
        let controllers = [firstItem, secondItem]
        viewControllers = controllers
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController.accessibilityLabel == "TrakersViewController" {
            selectedTabBar = 0
        } else {
            selectedTabBar = 1
        }
    }
    
}
