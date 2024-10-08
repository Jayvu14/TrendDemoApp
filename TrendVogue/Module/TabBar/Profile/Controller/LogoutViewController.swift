import UIKit

class LogoutViewController: UIViewController {
    
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var cancelBack: UIButton!
    @IBOutlet weak var cancelButtton: UIButton!
    @IBOutlet weak var logoutButtton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .init(white: 0.1, alpha: 0.6)
        self.navigationController?.navigationBar.isHidden = true
        logoutView.layer.cornerRadius = 15
        cancelButtton.layer.cornerRadius = cancelButtton.frame.height / 2
        cancelButtton.layer.borderColor = UIColor.backgoundUIcolour.cgColor
        cancelButtton.layer.borderWidth = 2
        logoutButtton.layer.cornerRadius = logoutButtton.frame.height / 2
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        performLogout()
    }
    
    private func performLogout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        self.navigateToSignIn()
    }
    
    private func navigateToSignIn() {
        guard let signInVC = authenticationStoryboard.instantiateViewController(withIdentifier: SigninViewController.identifier) as? SigninViewController else { return }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let nav = UINavigationController(rootViewController: signInVC)
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
    
    @IBAction func cancelbackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

