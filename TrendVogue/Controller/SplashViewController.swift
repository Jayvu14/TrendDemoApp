import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var fLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        fLabel.layer.cornerRadius = fLabel.frame.height / 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
           
            if let navigate =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                let navController = UINavigationController(rootViewController: navigate)
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let delegate = windowScene.delegate as? SceneDelegate else { return  }
                navController.setNavigationBarHidden(true, animated: false)
                delegate.window?.rootViewController = navController
                delegate.window?.makeKeyAndVisible()
            }
        }
    }
}
