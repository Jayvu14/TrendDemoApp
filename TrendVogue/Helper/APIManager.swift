import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
}

class APIManager {
    static let shared = APIManager()
    private init() {}
    func fetchProducts(completion: @escaping (Result<[ProductModel], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let products = try JSONDecoder().decode([ProductModel].self, from: data)
                completion(.success(products))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
