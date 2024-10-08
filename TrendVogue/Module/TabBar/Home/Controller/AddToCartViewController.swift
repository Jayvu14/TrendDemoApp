import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal
import Kingfisher

class AddToCartViewController: UIViewController {
    
    @IBOutlet weak var backBtnView: UIView!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var likeBtnView: UIView!
    @IBOutlet weak var likebutton: UIButton!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productDetail: UILabel!
    @IBOutlet weak var productCollectImages: UICollectionView!
    @IBOutlet weak var productGender: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productId: UILabel!
    @IBOutlet weak var productDiscription: UITextView!
    @IBOutlet weak var sizeCollecctionView: UICollectionView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var addTocartButton: UIButton!
    
    var currentIndex: Int = 0
    var selectedProduct: ProductModel?
    var likedStates: [Bool] = []
    var currentSelectedIndexPath: IndexPath?
    var scrolldirection = UICollectionViewLayout()
    var selecetedSize: String?
    var cartItem: CartItemModel?
    
    var objcollectionImages = [ProductImagesModel]()
    
    var objcloathsizes = [ProductSizeModel(cloathSize: " S "), ProductSizeModel(cloathSize: " M "), ProductSizeModel(cloathSize: " L "),
                          ProductSizeModel(cloathSize: "XL"), ProductSizeModel(cloathSize: "XXL"),ProductSizeModel(cloathSize: "XXXL")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        self.displayProductDetails()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func initialSetup() {
        productCollectImages.isScrollEnabled = false
        productDetail.textColor = .white
        productDetail.layer.shadowColor = UIColor.black.cgColor
        productDetail.layer.shadowRadius = 5.0
        productDetail.layer.shadowOpacity = 3.0
        productDetail.layer.shadowOffset = CGSize(width: 7, height: 7)
        productDetail.layer.masksToBounds = false
        productCollectImages.collectionDelegate(vc: self, identifier: ImagesXIIBCell.identifier)
        sizeCollecctionView.collectionDelegate(vc: self, identifier: SizeXIBCell.identifier)
        addTocartButton.layer.cornerRadius = addTocartButton.frame.height / 2
        backBtnView.layer.cornerRadius = backBtnView.frame.height / 2
        likeBtnView.layer.cornerRadius = likeBtnView.frame.height / 2
        priceView.layer.cornerRadius = 20
        priceView.layer.shadowOffset = .zero
        priceView.layer.shadowColor = UIColor.bordercolor.cgColor
        priceView.layer.shadowOpacity = 10
    }
    
    private func displayProductDetails() {
        guard let product = selectedProduct else { return }
        objcollectionImages = product.images.map { ProductImagesModel(imagesCollection: $0) }
        productCollectImages.reloadData()
        if let imageUrlString = product.images.first, let imageUrl = URL(string: imageUrlString) {
            productImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder")) { result in
                switch result {
                case .success(let value):
                    print("Image loaded: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Error loading image: \(error)")
                    self.productImage.image = UIImage(systemName: "photo")
                }
            }
        }
        productTitle.text = product.title
        let imageName = product.isselected ? "heart.fill" : "heart"
        likebutton.setImage(UIImage(systemName: imageName), for: .normal)
        likebutton.tintColor = product.isselected ? UIColor.brown : UIColor.brown
        productCategory.text = product.categoryName
        productId.text = "Product ID: \(product.id)"
        productPrice.text = "$\(product.price)"
        productDiscription.text = product.description
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let product = selectedProduct else { return }
        selectedProduct?.isselected.toggle()
        let productIdString = String(product.id)
        if selectedProduct?.isselected == true {
            addLike(for: productIdString, isSelected: true)
        } else {
            removeLike(for: productIdString)
        }
        updateLikeButtonImage()
    }
    
    private func saveCartItemToFirestore(cartItem: CartItemModel) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        
        let cartData: [String: Any] = [
            "title": cartItem.title,
            "size": cartItem.size,
            "price": cartItem.price,
            "image": cartItem.image,
            "quantity": cartItem.quantity
        ]
        
        db.collection("carts").document(userId).setData([cartItem.title: cartData], merge: true) { error in
            if let error = error {
                print("Error adding cart item: \(error.localizedDescription)")
                self.showAlert(with: "Error", message: "Could not add item to cart.")
            } else {
                print("Successfully added item to cart")
            }
        }
    }
    
    private func updateLikeButtonImage() {
        let imageName = selectedProduct?.isselected == true ? "heart.fill" : "heart"
        likebutton.setImage(UIImage(systemName: imageName), for: .normal)
        likebutton.tintColor = selectedProduct?.isselected == true ? UIColor.brown : UIColor.brown
    }
    
    private func addLike(for productId: String, isSelected: Bool) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        
        db.collection("likes").document(userId).setData(["product\(productId)": [
            "productId": productId,
            "isSelected": isSelected]],
                                                        merge: true) { error in
            if let error = error {
                print("Error adding like: \(error.localizedDescription)")
                self.selectedProduct?.isselected.toggle()
                self.updateLikeButtonImage()
            } else {
                print("Successfully liked product \(productId)")
            }
        }
    }
    
    private func removeLike(for productId: String) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        
        db.collection("likes").document(userId).updateData(["product\(productId)": FieldValue.delete()]) { error in
            if let error = error {
                print("Error removing like: \(error.localizedDescription)")
                self.selectedProduct?.isselected.toggle()
                self.updateLikeButtonImage()
            } else {
                print("Successfully unliked product \(productId)")
            }
        }
    }
    
    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func clicktomoreimage(_ sender: UIButton) {
        let item = sender.tag
        self.currentIndex += 8
        if self.currentIndex >= objcollectionImages.count {
            self.currentIndex = 1
        }
        let indexPath = IndexPath(item: self.currentIndex, section: 0)
        self.productCollectImages.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        let previousIndexPath = IndexPath(item: item, section: 0)
        if let previousCell = self.productCollectImages.cellForItem(at: previousIndexPath) as? ImagesXIIBCell {
            previousCell.moreImages.isHidden = true
            productCollectImages.isScrollEnabled = true
        }
    }
    
    @IBAction func addCartVC(_ sender: UIButton) {
        if let addtoCart = CartStoryboard.instantiateViewController(identifier: CartViewController.identifier) as? CartViewController {
            if let product = selectedProduct {
                let cartItem = CartItemModel(
                    title: product.title,
                    size: selecetedSize ?? "",
                    price: productPrice.text ?? "",
                    image: product.images.first ?? "", quantity: 1
                )
                addtoCart.objcartItem.append(cartItem)
                addtoCart.cameFromAddCart = true
                saveCartItemToFirestore(cartItem: cartItem)
                NotificationHelper.shared.sendNotification(title: "Item Added", body: "\(product.title) \(productPrice.text ?? "") has been added to your cart.")
            }
            navigationController?.pushViewController(addtoCart, animated: true)
        }
    }
}

extension AddToCartViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case productCollectImages:
            return objcollectionImages.count
        case sizeCollecctionView:
            return objcloathsizes.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case sizeCollecctionView:
            if let previousIndexPath = currentSelectedIndexPath {
                if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? SizeXIBCell {
                    previousCell.cloathsizeView.backgroundColor = .clear
                    previousCell.cloathsizeLabel.textColor = .black
                }
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? SizeXIBCell {
                cell.cloathsizeView.backgroundColor = .backgoundUIcolour
                cell.cloathsizeLabel.textColor = .white
                selecetedSize = objcloathsizes[indexPath.item].cloathSize.trimmingCharacters(in: .whitespaces)
            }
            currentSelectedIndexPath = indexPath
        case productCollectImages:
            let imageUrlString = objcollectionImages[indexPath.item].imagesCollection
            if let imageUrl = URL(string: imageUrlString) {
                self.productImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case productCollectImages:
            if let productImagecell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagesXIIBCell.identifier, for: indexPath) as? ImagesXIIBCell {
                productImagecell.imageCollection.image = UIImage(named: objcollectionImages[indexPath.item].imagesCollection)
                let imageUrlString = objcollectionImages[indexPath.item].imagesCollection
                if let imageUrl = URL(string: imageUrlString) {
                    productImagecell.imageCollection.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
                }
                
                return productImagecell
            }
        case sizeCollecctionView:
            if let sizesCell = collectionView.dequeueReusableCell(withReuseIdentifier: SizeXIBCell.identifier, for: indexPath) as? SizeXIBCell {
                sizesCell.cloathsizeLabel.text = objcloathsizes[indexPath.item].cloathSize
                if indexPath == currentSelectedIndexPath {
                    sizesCell.cloathsizeView.backgroundColor = .backgoundUIcolour
                    sizesCell.cloathsizeLabel.textColor = .white
                } else {
                    sizesCell.cloathsizeView.backgroundColor = .clear
                    sizesCell.cloathsizeLabel.textColor = .black
                }
                return sizesCell
            }
        default:
            break
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case productCollectImages:
            return CGSize(width: 60, height: 60)
        case sizeCollecctionView:
            let categoryName = objcloathsizes[indexPath.item].cloathSize
            let font = UIFont.systemFont(ofSize: 20)
            let labelSize = (categoryName as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
            let padding: CGFloat = 20
            let cellWidth = labelSize.width + padding
            return CGSize(width: cellWidth, height: 40)
        default:
            break
        }
        return CGSize()
    }
}
