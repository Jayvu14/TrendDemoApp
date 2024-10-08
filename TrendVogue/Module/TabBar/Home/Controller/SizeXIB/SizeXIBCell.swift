import UIKit

class SizeXIBCell: UICollectionViewCell {
    
    @IBOutlet weak var cloathsizeView: UIView!
    @IBOutlet weak var cloathsizeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        cloathsizeView.layer.cornerRadius = 8
        cloathsizeView.layer.borderWidth = 1
        cloathsizeView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
