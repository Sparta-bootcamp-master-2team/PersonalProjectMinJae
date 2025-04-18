import Foundation

struct ExchangeItemDTO {
    var items: [ExchangeItem] = []
    // 데이터 저장
    mutating func fetchItems(response: Response) {
        for (key, value) in response.rates {
            items.append(ExchangeItem(currencyTitle: key, rate: String(format: "%.4f", value)))
        }
    }
    // 필터링된 데이터 리턴
    func filterItems(searchText: String) -> [ExchangeItem] {
        let text = searchText.uppercased()
        var filteredItems = items.filter { $0.currencyTitle.contains(text) || $0.countryTitle.uppercased().contains(text) }
        if searchText == "" { filteredItems = self.items }
        return filteredItems
    }
}
