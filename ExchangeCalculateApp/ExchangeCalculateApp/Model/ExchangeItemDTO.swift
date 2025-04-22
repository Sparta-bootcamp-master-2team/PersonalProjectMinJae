import Foundation
import CoreData
import UIKit

struct ExchangeItemDTO {
    var items: [ExchangeItem] = []
    var favorites: [String] = []
    var lastExchangeItems: [LastExchangeItem] = []
    private var coreDataHandler = CoreDataHandler()
    // 불러온 데이터를 저장
    mutating func fetchItems(response: Response) {
        for (key, value) in response.rates {
            let lastRate = lastExchangeItems.filter{ $0.currency == key }.first
            let chagedRate = value - (lastRate?.rate ?? 0.0)
            items.append(ExchangeItem(currencyTitle: key,
                                      rate: String(format: "%.4f", value),
                                      isFavorited: favorites.contains(key) ? true : false,
                                      changedRate: chagedRate))
        }
        // 정렬
        sortItems()
    }
    
    // 정렬 메서드
    mutating func sortItems() {
        let favorites = self.items.filter { $0.isFavorited }.sorted{ $0.currencyTitle < $1.currencyTitle }
        let nonFavorites = self.items.filter { !$0.isFavorited }.sorted{ $0.currencyTitle < $1.currencyTitle }
        self.items = favorites + nonFavorites
        
    }
    mutating func fetchMockData() {
        let mock = MockData.mockRates
        for (key, value) in mock {
            lastExchangeItems.append(LastExchangeItem(currency: key, rate: value, updatedTime: "mock"))
        }
    }
    // 필터링된 데이터 리턴
    func filterItems(searchText: String) -> [ExchangeItem] {
        let text = searchText.uppercased()
        var filteredItems = items.filter { $0.currencyTitle.contains(text) || $0.countryTitle.uppercased().contains(text) }
        if searchText == "" { filteredItems = self.items }
        return filteredItems
    }
    
    // CoreData Read
    mutating func fetchCoreData(entity: Entity) -> Bool {
        let result = coreDataHandler.fetchCoreData(entity: entity)
        guard let result else { return false }
        if case .favorite = entity {
            self.favorites = result as! [String]
        }
        if case .lastExchangeItem = entity {
            self.lastExchangeItems = result as! [LastExchangeItem]
        }
        
        return true
    }
    
    // CorData Create
    mutating func saveCoreData(entity: Entity,
                               currency: String,
                               rate: String? = nil,
                               updatedTime: String? = nil) -> Bool {
        let result = coreDataHandler.saveCoreData(entity: entity,
                                                  currency: currency,
                                                  rate: rate,
                                                  updatedTime: updatedTime)
        updateItems(currency, true)
        return result
    }
    // CoreData Remove
    mutating func removeFavorite(_ currency: String) -> Bool {
        let result = coreDataHandler.removeFavorite(currency)
        updateItems(currency, false)
        return result
    }
    
    mutating func updateItems(_ currency: String,_ isFavorited: Bool) {
        for i in 0..<items.count {
            if items[i].currencyTitle == currency {
                items[i].isFavorited = isFavorited
                break
            }
        }
        sortItems()
    }
}
