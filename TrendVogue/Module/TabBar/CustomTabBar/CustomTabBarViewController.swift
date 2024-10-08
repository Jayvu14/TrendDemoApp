import UIKit

class CustomTabBarViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var firstTabView: UIView!
    @IBOutlet weak var homeTabButton: UIButton!
    @IBOutlet weak var secondTabView: UIView!
    @IBOutlet weak var cartTabButton: UIButton!
    @IBOutlet weak var thirdTabView: UIView!
    @IBOutlet weak var likeTabButton: UIButton!
    @IBOutlet weak var fourthTabView: UIView!
    @IBOutlet weak var profileTabButton: UIButton!
    
    private var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        designableTabbar()
        contentView.backgroundColor = .clear
        displayHomeTab()
    }
    
    func designableTabbar() {
        tabBarView.layer.cornerRadius = tabBarView.frame.height / 2
        [firstTabView, secondTabView, thirdTabView, fourthTabView].forEach {
            $0?.layer.cornerRadius = ($0?.frame.height ?? 0) / 2
        }
        tabBarView.clipsToBounds = true
    }
    
    @IBAction func onClickTabBar(_ sender: UIButton) {
        resetTabBarColors()
        resetTabBarButton()
        updateTabBarColor(for: sender.tag)
        switch sender.tag {
        case 0:
            displayHomeTab()
        case 1:
            displayViewController(identifier: CartViewController.identifier, storyboard: CartStoryboard)
        case 2:
            displayViewController(identifier: LikeViewController.identifier, storyboard: LikeStoryboard)
        case 3:
            displayViewController(identifier: ProfileViewController.identifier, storyboard: ProfileStoryboard)
        default:
            break
        }
    }
    
    private func resetTabBarColors() {
        [firstTabView, secondTabView, thirdTabView, fourthTabView].forEach { tabView in
            tabView?.backgroundColor = .clear
        }
    }
    
    private func resetTabBarButton() {
        homeTabButton.setImage(UIImage(named: "home"), for: .normal)
        cartTabButton.setImage(UIImage(named: "trolley"), for: .normal)
        likeTabButton.setImage(UIImage(named: "heart"), for: .normal)
        profileTabButton.setImage(UIImage(named: "profile"), for: .normal)
    }
    
    private func updateTabBarColor(for index: Int) {
        switch index {
        case 0:
            firstTabView.backgroundColor = .white
            homeTabButton.setImage(UIImage(named: "home1"), for: .normal)
        case 1:
            secondTabView.backgroundColor = .white
            cartTabButton.setImage(UIImage(named: "trolley1"), for: .normal)
        case 2:
            thirdTabView.backgroundColor = .white
            likeTabButton.setImage(UIImage(named: "heart1"), for: .normal)
        case 3:
            fourthTabView.backgroundColor = .white
            profileTabButton.setImage(UIImage(named: "profile1"), for: .normal)
        default:
            break
        }
    }
    
    
    private func displayHomeTab() {
        displayViewController(identifier: HomeViewController.identifier, storyboard: HomeStoryboard)
        firstTabView.backgroundColor = .white
        homeTabButton.setImage(UIImage(named: "home1"), for: .normal)
    }
    
    private func displayViewController(identifier: String, storyboard: UIStoryboard) {
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
        if let newViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
            addChild(newViewController)
            newViewController.view.frame = contentView.bounds
            contentView.addSubview(newViewController.view)
            newViewController.didMove(toParent: self)
            currentViewController = newViewController
        }
    }
}
