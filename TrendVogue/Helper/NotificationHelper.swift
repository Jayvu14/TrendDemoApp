import UIKit
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

class NotificationHelper {
    
    static let shared = NotificationHelper()
    private init() {
        
    }
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: User is not logged in.")
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let db = Firestore.firestore()
        let notificationData: [String: Any] = [
            "title": title,
            "body": body,
            "timestamp": Timestamp(date: Date())
        ]
        
        //        db.collection("notifications").document(userEmail).setData(notificationData) { error in
        //            if let error = error {
        //                print("Error adding notification to Firestore: \(error.localizedDescription)")
        //            } else {
        //                print("Notification saved to Firestore.")
        //                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        //                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //                UNUserNotificationCenter.current().add(request) { error in
        //                    if let error = error {
        //                        print("Error adding notification: \(error.localizedDescription)")
        //                    }
        //                }
        //            }
        //        }
        db.collection("notifications").document(UUID().uuidString).setData(notificationData) { error in
            if let error = error {
                print("Error adding notification to Firestore: \(error.localizedDescription)")
            } else {
                print("Notification saved to Firestore.")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error adding notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
