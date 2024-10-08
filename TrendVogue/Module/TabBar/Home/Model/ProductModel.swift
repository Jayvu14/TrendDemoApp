import Foundation

// MARK: - ProductModel
struct ProductModel: Codable {
    let id: Int
    let title: String
    let price: Int
    let description: String
    let images: [String]
    let creationAt, updatedAt: String
    let category: Category
    var isselected:Bool = false
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.price = try container.decode(Int.self, forKey: .price)
        self.description = try container.decode(String.self, forKey: .description)
        self.images = try container.decode([String].self, forKey: .images)
        self.creationAt = try container.decode(String.self, forKey: .creationAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.category = try container.decode(Category.self, forKey: .category)
    }
    
    var categoryName: String {
            return category.name
        }
}

// MARK: - Category
struct Category: Codable {
    let id: Int
    let name: String
    let image: String
    let creationAt: String
    let updatedAt: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.image = try container.decode(String.self, forKey: .image)
        self.creationAt = try container.decode(String.self, forKey: .creationAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

enum CategoryName: String, Codable {
    case electronics = "Electronics"
    case furniture = "Furniture"
    case miscellaneous = "Miscellaneous"
    case newBooks = "New Books"
    case nuevo = "nuevo"
    case shoes = "Shoes"
}
