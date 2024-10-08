import Foundation
import UIKit

extension UICollectionView {
    func collectionDelegate(vc: UIViewController, identifier: String) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        self.delegate = vc as? UICollectionViewDelegate
        self.dataSource = vc as? UICollectionViewDataSource
    }
}
