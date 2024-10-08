import UIKit
import FirebaseFirestoreInternal
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileeditButton: UIButton!
    @IBOutlet weak var profileeditView: UIView!
    @IBOutlet weak var profilefunctionTableView: UITableView!
    
    var objProfile = [
        ProfileFunctionalityModel(functionalityImage: "profileuser", functionalityLabel: "Your Profile", functionalityButton: "chevron.right"),
        ProfileFunctionalityModel(functionalityImage: "shoppinglist", functionalityLabel: "My Orders", functionalityButton: "chevron.right"),
        ProfileFunctionalityModel(functionalityImage: "padlock", functionalityLabel: "Privacy Policy", functionalityButton: "chevron.right"),
        ProfileFunctionalityModel(functionalityImage: "exit", functionalityLabel: "Log out", functionalityButton: "chevron.right")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilefunctionTableView.setTable(vc: self, identifier: ProfileXIBCell.identifier)
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileeditView.layer.cornerRadius = profileeditView.frame.height / 2
        profileeditButton.layer.cornerRadius = profileeditButton.frame.height / 2
        fetchProfileImageURL()
    }
    
    func uploadImageToFirebase(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                guard let downloadURL = url else { return }
                print("Image uploaded successfully! Download URL: \(downloadURL.absoluteString)")
                self?.saveImageURLToFirestore(url: downloadURL.absoluteString)
            }
        }
    }
    
    func saveImageURLToFirestore(url: String) {
        guard let userID = Auth.auth().currentUser?.email else {
            print("User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("User").document(userID).setData(["profileImageURL": url], merge: true) { error in
            if let error = error {
                print("Error saving image URL: \(error.localizedDescription)")
            } else {
                print("Image URL successfully saved to Firestore!")
            }
        }
    }
    
    func fetchProfileImageURL() {
        guard let userID = Auth.auth().currentUser?.email else {
            print("User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("User").document(userID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("Document does not exist")
                return
            }
            
            if let name = data["User Name"] as? String {
                self.profileName.text = name
            }
            
            if let profileImageURL = data["profileImageURL"] as? String {
                self.loadImage(from: profileImageURL)
            }
        }
    }
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
        }
        task.resume()
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objProfile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let tableProfilecell = profilefunctionTableView.dequeueReusableCell(withIdentifier: "ProfileXIBCell", for: indexPath) as? ProfileXIBCell {
            tableProfilecell.functionalityImage.image = UIImage(named: objProfile[indexPath.row].functionalityImage)
            tableProfilecell.functionalityLabel.text = objProfile[indexPath.row].functionalityLabel
            tableProfilecell.buttonTapAction = { [weak self] in
                if indexPath.row == 0 {
                    if let myorder = ProfileStoryboard.instantiateViewController(identifier: EditProfileViewController.identifier) as? EditProfileViewController {
                        self?.navigationController?.pushViewController(myorder, animated: true)
                    }
                }
                if indexPath.row == 1 {
                    if let myorder = CartStoryboard.instantiateViewController(identifier: MyOrderViewController.identifier) as? MyOrderViewController {
                        self?.navigationController?.pushViewController(myorder, animated: true)
                    }
                }
                if indexPath.row == 2 {
                    if let privacy = ProfileStoryboard.instantiateViewController(identifier: PrivacyPolicyViewController.identifier) as? PrivacyPolicyViewController {
                        self?.navigationController?.pushViewController(privacy, animated: true)
                    }
                }
                if indexPath.row == 3 {
                    if let logoutVC = ProfileStoryboard.instantiateViewController(identifier: LogoutViewController.identifier) as? LogoutViewController {
                        logoutVC.modalTransitionStyle = .crossDissolve
                        logoutVC.modalPresentationStyle = .overCurrentContext
                        self?.present(logoutVC, animated: true, completion: nil)
                    }
                }
            }
            
            return tableProfilecell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImage.image = selectedImage
            uploadImageToFirebase(image: selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func profileEditButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
