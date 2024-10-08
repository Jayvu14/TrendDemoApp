import UIKit
import FirebaseAuth
import CoreLocation
import FirebaseFirestore
import Kingfisher

class HomeViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var allProductsTableView: UITableView!
    @IBOutlet weak var seeallProduct: UIButton!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notficationBadgeView: UIView!
    @IBOutlet weak var notificationBadgeLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationShowlabel: UILabel!
    @IBOutlet weak var productSearch: UISearchBar!
    @IBOutlet weak var FiltersearchView: UIView!
    @IBOutlet weak var pagecontrolCollection: UICollectionView!
    @IBOutlet weak var productCategoryCollection: UICollectionView!
    @IBOutlet weak var salesStartHoursLabel: UILabel!
    @IBOutlet weak var salesStartHoursView: UIView!
    @IBOutlet weak var salesStartMinuteLabel: UILabel!
    @IBOutlet weak var salesStartMinuteView: UIView!
    @IBOutlet weak var salesStartSeeccondsLabel: UILabel!
    @IBOutlet weak var salesStartSecondsView: UIView!
    @IBOutlet weak var genderShowCollectionView: UICollectionView!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var pagecontrol: UIPageControl!
    @IBOutlet weak var productCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var pagecategory: UIStackView!
    @IBOutlet weak var flashsale: UIStackView!
    
    //MARK: - Variables
    var currentIndex: Int = 0
    var objpageImage = [BannerModel(banner: "Banner1"), BannerModel(banner: "Banner2"), BannerModel(banner: "Banner3"), BannerModel(banner: "Banner4")]
    let productCategories: [ProductCategory] = [
        ProductCategory(imageName: "brand", label: "Clothes", item: .nuevo),
        ProductCategory(imageName: "devices", label: "Electronics", item: .electronics),
        ProductCategory(imageName: "furniture", label: "Furniture", item: .furniture),
        ProductCategory(imageName: "sneakerss", label: "Shoes", item: .shoes),
        ProductCategory(imageName: "gift", label: "Miscellaneous", item: .miscellaneous)]
    
    var objProductGenderLabel = [GenderModel(gender: "All"),GenderModel(gender: "Clothes"),
                                 GenderModel(gender: "Devices"),GenderModel(gender: "Furniture"),
                                 GenderModel(gender: "Shoes"),GenderModel(gender: "Miscellaneous")]
    var products: [ProductModel] = []
    var isSearching: Bool = false
    var timer: Timer?
    var targetDate: Date?
    var currentSelectedIndexPath: IndexPath?
    var likedStates: [Bool] = []
    let locationManager = CLLocationManager()
    var notifications: [Notification] = []
    
    //MARK: - Data deallocate
    deinit {
        timer?.invalidate()
    }
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
        fetchNotifications()
        
    }
}

//MARK: - Button Action
extension HomeViewController {
    @IBAction func seeAllProductTapped(_ sender: UIButton) {
        self.stackView.isHidden = false
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.stackView.isHidden = true
    }
    
    @IBAction func notificationTapped(_ sender: UIButton) {
        if let notificationVC = HomeStoryboard.instantiateViewController(withIdentifier: NotificationShowViewController.identifier) as? NotificationShowViewController {
            navigationController?.pushViewController(notificationVC, animated: true)
        }
    }
    
    func updateBadgeLabel() {
        let count = notifications.count
        if count > 0 {
            notificationBadgeLabel.text = "\(count)"
            notificationBadgeLabel.isHidden = false
            notficationBadgeView.isHidden = false
        } else {
            notificationBadgeLabel.isHidden = true
            notficationBadgeView.isHidden = true
        }
    }
    
    func fetchNotifications() {
        let db = Firestore.firestore()
        db.collection("notifications").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching notifications: \(error.localizedDescription)")
                return
            }
            self.notifications = snapshot?.documents.compactMap { document in Notification(data: document.data(), id: document.documentID) } ?? []
            self.updateBadgeLabel()
        }
    }
}

//MARK: - Objc Methods
extension HomeViewController {
    @objc func changeBanner() {
        self.currentIndex += 1
        if self.currentIndex >= objpageImage.count {
            self.currentIndex = 0
        }
        let indexPath = IndexPath(item: self.currentIndex, section: 0)
        self.pagecontrolCollection.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        self.pagecontrol.currentPage = self.currentIndex
    }
    
    @objc func likedislikeButtonTapped(_ sender: UIButton) {
        let itemIndex = sender.tag
        guard itemIndex < products.count else { return }
        likedStates[itemIndex].toggle()
        let productId = String(products[itemIndex].id)
        if !products[itemIndex].isselected {
            addLike(for: productId, isSelected: true)
            products[itemIndex].isselected = true
        } else {
            removeLike(for: productId)
            products[itemIndex].isselected = false
        }
        let isLiked = products[itemIndex].isselected
        let imageName = isLiked ? "heart.fill" : "heart"
        let image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        
        sender.setImage(image, for: .normal)
        sender.tintColor = isLiked ? UIColor.brown : UIColor.gray
    }
    
    private func fetchLikedProducts() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.email else { return }
        db.collection("likes").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let document = document, document.exists {
                let likedData = document.data() ?? [:]
                print(likedData)
                self.likedStates = self.products.map { product in
                    return likedData[String(product.id)] as? Bool ?? false
                }
                self.products.indices.forEach { kindex in
                    if let pid = likedData["product\(self.products[kindex].id)"] as? [String:Any]{
                        print(pid)
                        if let kid = Int(pid["productId"] as? String ?? ""){
                            if let index = self.products.firstIndex(where: {$0.id == kid}){
                                if let kisselected = pid["isSelected"] as? Bool{
                                    self.products[index].isselected = kisselected
                                    print(self.products[index])
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.productsCollectionView.reloadData()
                }
            } else {
                print("No liked products found or document does not exist")
            }
        }
    }
    
    private func addLike(for productId: String, isSelected:Bool) {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.email ?? "unknown_user"
        
        db.collection("likes").document(userId).setData(["product\(productId)":["productId":productId,
                                                                                "isSelected":isSelected]], merge: true) { error in
            if let error = error {
                print("Error adding like: \(error.localizedDescription)")
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
            } else {
                print("Successfully unliked product \(productId)")
            }
        }
    }
    
    
    @objc func updateCountdown() {
        let currentDate = Date()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let targetDateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let midnightDate = calendar.date(from: targetDateComponents)!
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: midnightDate)!
        let remainingTime = nextMidnight.timeIntervalSince(currentDate)
        
        if remainingTime <= 0 {
            timer?.invalidate()
            salesStartHoursLabel.text = "00"
            salesStartMinuteLabel.text = "00"
            salesStartSeeccondsLabel.text = "00"
            return
        }
        
        let hours = Int(remainingTime) / 3600
        let minutes = (Int(remainingTime) % 3600) / 60
        let seconds = Int(remainingTime) % 60
        
        salesStartHoursLabel.text = String(format: "%02d", hours)
        salesStartMinuteLabel.text = String(format: "%02d", minutes)
        salesStartSeeccondsLabel.text = String(format: "%02d", seconds)
    }
}

//MARK: - Custom Functions
extension HomeViewController {
    private func initialSetup() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.stackView.backgroundColor = .white
        notificationBadgeLabel.isHidden = true
        notficationBadgeView.isHidden = true
        notificationBadgeLabel.textColor = .white
        notficationBadgeView.layer.cornerRadius = 10
        setupLocationManager()
        self.startTimer()
        productSearch.delegate = self
        allProductsTableView.delegate = self
        allProductsTableView.dataSource = self
        stackView.isHidden = true
        notificationView.layer.cornerRadius = notificationView.frame.height / 2
        notificationView.layer.backgroundColor = UIColor.lightGray.cgColor
        [salesStartHoursView,salesStartMinuteView,salesStartSecondsView].forEach({$0?.setUiView(radius: 8, bordercolor: UIColor.white.cgColor, borderwidth: 0,kbackgroundcolor: UIColor.backgroundBrown.cgColor)})
        pagecontrolCollection.layer.cornerRadius = 20
        pagecontrol.numberOfPages = objpageImage.count
        pagecontrol.currentPage = currentIndex
        self.pagecontrolCollection.collectionDelegate(vc: self, identifier: PageControlCollectionViewCell.identifier)
        self.productCategoryCollection.collectionDelegate(vc: self, identifier: ProductXIBCell.identifier)
        self.genderShowCollectionView.collectionDelegate(vc: self, identifier: GenderXIBCell.identifier)
        self.productsCollectionView.collectionDelegate(vc: self, identifier: ProductShowXib.identifier)
        self.allProductsTableView.setTable(vc: self, identifier: SeeAllXIBCell.identifier)
        likedStates = Array(repeating: false, count: products.count)
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.changeBanner), userInfo: nil, repeats: true)
        }
        self.FiltersearchView.layer.cornerRadius = FiltersearchView.frame.height / 2
        self.customizeSearchBar()
    }
    
    //MARK: - Fetch and Filter Products
    private func filterProducts(for category: String) {
        APIManager.shared.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self?.products = products.filter { $0.categoryName == category }
                    self?.fetchLikedProducts()
                    self?.productsCollectionView.reloadData()
                case .failure(let error):
                    print("Error fetching products: \(error)")
                }
            }
        }
    }
    
    private func fetchProducts() {
        APIManager.shared.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self?.products = products
                    self?.likedStates = Array(repeating: false, count: products.count)
                    self?.fetchLikedProducts()
                    self?.productsCollectionView.reloadData()
                case .failure(let error):
                    print("Error fetching products: \(error)")
                }
            }
        }
    }
    
    private func customizeSearchBar() {
        let image = UIImage(named: "searchm")
        self.productSearch.setSearchBar(borderWidth: 1.0, borderColor: UIColor.bordercolor.cgColor, cornereRadius: 23, backgroundColor: .clear, leftView: UIImageView(image: image), placeeHolder: "Search", barStyle: .minimal, textBackgroundColor: .white)
        self.productSearch.searchTextField.borderStyle = .none
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pagewidth = scrollView.frame.size.width
        let currentpage = Int(scrollView.contentOffset.x / pagewidth)
        self.pagecontrol.currentPage = currentpage
    }
}

//MARk: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case genderShowCollectionView:
            if let previousIndexPath = currentSelectedIndexPath {
                if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? GenderXIBCell {
                    previousCell.genderView.backgroundColor = .clear
                    previousCell.genderLabel.textColor = .black
                }
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? GenderXIBCell {
                cell.genderView.backgroundColor = .backgoundUIcolour
                cell.genderLabel.textColor = .white
            }
            currentSelectedIndexPath = indexPath
        case productCategoryCollection:
            let selectedCategory = productCategories[indexPath.item].item
            filterProducts(for: selectedCategory.rawValue)

        case productsCollectionView:
            let selectedProduct = products[indexPath.item]
            if let navigate = storyboard?.instantiateViewController(withIdentifier: AddToCartViewController.identifier) as?  AddToCartViewController  {
                navigate.selectedProduct = selectedProduct
                navigationController?.pushViewController(navigate, animated: true)
            }
        default:
            break
        }
    }
}

//MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case pagecontrolCollection:
            return objpageImage.count
        case productCategoryCollection:
            return productCategories.count
        case genderShowCollectionView:
            return objProductGenderLabel.count
        case productsCollectionView:
            return products.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case pagecontrolCollection:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageControlCollectionViewCell.identifier, for: indexPath) as? PageControlCollectionViewCell {
                cell.configureCell(showImage: objpageImage[indexPath.row].banner)
                return cell
            }
        case productCategoryCollection:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductXIBCell.identifier, for: indexPath) as? ProductXIBCell {
                let category = productCategories[indexPath.item]
                cell.productshowImage.image = UIImage(named: category.imageName)
                cell.productshowLabel.text = category.label
                return cell
            }
        case genderShowCollectionView:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenderXIBCell.identifier, for: indexPath) as? GenderXIBCell {
                let category = objProductGenderLabel[indexPath.item]
                cell.genderLabel.text = objProductGenderLabel[indexPath.item].gender
                if indexPath == currentSelectedIndexPath {
                    cell.genderView.backgroundColor = .backgoundUIcolour
                    cell.genderLabel.textColor = .white
                } else {
                    cell.genderView.backgroundColor = .clear
                    cell.genderLabel.textColor = .black
                }
                return cell
            }
        case productsCollectionView:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductShowXib.identifier, for: indexPath) as? ProductShowXib {
                let product = products[indexPath.item]
                if let imageUrlString = product.images.first, let imageUrl = URL(string: imageUrlString) {
                    cell.productImages.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
                } else {
                    cell.productImages.image = UIImage(systemName: "person")
                }
                cell.productTittle.text = product.title
                cell.productRatings.setTitle(String(product.id), for: .normal)
                cell.productPrice.text = "$\(product.price)"
                cell.likedislikeButton.tag = indexPath.item
                let isLiked = product.isselected
                let heartImageName = isLiked ? "heart.fill" : "heart"
                cell.likedislikeButton.setImage(UIImage(systemName: heartImageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
                cell.likedislikeButton.tintColor = isLiked ? UIColor.brown : UIColor.brown
                
                cell.likedislikeButton.addTarget(self, action: #selector(likedislikeButtonTapped(_:)), for: .touchUpInside)
                return cell
            }
        default:
            break
        }
        return UICollectionViewCell()
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case pagecontrolCollection :
            return CGSize(width: (collectionView.frame.width), height: 200)
        case productCategoryCollection :
            return CGSize(width: collectionView.frame.width / 4, height: 110)
        case genderShowCollectionView :
            let categoryName = objProductGenderLabel[indexPath.item].gender
            let font = UIFont.systemFont(ofSize: 20)
            let labelSize = (categoryName as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
            let padding: CGFloat = 20
            let cellWidth = labelSize.width + padding
            return CGSize(width: cellWidth, height: 50)
        case productsCollectionView:
            var kheight = 0.0
            if  (self.products.count % 2 == 0){
                kheight = 280 * Double((self.products.count / 2))
            }else{
                kheight = 280 * Double((self.products.count / 2) + 1)
            }
            productCollectionHeight.constant = kheight
            return CGSize(width: (collectionView.frame.width - 16) / 2, height: 280)
        default:
            break
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case genderShowCollectionView:
            return 15
        case productsCollectionView:
            return 10
        default :
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case genderShowCollectionView:
            return 15
        case productsCollectionView:
            return 10
        default :
            break
        }
        return 0
    }
}

//MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = productCategories[indexPath.item].item
        filterProducts(for: selectedCategory.rawValue)
        self.stackView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

//MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SeeAllXIBCell.identifier, for: indexPath) as? SeeAllXIBCell {
            let product = productCategories[indexPath.row]
            cell.structurelable.text = product.label
            cell.structureImage.image = UIImage(named: product.imageName)
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                if let error = error {
                    self?.locationShowlabel.text = "Failed to find address: \(error.localizedDescription)"
                    return
                }
                if let placemark = placemarks?.first {
                    var addressString: String = ""
                    if let name = placemark.name { addressString += name + ", " }
                    if let locality = placemark.locality { addressString += locality + ", " }
                    if let administrativeArea = placemark.administrativeArea { addressString += administrativeArea + " " }
                    if let postalCode = placemark.postalCode { addressString += postalCode }
                    self?.locationShowlabel.text = addressString
                } else {
                    self?.locationShowlabel.text = "Address not found"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationShowlabel.text = "Failed to find location: \(error.localizedDescription)"
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            fetchProducts()
        } else {
            isSearching = true
            filterProducts(query: searchText)
        }
        pagecontrolCollection.isHidden = isSearching
        pagecategory.isHidden = isSearching
        flashsale.isHidden = isSearching
    }
    
    private func filterProducts(query: String) {
        APIManager.shared.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self?.products = products.filter { $0.title.lowercased().contains(query.lowercased()) }
                    self?.productsCollectionView.reloadData()
                case .failure(let error):
                    print("Error fetching products: \(error)")
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        fetchProducts()
    }
}
