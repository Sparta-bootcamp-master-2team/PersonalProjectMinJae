import Foundation

struct ExchangeItemDTO {
    var items: [ExchangeItem] = []
    var filteredItems: [ExchangeItem] = []
    
    mutating func fetchItems(response: Response) {
        for (key, value) in response.rates {
            items.append(ExchangeItem(currencyTitle: key, rate: String(format: "%.4f", value)))
        }
    }
}
