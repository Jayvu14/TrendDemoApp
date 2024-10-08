import Foundation
import CoreData
import UIKit

class CoreDataHelper {
    static let sharedInstance = CoreDataHelper()
    
    //MARK: - Save User in coredata
    func saveData(objUserModel: UserModel) {
        if let save = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: context!) as? UserEntity {
            save.username = objUserModel.nameuser
            save.useremail = objUserModel.emailuser
            save.userpassword = objUserModel.passworduser
            save.usercopassword = objUserModel.confimpassworduser
            do{
                try context?.save()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Fetch User from coredata
    func fetchData() -> [UserEntity]? {
        var showData = [UserEntity]()
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "UserEntity")
        do {
            showData = try! context?.fetch(request) as! [UserEntity]
            return showData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    //MARK: - Current User fetch from coredata
    func fetchCurrentUser(email: String) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "useremail == %@", email)
        do {
            let users = try context?.fetch(request)
            return users?.first
        } catch {
            print("Failed to fetch current user: \(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: - Update user password
    func updatePassword(for email: String, newPassword: String) -> Bool {
        guard let user = fetchCurrentUser(email: email) else {
            print("User not found")
            return false
        }
        user.userpassword = newPassword
        do {
            try context?.save()
            print("Password updated successfully")
            return true
        } catch {
            print("Failed to update password: \(error.localizedDescription)")
            return false
        }
    }
}

