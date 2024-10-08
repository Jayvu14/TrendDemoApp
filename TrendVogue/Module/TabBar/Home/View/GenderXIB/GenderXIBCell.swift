import UIKit

class GenderXIBCell: UICollectionViewCell {
    
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var genderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        genderView.layer.cornerRadius = 20
        genderView.layer.borderWidth = 1
        genderView.layer.borderColor = UIColor.bordercolor.cgColor
        
    }

}
