import UIKit
import AuthenticationServices
import GoogleSignIn

class SigninViewController: UIViewController {
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var signupnavigateBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let signInBtn = ASAuthorizationAppleIDButton()
        self.uisetup()
    }
    
    func uisetup() {
        emailView.setUiView(radius: emailView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 1)
        passwordView.setUiView(radius: passwordView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 1)
        signinButton.layer.cornerRadius = signinButton.frame.height / 2
        forgotButton.setUnderlinedTitle()
        signupnavigateBtn.setUnderlinedTitle()
        
        [appleBtn, googleBtn, facebookBtn].forEach {
            $0?.setButtonborder(btnCorner: appleBtn.frame.height / 2, btnWidth: 2, btnColor: UIColor.lightGray.cgColor)
        }
        //        PasswordToggleHelper.configurePasswordToggle(for: passwordTextField)
    }
    
    
    @IBAction func passwordhidesignin(_ sender: UIButton){
        if !sender.isSelected{
            sender.isSelected = true
            passwordTextField.isSecureTextEntry = false
        }
        else{
            sender.isSelected = false
            passwordTextField.isSecureTextEntry = true
        }
        
    }
    
    @IBAction func signupnavigatebtn(_ sender: UIButton) {
        if let navigetetosignin = storyboard?.instantiateViewController(identifier: "SignupViewController") as? SignupViewController {
            navigationController?.pushViewController(navigetetosignin, animated: true)
        }
    }
    
    @IBAction func signinwithapple(_ sender: UIButton) {
        let appleIDprovider = ASAuthorizationAppleIDProvider()
        let request = appleIDprovider.createRequest()
        request.requestedScopes = [.email,.fullName]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
    }
    
    @IBAction func googleBtn(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            
            guard let signIInResult = signInResult else { return }
            let user = signInResult?.user
            
            print(user?.profile?.email ?? "")
            print(user?.profile?.name ?? "")
            print(user?.profile?.familyName ?? "")
            print(user?.profile?.imageURL(withDimension: 320) ?? "")
            self.showAlert(alertText: "Heyy", alertMessage: "\(user?.profile?.name) You have login to Google")
        }
    }
    
    @IBAction func forgotnavigate(_ sender: UIButton) {
        if let navigateforgot = storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as? ForgotPasswordViewController {
            navigationController?.pushViewController(navigateforgot, animated: true)
        }
    }
    
    @IBAction func signinButton(_ sender: UIButton){
        if(emailTextField.text?.isEmpty ?? true){
            alretView(kstrmsg: "Please Enter Username")
        }else if !isValidEmail(emailTextField.text ?? ""){
            alretView(kstrmsg: "Your Username Doesn't Match")
        }else if (passwordTextField.text?.isEmpty ?? true){
            alretView(kstrmsg: "Please Enter Password")
        }else if !isPasswordValid(passwordTextField.text ?? ""){
            alretView(kstrmsg: "Your Password Doesn't Match")
        }
        let fetchResult = CoreDataHelper.sharedInstance.fetchData()
        if let user = fetchResult?.first(where: { $0.useremail == emailTextField.text && $0.userpassword == passwordTextField.text}) {
            showAlert(alertText: "Congratuation", alertMessage: "You have sucessfully login \(user.useremail ?? "")")
        } else {
            showAlert(alertText: "Sorry", alertMessage: "Invalid creedentials")
        }
    }
    

}
extension SigninViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel,handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            print(credentials.user)
            print(credentials.email!)
            print(credentials.fullName!)
            
        case let credentials as ASPasswordCredential :
            print(credentials.password)
        default:
            let alert = UIAlertController(title: "Apple SignIn", message: "Something went wrong with your Apple SignIn", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel,handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

extension SigninViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

