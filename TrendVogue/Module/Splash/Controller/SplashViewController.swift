import UIKit

class SplashViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var fLabel: UILabel!
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        fLabel.layer.cornerRadius = fLabel.frame.height / 2
        self.initialSetup()
    }
}

//MARK: - Custom Functions
extension SplashViewController {
    private func initialSetup() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            // Check if the user is logged in
            let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            
            if isLoggedIn {
                // User is logged in, navigate to home
                self.navigateToHome()
            } else {
                // User is not logged in, navigate to login
                self.navigateToLogin()
            }
        }
    }
    
    private func navigateToHome() {
        if let navigate = customTabBarStoryboard.instantiateViewController(withIdentifier: CustomTabBarViewController.identifier) as? CustomTabBarViewController {
            let navController = UINavigationController(rootViewController: navigate)
            self.setRootViewController(navController)
        }
    }
    
    private func navigateToLogin() {
        if let navigate = authenticationStoryboard.instantiateViewController(withIdentifier: SigninViewController.identifier) as? SigninViewController {
            let navController = UINavigationController(rootViewController: navigate)
            self.setRootViewController(navController)
        }
    }

    private func setRootViewController(_ viewController: UINavigationController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return }
        viewController.setNavigationBarHidden(true, animated: false)
        delegate.window = UIWindow(windowScene: windowScene)
        delegate.window?.rootViewController = viewController
        
        delegate.window?.makeKeyAndVisible()
    }
}
