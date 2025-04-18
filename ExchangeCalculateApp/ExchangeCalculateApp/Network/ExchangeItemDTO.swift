import Foundation

struct ExchangeItemDTO {
    var items: [ExchangeItem] = []
    
    mutating func fetchItems(response: Response) {
        for (key, value) in response.rates {
            items.append(ExchangeItem(currencyTitle: key, rate: String(format: "%.4f", value)))
        }
    }
    
    func filterItems(searchText: String) -> [ExchangeItem] {
        let text = searchText.uppercased()
        var filteredItems = items.filter { $0.currencyTitle.contains(text) || $0.countryTitle.uppercased().contains(text) }
        if searchText == "" { filteredItems = self.items }
        return filteredItems
    }
}
