import UIKit

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forgotemailView: UIView!
    @IBOutlet weak var resetPasswrdButton: UIButton!
    @IBOutlet weak var forgotemailTexfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.layer.borderColor = UIColor.lightGray.cgColor
        backButton.layer.borderWidth = 2
        
        forgotemailView.setUiView(radius: forgotemailView.frame.height / 2, bordercolor: UIColor.lightGray.cgColor, borderwidth: 2)
        resetPasswrdButton.layer.cornerRadius = resetPasswrdButton.frame.height / 2
    }
    
    @IBAction func navigatebackbutton (_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetPasswrdButton(_ sender: UIButton) {
        if(forgotemailTexfield.text?.isEmpty ?? true) {
            alretView(kstrmsg: "Please Enter Email")
        } else if !isValidEmail(forgotemailTexfield.text ?? "") {
            alretView(kstrmsg: "Please Enter Valid Email")
        }
        let fetchResult = CoreDataHelper.sharedInstance.fetchData()
        if let user = fetchResult?.first(where: { $0.useremail == forgotemailTexfield.text }) {
            if let navigateNewPassword = storyboard?.instantiateViewController(identifier: "CreatenewPasswordViewController") as? CreatenewPasswordViewController {
                navigateNewPassword.currentUserEmail = forgotemailTexfield.text ?? ""
                navigationController?.pushViewController(navigateNewPassword, animated: true)
            }
        } else {
            showAlert(alertText: "Sorry", alertMessage: "Invalid creedentials")
        }
    }
}
