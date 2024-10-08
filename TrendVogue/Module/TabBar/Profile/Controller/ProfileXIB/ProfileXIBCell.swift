import UIKit

class ProfileXIBCell: UITableViewCell {
    
    @IBOutlet weak var functionalityImage: UIImageView!
    @IBOutlet weak var functionalityLabel: UILabel!
    @IBOutlet weak var functionalityButton: UIButton!
    
    var buttonTapAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        functionalityButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
           buttonTapAction?()
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
}
