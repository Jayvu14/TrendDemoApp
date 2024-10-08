import Foundation
import UIKit

extension UIViewController{
    func alretView(kstrmsg:String){
        let alert = UIAlertController(title: "", message: kstrmsg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
