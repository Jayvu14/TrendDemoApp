import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SignupViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var namesignupTextField: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailsignupTextField: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordsignupTextField: UITextField!
    @IBOutlet weak var confirmpasswordView: UIView!
    @IBOutlet weak var confirmpasswordsignupTextField: UITextField!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signinnavigateButton: UIButton!
    
    //MARK: - Variables
    var db = Firestore.firestore()
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
}

//MARK: - Button Actions
extension SignupViewController {
    @IBAction func passwordHideSignup(_ sender: UIButton) {
        if !sender.isSelected{
            sender.isSelected = true
            passwordsignupTextField.isSecureTextEntry = false
        } else {
            sender.isSelected = false
            passwordsignupTextField.isSecureTextEntry = true
        }
    }
    
    //    MARK: - Confirm Hide And Show Button
    @IBAction func confirmpasswordHideSignup(_ sender: UIButton){
        if !sender.isSelected {
            sender.isSelected = true
            confirmpasswordsignupTextField.isSecureTextEntry = false
        } else {
            sender.isSelected = false
            confirmpasswordsignupTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func signinNavigate(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signupbutn(_ sender: UIButton) {
        if (emailsignupTextField.text?.isEmpty ?? true) {
            showAlert(alertText: "", alertMessage: "Please Enter Email")
            return
        } else if !isValidEmail(emailsignupTextField.text ?? "") {
            showAlert(alertText: "", alertMessage: "Please Enter Valid Email")
            return
        } else if (passwordsignupTextField.text?.isEmpty ?? true) {
            showAlert(alertText: "", alertMessage: "Please Enter Password")
            return
        } else if !isPasswordValid(passwordsignupTextField.text ?? "") {
            showAlert(alertText: "", alertMessage: "Please Enter Valid Password")
            return
        } else if (confirmpasswordsignupTextField.text?.isEmpty ?? true) {
            showAlert(alertText: "", alertMessage: "Please Enter Confirm Password")
            return
        } else if passwordsignupTextField.text != confirmpasswordsignupTextField.text {
            showAlert(alertText: "", alertMessage: "Password and Confirm Password do not match")
            return
        }
        
        let email = emailsignupTextField.text ?? ""
        let password = passwordsignupTextField.text ?? ""
        let username = namesignupTextField.text ?? ""
        
        UserAuthHelper.shared.createUser(email: email, password: password, username: namesignupTextField.text ?? "") { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.namesignupTextField.text = ""
                    self.emailsignupTextField.text = ""
                    self.passwordsignupTextField.text = ""
                    self.confirmpasswordsignupTextField.text = ""
                    
                    UserAuthHelper.shared.showAlert(on: self, title: "Congratulations", message: "Please verify your email to complete the registration.")
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    UserAuthHelper.shared.showAlert(on: self, title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

//MARK: - Custom Functions
extension SignupViewController {
    private func initialSetup() {
        db.collection("User").getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID)=>\(document.data())")
                }
            }
        }
        lblTitle.text = "Fiil your information below or register with your social account."
        lblTitle.font = UIFont().calculateDynamicFontSize(baseFontSize: 14)
        [nameView, emailView, passwordView, confirmpasswordView].forEach {
            $0?.setUiView(radius: nameView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 2, kbackgroundcolor: UIColor.clear.cgColor)
        }
        
        termsButton.setUnderlinedTitle()
        agreeButton.setButtonborder(btnTextcolor: .clear, btnFont: .boldSystemFont(ofSize: 0), btnText: "", btnCorner: 4, btnWidth: 2, btnColor: UIColor.backgoundUIcolour.cgColor,btnbackgroundcolor: UIColor.clear.cgColor)
        //        agreeButton.setButtonborder(btnCorner: 4, btnWidth: 2, btnColor: UIColor.brown.cgColor)
        signupButton.layer.cornerRadius = signupButton.frame.height / 2
        self.signinnavigateButton.setUnderlinedTitle()
        //        PasswordToggleHelper.configurePasswordToggle(for: passwordsignupTextField)
        //        PasswordToggleHelper.configurePasswordToggle(for: confirmpasswordsignupTextField)
    }
}
