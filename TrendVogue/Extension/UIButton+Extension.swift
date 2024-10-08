import Foundation
import UIKit

extension UIButton {
    func setUnderlinedTitle() {
        guard let title = title(for: .normal) else { return }
        let attributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func setButtonborder(btnTextcolor: UIColor,btnFont: UIFont,btnText: String,btnCorner: CGFloat, btnWidth: CGFloat, btnColor: CGColor, btnbackgroundcolor: CGColor) {
        self.setTitle(btnText, for: .normal)
        self.setTitleColor(btnTextcolor, for: .normal)
        self.layer.cornerRadius = btnCorner
        self.layer.borderWidth = btnWidth
        self.layer.borderColor = btnColor
        self.layer.backgroundColor = btnbackgroundcolor
        
    }
}

