import UIKit
import FirebaseFirestoreInternal
import FirebaseAuth

class CreatenewPasswordViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var createNewBackBtn: UIButton!
    @IBOutlet weak var newpasswordView: UIView!
    @IBOutlet weak var newpasswordTextField: UITextField!
    @IBOutlet weak var confirmpasswordView: UIView!
    @IBOutlet weak var confirmpasswordTextField: UITextField!
    @IBOutlet weak var createNewPassword: UIButton!
    
    //MARK: - Variables
    var currentUserEmail: String?
    
    //MARK: - Overridee Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
}
//MARK: - ButtonAction
extension CreatenewPasswordViewController {
    @IBAction func createNewBackBtn(_ sender: UIButton) {
        if let navigateBack = storyboard?.instantiateViewController(withIdentifier: ForgotPasswordViewController.identifier) as? ForgotPasswordViewController {
            navigationController?.pushViewController(navigateBack, animated: true)
        }
    }
    
    @IBAction func createNewPassword(_ sender: UIButton) {
        if(newpasswordTextField.text?.isEmpty ?? true) {
            showAlert(alertText: "", alertMessage: "Please Enter Password")
        } else if !isPasswordValid(newpasswordTextField.text ?? "") {
            showAlert(alertText: "", alertMessage: "Please Enter Valid Password")
        } else if (confirmpasswordTextField.text?.isEmpty ?? true) {
            showAlert(alertText: "", alertMessage: "Please Enter ConfirmPassword")
        } else if newpasswordTextField.text == confirmpasswordTextField.text {
            showAlert(alertText: "", alertMessage: "Password and Confirm Password do not match")
        }
        self.updatePassword()
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

//MARK: - Custom Functions
extension CreatenewPasswordViewController {
    private func initialSetup() {
        createNewBackBtn.setButtonborder(btnTextcolor: .clear, btnFont: .boldSystemFont(ofSize: 0), btnText: "", btnCorner: createNewBackBtn.frame.width / 2, btnWidth: 2, btnColor: UIColor.lightGray.cgColor, btnbackgroundcolor: UIColor.clear.cgColor)
        //        createNewBackBtn.setButtonborder(btnCorner: createNewBackBtn.frame.width / 2, btnWidth: 2, btnColor: UIColor.lightGray.cgColor)
        newpasswordView.setUiView(radius: newpasswordView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 2, kbackgroundcolor: UIColor.clear.cgColor)
        confirmpasswordView.setUiView(radius: confirmpasswordView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 2, kbackgroundcolor: UIColor.clear.cgColor)
        createNewPassword.layer.cornerRadius = createNewPassword.frame.height / 2
    }
    
    private func updatePassword() {
        Auth.auth().currentUser?.updatePassword(to: newpasswordTextField.text ?? "") { error in
            if let error = error {
                self.showAlert(alertText: "", alertMessage: "Error updating password: \(error.localizedDescription)")
                return
            }
            // Update password in Firestore
            let db = Firestore.firestore()
            guard let email = self.currentUserEmail else { return }
            db.collection("User").whereField("User Email", isEqualTo: email).getDocuments { (querySnapshot, error) in
                if let error = error {
                    self.showAlert(alertText: "", alertMessage: "Error fetching user: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    self.showAlert(alertText: "", alertMessage: "User not found.")
                    return
                }
                
                // Assuming the user document is updated with the new password
                let userDocument = documents.first!
                userDocument.reference.updateData(["password": self.newpasswordTextField.text ?? ""]) { error in
                    if let error = error {
                        self.showAlert(alertText: "", alertMessage: "Unable to update password in Firestore: \(error.localizedDescription)")
                        return
                    }
                    
                    // Navigate to SigninViewController after successful update
                    if let signinNewpasswrd = self.storyboard?.instantiateViewController(identifier: SigninViewController.identifier) as? SigninViewController {
                        self.navigationController?.pushViewController(signinNewpasswrd, animated: true)
                    }
                }
            }
        }
    }
}
