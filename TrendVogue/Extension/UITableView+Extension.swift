import Foundation
import UIKit

extension UITableView {
    func setTable(vc: UIViewController, identifier: String) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        self.delegate = vc as? UITableViewDelegate
        self.dataSource = vc as? UITableViewDataSource
    }
}
