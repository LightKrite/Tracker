import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        if UserDefaults.standard.isNotFirstRun {
            window.rootViewController = TabBarController()
        } else {
            window.rootViewController = OnboardingViewController()
        }
        self.window = window
        window.makeKeyAndVisible()
        
        
    }
}

