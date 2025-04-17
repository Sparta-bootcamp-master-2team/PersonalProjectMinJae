import Foundation

// Cell Model
struct ExchangeItem: Hashable {
    let currencyTitle: String
    let countryTitle: String
    let rate: String
}

// Network Response
struct Response: Codable {
    let result: String
    let base: String
    let rates: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case result
        case base = "base_code"
        case rates
    }
}
