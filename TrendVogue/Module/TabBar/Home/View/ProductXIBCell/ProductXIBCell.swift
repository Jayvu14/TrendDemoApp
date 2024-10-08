import UIKit

class ProductXIBCell: UICollectionViewCell {
    
    @IBOutlet weak var productshowImage: UIImageView!
    @IBOutlet weak var productshowLabel: UILabel!
    @IBOutlet weak var productshowView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        productshowView.layer.backgroundColor = UIColor.backgroundBrown.cgColor
        productshowView.layer.cornerRadius = (productshowView.frame.size.width / 2)
        
    }

}
