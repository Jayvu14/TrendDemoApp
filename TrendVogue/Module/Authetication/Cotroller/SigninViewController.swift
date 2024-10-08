import UIKit
import AuthenticationServices
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

class SigninViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var signinLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var emailPlaceholder: UILabel!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordPlaceholder: UILabel!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var signupnavigateBtn: UIButton!
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let signInBtn = ASAuthorizationAppleIDButton()
        self.uisetup()
    }
}

//MARK: - Button Actions
extension SigninViewController {
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
        if let navigetetosignin = authenticationStoryboard.instantiateViewController(identifier: SignupViewController.identifier) as? SignupViewController {
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
            guard error == nil else {
                self.showAlert(alertText: "Google Sign In Error", alertMessage: error!.localizedDescription)
                return
            }
            
            guard let signIInResult = signInResult,
                  let user = signInResult?.user else { return }
            let idToken = user.idToken?.tokenString ?? ""
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString ?? "")
            // Sign in with Firebase using Google
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(alertText: "Google Sign In Error", alertMessage: error.localizedDescription)
                    return
                }
                // Navigate to home
                self.navigateToHome()
            }
        }
    }
    
    @IBAction func forgotnavigate(_ sender: UIButton) {
        if let navigateforgot = storyboard?.instantiateViewController(withIdentifier: ForgotPasswordViewController.identifier) as? ForgotPasswordViewController {
            navigationController?.pushViewController(navigateforgot, animated: true)
        }
    }
    
    @IBAction func signinButton(_ sender: UIButton){
        if(emailTextField.text?.isEmpty ?? true) {
            showAlert(alertText: "", alertMessage: "Please Enter Username")
        } else if !isValidEmail(emailTextField.text ?? "") {
            showAlert(alertText: "", alertMessage: "Your Username Doesn't Match")
        } else if (passwordTextField.text?.isEmpty ?? true) {
            showAlert(alertText: "", alertMessage: "Please Enter Password")
        } else if !isPasswordValid(passwordTextField.text ?? "") {
            showAlert(alertText: "", alertMessage: "Your Password Doesn't Match")
        }
        self.userSignIn()
    }
}

//MARK: - Custom Functions
extension SigninViewController {
    func uisetup() {
        signinLabel.setLabel(labelText: "Sign In", labelColour: .black, labelSize: .systemFont(ofSize: 24, weight: .semibold))
        messageLabel.setLabel(labelText: "Hi! Welcome back, you've been missed ", labelColour: .lightGray, labelSize: .systemFont(ofSize: 16, weight: .light))
        emailPlaceholder.setLabel(labelText: "Email", labelColour: .black, labelSize: .systemFont(ofSize: 16))
        passwordPlaceholder.setLabel(labelText: "Password", labelColour: .black, labelSize: .systemFont(ofSize: 16))
        emailView.setUiView(radius: emailView.frame.height / 2, bordercolor: UIColor.bordercolor.cgColor, borderwidth: 1, kbackgroundcolor: UIColor.white.cgColor)
        passwordView.setUiView(radius: passwordView.frame.height / 2, bordercolor: UIColor.bordercolor.cgColor, borderwidth: 1, kbackgroundcolor: UIColor.white.cgColor)
        signinButton.setButtonborder(btnTextcolor: .white, btnFont: .systemFont(ofSize: 16, weight: .bold), btnText: "Sign In", btnCorner: signinButton.frame.height / 2, btnWidth: 0, btnColor: UIColor.brown.cgColor,btnbackgroundcolor: UIColor.backgoundUIcolour.cgColor)
        forgotButton.setButtonborder(btnTextcolor: .backgoundUIcolour, btnFont: .systemFont(ofSize: 16, weight: .bold), btnText: "Forgot Password?", btnCorner: 0, btnWidth: 0, btnColor: UIColor.clear.cgColor,btnbackgroundcolor: UIColor.clear.cgColor)
        forgotButton.setUnderlinedTitle()
        signupnavigateBtn.setUnderlinedTitle()
        //        appleBtn.setButtonborder(btnTextcolor: .clear, btnFont: .boldSystemFont(ofSize: 0), btnText: "", btnCorner:
        //        appleBtn.frame.height / 2, btnWidth: 2, btnColor: UIColor.bordercolor.cgColor, btnbackgroundcolor: UIColor.clear.cgColor)
        appleBtn.setImage(UIImage(named: "apple"), for: .normal)
        googleBtn.setImage(UIImage(named: "search"), for: .normal)
        facebookBtn.setImage(UIImage(named: "facebook"), for: .normal)
        [appleBtn, googleBtn, facebookBtn].forEach {
            $0?.setButtonborder(btnTextcolor: .clear, btnFont: .boldSystemFont(ofSize: 0), btnText: "", btnCorner: appleBtn.frame.height / 2, btnWidth: 2, btnColor: UIColor.bordercolor.cgColor,btnbackgroundcolor: UIColor.clear.cgColor)
            //            appleBtn.setImage("apple", for: .disabled)
            //            setButtonborder(btnCorner: appleBtn.frame.height / 2, btnWidth: 2, btnColor: UIColor.bordercolor.cgColor)
        }
        //                PasswordToggleHelper.configurePasswordToggle(for: passwordTextField)
    }
    
    //MARK: - User Sign in

    private func userSignIn() {
            UserAuthHelper.shared.signIn(email: emailTextField.text!, password: passwordTextField.text!) { result in
                switch result {
                case .success:
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self.navigateToHome()
                case .failure(let error):
                    self.showAlert(alertText: "Sign In Error", alertMessage: error.localizedDescription)
                }
            }
        }
    
    private func navigateToHome() {
        if let navigateHome = customTabBarStoryboard.instantiateViewController(withIdentifier: CustomTabBarViewController.identifier) as? CustomTabBarViewController {
            navigationController?.pushViewController(navigateHome, animated: true)
        }
    }
}

//MARK: - ASAuthorizationControllerDelegate
extension SigninViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel,handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            guard let appleIDToken = credentials.identityToken,
                  let tokenString = String(data: appleIDToken, encoding: .utf8) else { return }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, accessToken: "")
            
            // Sign in with Firebase using Apple ID
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(alertText: "Apple Sign In Error", alertMessage: error.localizedDescription)
                    return
                }
                self.navigateToHome()
            }
        default:
            break
        }
    }
}

//MARK: - ASAuthorizationControllerPresentationContextProviding
extension SigninViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

