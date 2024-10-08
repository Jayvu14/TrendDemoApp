import Foundation
import UIKit

extension UISearchBar {
    func setSearchBar(borderWidth: CGFloat, borderColor: CGColor, cornereRadius: CGFloat, backgroundColor: UIColor, leftView: UIView, placeeHolder: String, barStyle: UISearchBar.Style, textBackgroundColor: UIColor) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor
        self.layer.cornerRadius = cornereRadius
        self.backgroundColor = backgroundColor
        self.searchTextField.leftView = leftView
        self.searchTextField.placeholder = placeeHolder
        self.searchTextField.backgroundColor = textBackgroundColor
        self.searchBarStyle = barStyle
    }
}
//        if let searchBarTextField = productSearch.value(forKey: "searchField") as? UITextField {
//            // Remove the border
//            searchBarTextField.layer.borderWidth = 0
//            searchBarTextField.layer.cornerRadius = 10
//            searchBarTextField.layer.masksToBounds = true
//            searchBarTextField.backgroundColor = .white
//        }
