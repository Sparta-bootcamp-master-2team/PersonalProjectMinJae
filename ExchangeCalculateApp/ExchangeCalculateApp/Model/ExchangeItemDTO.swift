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
        // items에 저장
        for (key, value) in response.rates {
            let lastRate = lastExchangeItems.filter{ $0.currency == key }.first
            let chagedRate = value - (lastRate?.rate ?? value)
            items.append(ExchangeItem(currencyTitle: key,
                                      rate: String(format: "%.4f", value),
                                      isFavorited: favorites.contains(key) ? true : false,
                                      changedRate: chagedRate))
        }
        
        // 이전 데이터 업데이트 필요 여부 파악
        let updateTime = response.updateUnixTime
        let nextUpdateTime = lastExchangeItems.first?.updateTime ?? 0
        let nowUnixTime = Int(Date().timeIntervalSince1970)
        
        print("now: \(nowUnixTime), next: \(nextUpdateTime)")
        if nowUnixTime >= nextUpdateTime {
            // 업데이트 필요
            print("이전 데이터 업데이트 필요!")
            if !lastExchangeItems.isEmpty {
                print("이전 데이터가 존재, 갱신 필요!")
                // changeRate 계산 및 갱신
                for (key, value) in response.rates {
                    let lastRate = lastExchangeItems.filter{ $0.currency == key }.first?.rate ?? 0.0
                    let currentRate = value
                    let _ = coreDataHandler.updateLastExchangeItem(entity: .lastExchangeItem,
                                                           currency: key,
                                                           rate: currentRate,
                                                           updateTime: updateTime,
                                                           changeRate: currentRate - lastRate)
                }
            } else {
                // 데이터 주입
                print("이전 데이터가 존재하지않음, 주입 필요!")
                for (key, value) in response.rates {
                    let _ = coreDataHandler.saveCoreData(entity: .lastExchangeItem,
                                                         currency: key,
                                                         rate: value,
                                                         updateTime: updateTime,
                                                         changeRate: value)
                }
            }
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
                               rate: Double? = nil,
                               updateTime: Int? = nil,
                               changeRate: Double? = nil) -> Bool {
        let result = coreDataHandler.saveCoreData(entity: entity,
                                                  currency: currency,
                                                  rate: rate,
                                                  updateTime: updateTime,
                                                  changeRate: changeRate)
        updateItems(currency, true)
        return result
    }
    // CoreData Remove
    mutating func removeFavorite(_ currency: String) -> Bool {
        let result = coreDataHandler.removeFavorite(currency)
        updateItems(currency, false)
        return result
    }
    
    // 즐겨찾기 항목 업데이트
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
