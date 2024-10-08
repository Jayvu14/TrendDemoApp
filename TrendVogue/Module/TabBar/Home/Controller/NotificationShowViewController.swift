import UIKit
import FirebaseFirestoreInternal
import FirebaseFirestore

class NotificationShowViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var notificationTableView: UITableView!
    
    var newNotifications: [Notification] = []
    var oldNotifications: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTableView.setTable(vc: self, identifier: NotificationXIBCell.identifier)
        notificationTableView.sectionHeaderTopPadding = 1.0
        backView.layer.cornerRadius = backView.frame.height / 2
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.bordercolor.cgColor
        clearAllButton.layer.backgroundColor = UIColor.black.cgColor
        clearAllButton.layer.cornerRadius = clearAllButton.frame.height / 2
        self.fetchNotifications()
    }
    
    @IBAction func backButtontap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearAllNotification(_ sender: UIButton) {
        let db = Firestore.firestore()
        db.collection("notifications").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching notifications: \(error.localizedDescription)")
                return
            }
            let batch = db.batch()
            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            batch.commit { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error deleting notifications: \(error.localizedDescription)")
                } else {
                    print("All notifications deleted successfully.")
                    DispatchQueue.main.async {
                        self.newNotifications.removeAll()
                        self.oldNotifications.removeAll()
                        self.notificationTableView.reloadData()
                        self.updateClearAllButtonVisibility()
                    }
                }
            }
        }
    }
    private func updateClearAllButtonVisibility() {
        clearAllButton.isHidden = newNotifications.isEmpty && oldNotifications.isEmpty
    }
    
    func fetchNotifications() {
        let db = Firestore.firestore()
        db.collection("notifications").order(by: "timestamp", descending: true).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching notifications: \(error.localizedDescription)")
                return
            }
            
            let currentDate = Date()
            let twoHoursAgo = currentDate.addingTimeInterval(-2 * 60 * 60)
            
            self.newNotifications = []
            self.oldNotifications = []
            
            snapshot?.documents.forEach { document in
                if let notification = Notification(data: document.data(), id: document.documentID) {
                    if notification.timestamp >= twoHoursAgo {
                        self.newNotifications.append(notification)
                    } else {
                        self.oldNotifications.append(notification)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.notificationTableView.reloadData()
                self.updateClearAllButtonVisibility()
            }
        }
    }
}
extension NotificationShowViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if newNotifications.isEmpty && oldNotifications.isEmpty {
            return 1
        }
        var sections = 0
        if !newNotifications.isEmpty { sections += 1 }
        if !oldNotifications.isEmpty { sections += 1 }
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newNotifications.isEmpty && oldNotifications.isEmpty {
            return 1
        }
        
        if !newNotifications.isEmpty && section == 0 {
            return newNotifications.count
        } else if !oldNotifications.isEmpty && (section == 1 || (newNotifications.isEmpty && section == 0)) {
            return oldNotifications.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if newNotifications.isEmpty && oldNotifications.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Notifications"
            cell.textLabel?.textAlignment = .center
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationXIBCell.identifier, for: indexPath) as? NotificationXIBCell else {
            return UITableViewCell()
        }
        
        let notification: Notification
        if !newNotifications.isEmpty && indexPath.section == 0 {
            notification = newNotifications[indexPath.row]
        } else if !oldNotifications.isEmpty && (indexPath.section == 1 || (newNotifications.isEmpty && indexPath.section == 0)) {
            notification = oldNotifications[indexPath.row]
        } else {
            return UITableViewCell()
        }
        
        cell.notificationTittle.text = notification.title
        cell.notificationSizeQuantity.text = notification.body
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy EEE hh:mm a"
        let formattedDate = dateFormatter.string(from: notification.timestamp)
        cell.notificattionPrice.text = formattedDate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if newNotifications.isEmpty && oldNotifications.isEmpty {
            return nil
        }
        let headerView = UIView()
        headerView.backgroundColor = .backgoundUIcolour
        headerView.layer.cornerRadius = 14
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        switch section {
        case 0:
            titleLabel.text = "New Notifications"
            titleLabel.textColor = .white
            titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        case 1:
            titleLabel.text = "Old Notifications"
            titleLabel.textColor = .white
            titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        default:
            titleLabel.text = ""
        }
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if newNotifications.isEmpty && oldNotifications.isEmpty {
            return 0
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notificationToDelete: Notification
            if !newNotifications.isEmpty && indexPath.section == 0 {
                notificationToDelete = newNotifications[indexPath.row]
                newNotifications.remove(at: indexPath.row)
            } else if !oldNotifications.isEmpty && (indexPath.section == 1 || (newNotifications.isEmpty && indexPath.section == 0)) {
                notificationToDelete = oldNotifications[indexPath.row]
                oldNotifications.remove(at: indexPath.row)
            } else {
                return
            }
            
            let db = Firestore.firestore()
            db.collection("notifications").document(notificationToDelete.id).delete { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error deleting notification: \(error.localizedDescription)")
                } else {
                    print("Notification deleted successfully.")
                    DispatchQueue.main.async {
                        self.notificationTableView.reloadData()
                        self.updateClearAllButtonVisibility()
                    }
                }
            }
        }
    }
}
