import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forgotemailView: UIView!
    @IBOutlet weak var resetPasswrdButton: UIButton!
    @IBOutlet weak var forgotemailTexfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
}

//MARK: - Buttton Action
extension ForgotPasswordViewController {
    @IBAction func navigatebackbutton (_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetPasswrdButton(_ sender: UIButton) {
        if (forgotemailTexfield.text?.isEmpty ?? true) {
            showAlert(alertText: "", alertMessage: "Please Enter Email")
        } else if !isValidEmail(forgotemailTexfield.text ?? "") {
            showAlert(alertText: "", alertMessage: "Please Enter Valid Email")
        }
        
        Auth.auth().sendPasswordReset(withEmail: forgotemailTexfield.text ?? "") { error in
            if let error = error {
                self.handleAuthError(error)
            } else {
                self.showAlert(alertText: "Success", alertMessage: "If an account exists with this email, a password reset link has been sent. Please check your inbox.")
            }
        }
    }
}

//MARK: - Custom Functions
extension ForgotPasswordViewController {
    private func initialSetup() {
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.layer.borderColor = UIColor.lightGray.cgColor
        backButton.layer.borderWidth = 2
        forgotemailView.setUiView(radius: forgotemailView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 2,kbackgroundcolor: UIColor.clear.cgColor)
        resetPasswrdButton.layer.cornerRadius = resetPasswrdButton.frame.height / 2
    }
    
    private func handleAuthError(_ error: Error) {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.userNotFound.rawValue:
            showAlert(alertText: "Error", alertMessage: "No account found with this email.")
        default:
            showAlert(alertText: "Error", alertMessage: "An error occurred. Please try again later.")
        }
    }
}
