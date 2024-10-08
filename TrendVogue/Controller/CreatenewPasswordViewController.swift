import UIKit

class CreatenewPasswordViewController: UIViewController {
    
    @IBOutlet weak var createNewBackBtn: UIButton!
    @IBOutlet weak var newpasswordView: UIView!
    @IBOutlet weak var newpasswordTextField: UITextField!
    @IBOutlet weak var confirmpasswordView: UIView!
    @IBOutlet weak var confirmpasswordTextField: UITextField!
    @IBOutlet weak var createNewPassword: UIButton!
    
    var currentUserEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createNewBackBtn.setButtonborder(btnCorner: createNewBackBtn.frame.width / 2, btnWidth: 2, btnColor: UIColor.lightGray.cgColor)
        newpasswordView.setUiView(radius: newpasswordView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 2)
        confirmpasswordView.setUiView(radius: confirmpasswordView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 2)
        createNewPassword.layer.cornerRadius = createNewPassword.frame.height / 2
    }
    
    @IBAction func createNewBackBtn(_ sender: UIButton) {
        if let navigateBack = storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as? ForgotPasswordViewController {
            navigationController?.pushViewController(navigateBack, animated: true)
        }
    }
    
    @IBAction func createNewPassword(_ sender: UIButton) {
        if(newpasswordTextField.text?.isEmpty ?? true) {
            alretView(kstrmsg: "Please Enter Password")
        } else if !isPasswordValid(newpasswordTextField.text ?? "") {
            alretView(kstrmsg: "Please Enter Valid Password")
        } else if (confirmpasswordTextField.text?.isEmpty ?? true) {
            alretView(kstrmsg: "Please Enter ConfirmPassword")
        } else if newpasswordTextField.text != confirmpasswordTextField.text {
            alretView(kstrmsg: "Password and Confirm Password do not match")
        }
        let success = CoreDataHelper.sharedInstance.updatePassword(for: currentUserEmail ?? "", newPassword: newpasswordTextField.text ?? "")
        if success {
            if let signinNewpasswrd = storyboard?.instantiateViewController(identifier: "SigninViewController") as? SigninViewController {
                navigationController?.pushViewController(signinNewpasswrd, animated: true)
            }
        } else {
            alretView(kstrmsg: "Unable to update password")
        }
    }
    
    @IBAction func newpasswordHide(_ sender: UIButton) {
        if !sender.isSelected{
            sender.isSelected = true
            newpasswordTextField.isSecureTextEntry = false
        } else {
            sender.isSelected = false
            newpasswordTextField.isSecureTextEntry = true
        }
    }
    
    //    MARK: - Confirm Hide And Show Button
    @IBAction func newconfirmpasswordHide(_ sender: UIButton){
        if !sender.isSelected {
            sender.isSelected = true
            confirmpasswordTextField.isSecureTextEntry = false
        } else {
            sender.isSelected = false
            confirmpasswordTextField.isSecureTextEntry = true
        }
    }
}
