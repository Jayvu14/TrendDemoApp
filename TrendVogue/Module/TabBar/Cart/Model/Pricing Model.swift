import Foundation

struct Pricing {
    var subtotal: Double
    var deliveryFee: Double
    var discount: Double
    
    var totalCost: Double {
        return subtotal + deliveryFee - discount
    }
    var cartItems: [CartItemModel]
}

