import UIKit
import FirebaseFirestoreInternal
import FirebaseAuth

class ProceedCheckoutViewController: UIViewController {
    
    @IBOutlet weak var proceedcheckoutView: UIView!
    @IBOutlet weak var promocodeView: UIView!
    @IBOutlet weak var promocodeTextField: UITextField!
    @IBOutlet weak var promocodeButton: UIButton!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var diliveryFeeLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var totalcostLabel: UILabel!
    @IBOutlet weak var procedcheckoutButton: UIButton!
    
    var objprice: Pricing?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .init(white: 0.1, alpha: 0.6)
        promocodeView.layer.cornerRadius = promocodeView.frame.height / 2
        promocodeView.layer.borderWidth = 1
        promocodeView.layer.borderColor = UIColor.bordercolor.cgColor
        promocodeButton.layer.cornerRadius = promocodeButton.frame.height / 2
        proceedcheckoutView.layer.cornerRadius = 20
        procedcheckoutButton.layer.cornerRadius = procedcheckoutButton.frame.height / 2
        
        
        subTotalLabel.text = String(format: "$%.2f", objprice?.subtotal ?? 0.0)
        diliveryFeeLabel.text = String(format: "$%.2f", objprice?.deliveryFee ?? 0.0)
        discountLabel.text = String(format: "-$%.2f", objprice?.discount ?? 0.0)
        totalcostLabel.text = String(format: "$%.2f", objprice?.totalCost ?? 0.0)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func procedcheckoutTapped(_ sender: UIButton) {
        saveOrderToFirestore { success in
            if success {
                self.clearCartInFirestore { cleared in
                    if cleared {
                        if let orderplace = CartStoryboard.instantiateViewController(withIdentifier: OrderPlacedViewController.identifier) as? OrderPlacedViewController {
                            NotificationHelper.shared.sendNotification(title: "Congratulation you buy Product Sucessfully.", body: "Your Total Amount of \(self.totalcostLabel.text ?? "") and within 2 days.")
                            let nav = UINavigationController(rootViewController: orderplace)
                            nav.setNavigationBarHidden(true, animated: false)
                            nav.modalTransitionStyle = .crossDissolve
                            nav.modalPresentationStyle = .fullScreen
                            self.present(nav, animated: true, completion: nil)
                        }
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Failed to place the order. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    private func clearCartInFirestore(completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        db.collection("carts").document(userId).delete { error in
            if let error = error {
                print("Error clearing cart: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Cart cleared successfully!")
                completion(true)
            }
        }
    }

    private func saveOrderToFirestore(completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        let cartItemsDict = objprice?.cartItems.map { $0.toDictionary() } ?? []
        let orderData: [String: Any] = [
            "subtotal": objprice?.subtotal ?? 0.0,
            "deliveryFee": objprice?.deliveryFee ?? 0.0,
            "discount": objprice?.discount ?? 0.0,
            "totalCost": objprice?.totalCost ?? 0.0,
            "cartItems": cartItemsDict
        ]
        db.collection("orders").document(userId).setData(orderData) { error in
            if let error = error {
                print("Error saving order: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Order successfully saved!")
                completion(true)
            }
        }
    }
}
