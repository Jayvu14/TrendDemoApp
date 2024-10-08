import UIKit
import Lottie
import FirebaseAuth
import FirebaseFirestoreInternal
import Kingfisher

class CartViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var buyProduct: UIButton!
    @IBOutlet weak var noproduct: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var cartProductsTableView: UITableView!
    
    var objcartItem: [CartItemModel] = []
    var cameFromAddCart: Bool = false
    let deliveryFee: Double = 5.0
    let discount: Double = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCartItems()
        self.setupAnimation()
        cartProductsTableView.setTable(vc: self, identifier: CartProductXIB.identifier)
        backView.layer.cornerRadius = backView.frame.height / 2
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.bordercolor.cgColor
        backButton.isHidden = !cameFromAddCart
        backView.isHidden = !cameFromAddCart
    }
    
    private func fetchCartItems() {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        db.collection("carts").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching cart items: \(error.localizedDescription)")
                return
            }
            guard let document = document, document.exists else {
                print("No cart items found for user")
                self.noproduct.isHidden = false
                self.animationView.isHidden = false
                return
            }
            self.objcartItem.removeAll()
            for (key, value) in document.data() ?? [:] {
                if let cartData = value as? [String: Any],
                   let title = cartData["title"] as? String,
                   let size = cartData["size"] as? String,
                   let price = cartData["price"] as? String,
                   let image = cartData["image"] as? String,
                   let quantity = cartData["quantity"] as? Int {
                    let cartItem = CartItemModel(title: title, size: size, price: price, image: image, quantity: quantity)
                    self.objcartItem.append(cartItem)
                }
            }
            DispatchQueue.main.async {
                self.cartProductsTableView.reloadData()
                self.noproduct.isHidden = !self.objcartItem.isEmpty
                self.animationView.isHidden = !self.objcartItem.isEmpty
            }
        }
    }
    
    private func setupAnimation() {
            let jsonName = "lottie"
            let animation = LottieAnimation.named(jsonName)
            let animationView = LottieAnimationView(animation: animation)
            animationView.contentMode = .scaleAspectFit
            animationView.frame = self.animationView.bounds
            animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            animationView.loopMode = .loop
            animationView.play()
            self.animationView.addSubview(animationView)
        }
    
    @IBAction func backToprevious(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buyProduct(_ sender: UIButton) {
        if let navigateProceeed = CartStoryboard.instantiateViewController(withIdentifier: ProceedCheckoutViewController.identifier) as? ProceedCheckoutViewController {
            var subtotal = 0.0
            objcartItem.indices.forEach { index in
                let priceString = objcartItem[index].price
                let cleanedString = priceString.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                if let price = Double(cleanedString) {
                    subtotal = subtotal + (price * Double(objcartItem[index].quantity))
                }
            }
            let totalDiscount = subtotal * discount
            navigateProceeed.objprice =  Pricing(subtotal: subtotal, deliveryFee: deliveryFee, discount: totalDiscount, cartItems: objcartItem)
            navigateProceeed.modalTransitionStyle = .crossDissolve
            navigateProceeed.modalPresentationStyle = .overFullScreen
            self.present(navigateProceeed, animated: true, completion: nil)
            
        }
    }
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource, RemoveProductViewControllerDelegate {
    func didRemoveProduct(_ product: CartItemModel) {
        if let index = objcartItem.firstIndex(where: { $0.title == product.title }) {
            objcartItem.remove(at: index)
            cartProductsTableView.reloadData()
            removeProductFromFirestore(product)
            noproduct.isHidden = !objcartItem.isEmpty
        }
    }
    
    private func removeProductFromFirestore(_ product: CartItemModel) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        db.collection("carts").document(userId).updateData([
            product.title: FieldValue.delete()
        ]) { error in
            if let error = error {
                print("Error removing product from Firestore: \(error.localizedDescription)")
            } else {
                print("Product successfully removed from Firestore")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objcartItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let Cartcell = tableView.dequeueReusableCell(withIdentifier: CartProductXIB.identifier, for: indexPath) as? CartProductXIB {
            Cartcell.cartproductTitle.text = objcartItem[indexPath.row].title
            Cartcell.cartproductSize.text = objcartItem[indexPath.row].size
            Cartcell.cartproductPrice.text = objcartItem[indexPath.row].price
            let quantity = objcartItem[indexPath.row].quantity
            Cartcell.countProduct.text = "\(quantity)"
            let imageString = objcartItem[indexPath.row].image
            if !imageString.isEmpty, let imageUrl = URL(string: imageString) {
                Cartcell.cartproductImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
            } else {
                Cartcell.cartproductImage.image = UIImage(named: "placeholder")
            }
            Cartcell.plusProduct.tag = indexPath.row
            Cartcell.minusProduct.tag = indexPath.row
            Cartcell.plusProduct.addTarget(self, action: #selector(btnAddQuantityClicked), for: .touchUpInside)
            Cartcell.minusProduct.addTarget(self, action: #selector(btnRemoveQuantityClicked), for: .touchUpInside)
            return Cartcell
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let product = objcartItem[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "\u{1F5D1}") { (action, view, completionHandler) in
            DispatchQueue.main.async {
                self.cartProductsTableView.reloadData()
                if let removeProductVC = CartStoryboard.instantiateViewController(identifier: RemoveProdductViewController.identifier) as? RemoveProdductViewController {
                    removeProductVC.modalTransitionStyle = .crossDissolve
                    removeProductVC.modalPresentationStyle = .overFullScreen
                    removeProductVC.objremoveItem = product
                    removeProductVC.delegate = self
                    self.present(removeProductVC, animated: true, completion: nil)
                }
                completionHandler(true)
            }
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
extension CartViewController{
    @objc func btnAddQuantityClicked(_ sender:UIButton){
        let index = sender.tag
        objcartItem[index].quantity += 1
        cartProductsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        updateCartItemInFirestore(cartItem: objcartItem[index])
    }
    
    @objc func btnRemoveQuantityClicked(_ sender:UIButton){
        let index = sender.tag
        if objcartItem[index].quantity > 1 {
            objcartItem[index].quantity -= 1
            cartProductsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            updateCartItemInFirestore(cartItem: objcartItem[index])
        } else {
            let product = objcartItem[index]
            objcartItem.remove(at: index)
            cartProductsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            removeProductFromFirestore(product)
        }
        
        noproduct.isHidden = !objcartItem.isEmpty
    }
    
    private func updateCartItemInFirestore(cartItem: CartItemModel) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        
        db.collection("carts").document(userId).updateData([
            "\(cartItem.title).quantity": cartItem.quantity
        ]) { error in
            if let error = error {
                print("Error updating cart item: \(error.localizedDescription)")
            } else {
                print("Cart item updated successfully.")
            }
        }
    }
}
