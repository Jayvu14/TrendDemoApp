import UIKit

class ImagesXIIBCell: UICollectionViewCell {
    
    @IBOutlet weak var imageCollection: UIImageView!
    @IBOutlet weak var moreImages: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        moreImages.isHidden = true
        imageCollection.layer.cornerRadius = 8
    }
}
