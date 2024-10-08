import Foundation
import UIKit

extension UIView {
    func setUiView(radius: CGFloat, bordercolor: CGColor, borderwidth: CGFloat, kbackgroundcolor: CGColor) {
        self.layer.cornerRadius = radius
        self.layer.borderColor = bordercolor
        self.layer.borderWidth = borderwidth
        self.layer.backgroundColor = kbackgroundcolor
    }
}
