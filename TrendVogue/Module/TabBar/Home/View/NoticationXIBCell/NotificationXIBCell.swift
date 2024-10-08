import UIKit

class NotificationXIBCell: UITableViewCell {
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationTittle: UILabel!
    @IBOutlet weak var notificationSizeQuantity: UILabel!
    @IBOutlet weak var notificattionPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        notificationView.layer.cornerRadius = 10
        notificationView.layer.borderWidth = 1
        notificationView.layer.borderColor = UIColor.bordercolor.cgColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
