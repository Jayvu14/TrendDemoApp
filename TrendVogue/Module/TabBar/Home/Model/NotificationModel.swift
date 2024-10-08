import Foundation
import FirebaseFirestoreInternal

struct Notification {
    let id: String
    var title: String
    var body: String
    var timestamp: Date
    
    init?(data: [String: Any], id: String) {
            guard let title = data["title"] as? String,
                  let body = data["body"] as? String,
                  let timestamp = data["timestamp"] as? Timestamp else { return nil }
            
            self.id = id 
            self.title = title
            self.body = body
            self.timestamp = timestamp.dateValue()
        }
}
