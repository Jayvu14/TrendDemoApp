import UIKit

class ProductShowXib: UICollectionViewCell {
    
    @IBOutlet weak var prroductView: UIView!
    @IBOutlet weak var likedislikeView: UIView!
    @IBOutlet weak var likedislikeButton: UIButton!
    @IBOutlet weak var productImages: UIImageView!
    @IBOutlet weak var productTittle: UILabel!
    @IBOutlet weak var productRatings: UIButton!
    @IBOutlet weak var productPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        likedislikeView.layer.cornerRadius = likedislikeView.frame.height / 2
        prroductView.layer.cornerRadius = 20
        productImages.layer.cornerRadius = 20
        
    }
}
