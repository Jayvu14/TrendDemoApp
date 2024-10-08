import Foundation
import UIKit

extension UIFont{
    func calculateDynamicFontSize(baseFontSize: CGFloat) -> UIFont {
        let screenWidth = UIScreen.main.bounds.width
        let baseWidth: CGFloat = 375.0
        let scaleFactor = screenWidth / baseWidth
        let newFontSize = baseFontSize * scaleFactor
        let preferredFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: newFontSize))
        return preferredFont
    }
}


