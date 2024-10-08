import UIKit

class PageControlCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var bannnerrView: UIView!

    //MARK: - Override Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        bannerImage.layer.cornerRadius = 20
        bannnerrView.layer.cornerRadius = 20
    }
}

//MARK: - Custom Functions
extension PageControlCollectionViewCell {
    func configureCell(showImage: String) {
        self.bannerImage.image = UIImage(named: showImage)
    }
}
