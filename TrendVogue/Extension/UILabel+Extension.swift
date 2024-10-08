import Foundation
import UIKit

extension UILabel {
    func setLabel(labelText: String, labelColour: UIColor, labelSize: UIFont) {
        self.text = labelText
        self.textColor = labelColour
        self.font = labelSize
    }
}
