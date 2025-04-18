import Foundation
import Alamofire

// MARK: NetworkManager

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case serverError(code: Int)
    case transportError
}

enum ServerURL {
    static let string = "https://open.er-api.com/v6/latest/USD"
}

final class NetworkManager {
    func fetch<T: Codable>(type: T.Type, for url: String) async throws ->  T {
        guard let url = URL(string: url) else {
            throw(NetworkError.invalidURL)
        }
        let request = Session.default.request(url)
        
        let response = await request.serializingDecodable(T.self).response
        
        guard response.response?.statusCode == 200 else {
            throw NetworkError.serverError(code: response.response?.statusCode ?? 0)
        }
        
        guard let data = response.value else {
            throw(NetworkError.decodingError)
        }
        return data
    }
}
