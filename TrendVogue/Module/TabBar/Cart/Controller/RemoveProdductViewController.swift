import UIKit

protocol RemoveProductViewControllerDelegate: AnyObject {
    func didRemoveProduct(_ product: CartItemModel)
}

class RemoveProdductViewController: UIViewController {
    
    @IBOutlet weak var removeProductView: UIView!
    @IBOutlet weak var removeProductTableview: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var yesremoveButton: UIButton!
    
    weak var delegate: RemoveProductViewControllerDelegate?
    var objremoveItem: CartItemModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .init(white: 0.1, alpha: 0.6)
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.backgoundUIcolour.cgColor
        yesremoveButton.layer.cornerRadius = yesremoveButton.frame.height / 2
        removeProductView.layer.cornerRadius = 30
        removeProductTableview.setTable(vc: self, identifier: CartProductXIB.identifier)
        removeProductTableview.reloadData()
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesremoveButtonTapped(_ sender: UIButton) {
        NotificationHelper.shared.sendNotification(title: "Ohh Item Remove", body: "On Your Cart You Remove a Product")
            if let productToRemove = objremoveItem {
                delegate?.didRemoveProduct(productToRemove)
            }
            self.dismiss(animated: true, completion: nil)
        }
}
extension RemoveProdductViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objremoveItem == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let removecell = removeProductTableview.dequeueReusableCell(withIdentifier: CartProductXIB.identifier, for: indexPath) as? CartProductXIB {
            if let item = objremoveItem {
                removecell.cartproductTitle.text = item.title
                removecell.cartproductSize.text = item.size
                removecell.cartproductPrice.text = item.price
                let imageString = item.image
                if !imageString.isEmpty, let imageUrl = URL(string: imageString) {
                    removecell.cartproductImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
                } else {
                    removecell.cartproductImage.image = UIImage(named: "placeholder")
                }
            }
            return removecell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
