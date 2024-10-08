import UIKit
import FirebaseStorage
import FirebaseFirestoreInternal
import FirebaseAuth
import Kingfisher

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var editImageBuuttonView: UIView!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var editNameView: UIView!
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editProfileButton: UIButton!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        backView.layer.cornerRadius = backView.frame.height / 2
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.bordercolor.cgColor
        editImage.layer.cornerRadius = editImage.frame.width / 2
        editImageBuuttonView.layer.cornerRadius = editImageBuuttonView.frame.height / 2
        editImageButton.layer.cornerRadius = editImageButton.frame.height / 2
        editNameView.layer.cornerRadius = editNameView.frame.height / 2
        editNameView.layer.borderColor = UIColor.bordercolor.cgColor
        editNameView.layer.borderWidth = 1
        editProfileButton.layer.cornerRadius = editProfileButton.frame.height / 2
        
    }
    
    private func fetchUserData() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        let db = Firestore.firestore()
        db.collection("User").document(userEmail).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("Document does not exist")
                return
            }
            
            if let username = data["User Name"] as? String {
                self.editName.text = username
            }
            
            if let profileImageURL = data["profileImageURL"] as? String, let url = URL(string: profileImageURL) {
                self.loadImage(from: url)
            }
        }
    }
    
    private func loadImage(from url: URL) {
        editImage.kf.setImage(with: url, placeholder: nil)
    }
    
    @IBAction func editProfileButtton(_ sender: UIButton) {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        let updatedName = editName.text ?? ""
        
        var updatedData: [String: Any] = [
            "User Name": updatedName
        ]
        
        if let image = selectedImage {
            uploadImage(image) { imageUrl in
                if let imageUrl = imageUrl {
                    updatedData["profileImageURL"] = imageUrl
                }
                self.updateUserProfile(userEmail: userEmail, updatedData: updatedData)
            }
        } else {
            updateUserProfile(userEmail: userEmail, updatedData: updatedData)
        }
    }
    
    private func updateUserProfile(userEmail: String, updatedData: [String: Any]) {
        let db = Firestore.firestore()
        db.collection("User").document(userEmail).updateData(updatedData) { error in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
            } else {
                print("User data updated successfully.")
                self.fetchUserData()
            }
        }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        let imageData = image.jpegData(compressionQuality: 0.8)
        let storageRef = Storage.storage().reference().child("profileImages/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData!, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }
    
    @IBAction func backButttontap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            editImage.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            editImage.image = originalImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
