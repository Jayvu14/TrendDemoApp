import UIKit

class OrderPlacedViewController: UIViewController {
    
    @IBOutlet weak var viewOrderView: UIView!
    @IBOutlet weak var viewOrderButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewOrderView.layer.cornerRadius = 20
        viewOrderButton.layer.cornerRadius = viewOrderButton.frame.height / 2
    }
    
    @IBAction func orderViewTapped(_ sender: UIButton) {
        if let backToHome = customTabBarStoryboard.instantiateViewController(withIdentifier: CustomTabBarViewController.identifier) as? CustomTabBarViewController {
            navigationController?.pushViewController(backToHome, animated: true)
        }
    }
}
