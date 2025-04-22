import Foundation
import CoreData
import UIKit

struct ExchangeItemDTO {
    var items: [ExchangeItem] = []
    var favorites: [String] = []
    
    // 불러온 데이터를 저장
    mutating func fetchItems(response: Response) {
        for (key, value) in response.rates {
            items.append(ExchangeItem(currencyTitle: key,
                                      rate: String(format: "%.4f", value),
                                      isFavorited: favorites.contains(key) ? true : false ))
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
    // 즐겨찾기 항목 CoreData에서 불러오기
    mutating func fetchFavorite() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        do {
            let favoriteString = try container.viewContext.fetch(FavoriteExchange.fetchRequest())
            for item in favoriteString as [NSManagedObject] {
                if let name = item.value(forKey: FavoriteExchange.Key.currency) as? String {
                    self.favorites.append(name)
                }
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    // CorData Create
    mutating func saveFavorite(_ currency: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        
        guard let entity = NSEntityDescription.entity(forEntityName: FavoriteExchange.entityName, in: container.viewContext) else { return }
        let newFavorite = NSManagedObject(entity: entity, insertInto: container.viewContext)
        newFavorite.setValue(currency, forKey: FavoriteExchange.Key.currency)
        
        do {
            try container.viewContext.save()
            updateItems(currency, true)
        } catch {
            print("저장 실패")
        }
    }
    // CoreData Remove
    mutating func removeFavorite(_ currency: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        let fetchRequest = FavoriteExchange.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "currency == %@", currency)
        
        do {
            let result = try container.viewContext.fetch(fetchRequest)
            
            for data in result as [NSManagedObject] {
                container.viewContext.delete(data)
            }
            updateItems(currency, false)
        } catch {
            print("삭제 실패")
        }
    }
    // CoreData Update
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
