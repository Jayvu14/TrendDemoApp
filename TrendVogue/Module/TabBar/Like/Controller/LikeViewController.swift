import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class LikeViewController: UIViewController {
    
    @IBOutlet weak var likeCollectionView: UICollectionView!
    
    var products: [ProductModel] = []
    var likedStates: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likeCollectionView.collectionDelegate(vc: self, identifier: ProductShowXib.identifier)
        fetchProducts()
    }
    
    private func fetchProducts() {
        APIManager.shared.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    print("Fetched Products: \(products)")
                    self?.products = products
                    self?.likedStates = Array(repeating: false, count: products.count)
                    self?.fetchLikedProducts()
                case .failure(let error):
                    print("Error fetching products: \(error)")
                }
            }
        }
    }
    
    private func fetchLikedProducts() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.email else { return }
        db.collection("likes").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let document = document, document.exists {
                let likedData = document.data() ?? [:]
                print("Liked Data: \(likedData)")
                let likedProductIds = likedData.compactMap { key, value -> Int? in
                    if let dict = value as? [String: Any], let productIdString = dict["productId"] as? String, let productId = Int(productIdString) {
                        return productId
                    }
                    return nil
                }
                print("Liked Product IDs: \(likedProductIds)")
                self.products = self.products.filter { likedProductIds.contains($0.id) }
                self.likedStates = Array(repeating: false, count: self.products.count) // Initialize likedStates for filtered products
                print("Liked Products: \(self.products)")
                DispatchQueue.main.async {
                    self.likeCollectionView.reloadData()
                }
            } else {
                print("No liked products found or document does not exist")
            }
        }
    }
    
    @objc func likedislikeButtonTapped(_ sender: UIButton) {
        let productIndex = sender.tag
        guard productIndex < products.count else { return }
        let product = products[productIndex]
        let productId = String(product.id)
        likedStates[productIndex].toggle()
        if likedStates[productIndex] {
            removeLike(for: productId)
        }
        let heartImageName = likedStates[productIndex] ? "heart" : "heart.fill"
        sender.setImage(UIImage(systemName: heartImageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        sender.tintColor = likedStates[productIndex] ? UIColor.brown : UIColor.brown
    }
    
    private func removeLike(for productId: String) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        
        db.collection("likes").document(userId).updateData(["product\(productId)": FieldValue.delete()]) { error in
            if let error = error {
                print("Error removing like: \(error.localizedDescription)")
            } else {
                print("Successfully unliked product \(productId)")
            }
        }
    }
}

extension LikeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductShowXib", for: indexPath) as? ProductShowXib {
            let product = products[indexPath.row]
            cell.productTittle.text = product.title
            cell.productPrice.text = "$\(product.price)"
            cell.likedislikeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            if let imageUrlString = product.images.first, let imageUrl = URL(string: imageUrlString) {
                cell.productImages.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
            } else {
                cell.productImages.image = UIImage(named: "placeholder")
            }
            cell.productRatings.setTitle(String(product.id), for: .normal)
            cell.likedislikeButton.tag = indexPath.row
            cell.likedislikeButton.addTarget(self, action: #selector(likedislikeButtonTapped(_:)), for: .touchUpInside)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 18) / 2, height: 280)
    }
}

