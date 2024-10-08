import FirebaseAuth
import FirebaseFirestore

class UserAuthHelper {
    
    static let shared = UserAuthHelper()
    private init() {}
    
    func createUser(email: String, password: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                let userError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User creation failed."])
                completion(.failure(userError))
                return
            }
            
            self.sendEmailVerification(for: user) { verificationError in
                if let verificationError = verificationError {
                    completion(.failure(verificationError))
                    return
                }
                UserAuthHelper.shared.storeUserData(user: user, username: username, completion: completion)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func sendEmailVerification(for user: User, completion: @escaping (Error?) -> Void) {
        user.sendEmailVerification { error in
            completion(error)
        }
    }
    
    private func storeUserData(user: User, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        let db = Firestore.firestore()
        let placeholderImageURL = ""
        let userData: [String: Any] = [
            "User Name": username,
            "User Email": user.email ?? "",
            "profileImageURL": placeholderImageURL
        ]
        
        guard let userEmail = user.email else {
            let emailError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User email is not available."])
            completion(.failure(emailError))
            return
        }
        
        db.collection("User").document(userEmail).setData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(userEmail))
            }
        }
    }
    
    func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
