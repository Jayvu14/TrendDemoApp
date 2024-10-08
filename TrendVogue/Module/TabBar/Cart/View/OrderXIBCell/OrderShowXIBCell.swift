import UIKit

class OrderShowXIBCell: UITableViewCell {
    
    @IBOutlet weak var orderImage: UIImageView!
    @IBOutlet weak var orderTitle: UILabel!
    @IBOutlet weak var orderSizeQuantiy: UILabel!
    @IBOutlet weak var orderPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        orderImage.layer.cornerRadius = 15

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
}
