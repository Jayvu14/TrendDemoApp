import Foundation

struct CartItemModel {
    var title: String
    var size: String
    var price: String
    var image: String
    var quantity: Int
    
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "size": size,
            "price": price,
            "image": image,
            "quantity": quantity
        ]
    }
}
