import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class CartProductXIB: UITableViewCell {
    
    var cartItem: CartItemModel?
    
    @IBOutlet weak var cartproductImage: UIImageView!
    @IBOutlet weak var cartproductTitle: UILabel!
    @IBOutlet weak var cartproductSize: UILabel!
    @IBOutlet weak var cartproductPrice: UILabel!
    @IBOutlet weak var minusProduct: UIButton!
    @IBOutlet weak var countProduct: UILabel!
    @IBOutlet weak var plusProduct: UIButton!
    
    private var productCount: Int = 1 {
        didSet {
            countProduct.text = "\(productCount)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        cartproductImage.layer.cornerRadius = 12
        productCount = cartItem?.quantity ?? 1
        displayCartItemDetails()
        
    }
    
    private func displayCartItemDetails() {
        cartproductTitle.text = cartItem?.title
        cartproductSize.text = cartItem?.size
        cartproductPrice.text = cartItem?.price
        if let imageUrlString = cartItem?.image, let imageUrl = URL(string: imageUrlString) {
            cartproductImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
        } else {
            cartproductImage.image = UIImage(named: "placeholder")
        }
        countProduct.text = "\(productCount)"
    }
}
