import Foundation

//class PasswordToggleHelper {
//
//    static let shared = PasswordToggleHelper()
//
//    static func configurePasswordToggle(for textField: UITextField) {
//        let toggleButton = UIButton(type: .custom)
//        toggleButton.tintColor = UIColor.black
//        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
//        toggleButton.setImage(UIImage(systemName: "eye"), for: .selected)
//        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
//        toggleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        toggleButton.contentMode = .scaleAspectFit
//        textField.rightView = toggleButton
//        textField.rightViewMode = .always
//        textField.isSecureTextEntry = true
//        textField.textContentType = .none
//    }
//
//    @objc private static func togglePasswordVisibility(_ sender: UIButton) {
//        guard let textField = (sender.superview as? UITextField) else { return }
//        textField.isSecureTextEntry.toggle()
//        sender.isSelected.toggle()
//    }
//}
