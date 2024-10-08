import UIKit

class SignupViewController: UIViewController {
    
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
    
    var objusermodel = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(objusermodel)
        lblTitle.text = "Fiil your information below or register with your social account."
        lblTitle.font = UIFont().calculateDynamicFontSize(baseFontSize: 14)
        [nameView, emailView, passwordView, confirmpasswordView].forEach {
            $0?.setUiView(radius: nameView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 2)
        }
        
        termsButton.setUnderlinedTitle()
        agreeButton.setButtonborder(btnCorner: 4, btnWidth: 2, btnColor: UIColor.brown.cgColor)
        signupButton.layer.cornerRadius = signupButton.frame.height / 2
        self.signinnavigateButton.setUnderlinedTitle()
        //        PasswordToggleHelper.configurePasswordToggle(for: passwordsignupTextField)
        //        PasswordToggleHelper.configurePasswordToggle(for: confirmpasswordsignupTextField)
    }
    
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
            alretView(kstrmsg: "Please Enter Email")
        } else if !isValidEmail(emailsignupTextField.text ?? "") {
            alretView(kstrmsg: "Please Enter Valid Email")
        } else if (passwordsignupTextField.text?.isEmpty ?? true) {
            alretView(kstrmsg: "Please Enter Password")
        } else if !isPasswordValid(passwordsignupTextField.text ?? "") {
            alretView(kstrmsg: "Please Enter Valid Password")
        } else if (confirmpasswordsignupTextField.text?.isEmpty ?? true) {
            alretView(kstrmsg: "Please Enter Confirm Password")
        } else if passwordsignupTextField.text != confirmpasswordsignupTextField.text {
            alretView(kstrmsg: "Password and Confirm Password do not match")
        }
        if let fetchResult = CoreDataHelper.sharedInstance.fetchData(){
            if fetchResult.contains(where: {$0.useremail == (emailsignupTextField.text ?? "")}){
                self.showAlert(alertText: "Error!", alertMessage: "User Already Exist.")
            } else {
                let dataSave = UserModel(nameuser: namesignupTextField.text ?? "",
                                         emailuser: emailsignupTextField.text ?? "",
                                         passworduser: passwordsignupTextField.text ?? "",
                                         confimpassworduser: confirmpasswordsignupTextField.text ?? "")
                CoreDataHelper.sharedInstance.saveData(objUserModel: dataSave)
                self.clearTextField()
                showAlert(alertText: "Congratulations", alertMessage: "User Signup Successfully")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    private func clearTextField() {
        self.namesignupTextField.text = ""
        self.emailsignupTextField.text = ""
        self.passwordsignupTextField.text = ""
        self.confirmpasswordsignupTextField.text = ""
    }
}
