import Foundation
import CoreData
import UIKit

struct CoreDataHandler {
    // CoreData Read
    mutating func fetchCoreData(entity: Entity) -> [Any]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        var result: [Any] = []
        do {
            // 즐겨찾기 항목 불러오기
            if case .favorite = entity {
                let object = entity.favorite
                let type = object.type
                let datas = try container.viewContext.fetch(type.fetchRequest())
                
                if let favorites = datas as? [NSManagedObject] {
                    for item in favorites {
                        if let currency = item.value(forKey: object.key.currency) as? String {
                            result.append(currency)
                        }
                    }
                }
            }
            // 최근 환율 항목 불러오기
            if case .lastExchangeItem = entity {
                let object = entity.lastExchangeItem
                let type = object.type
                let datas = try container.viewContext.fetch(type.fetchRequest())
                
                if let lastExchanges = datas as? [NSManagedObject] {
                    for item in lastExchanges {
                        if let currency = item.value(forKey: object.key.currency) as? String,
                           let rate = item.value(forKey: object.key.rate) as? Double,
                           let updateTime = item.value(forKey: object.key.updateTime) as? String,
                           let changeRate = item.value(forKey: object.key.changeRate) as? Double {
                            result.append(LastExchangeItem(currency: currency,
                                                           rate: rate,
                                                           updateTime: updateTime,
                                                           change: changeRate))
                        }
                    }
                }
            }
            return result
        } catch {
            return nil
        }
    }
    
    // CorData Create
    mutating func saveCoreData(entity: Entity,
                               currency: String,
                               rate: Double? = nil,
                               updateTime: String? = nil,
                               changeRate: Double? = nil) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        // 기본으로 즐겨찾기 엔티티로 설정하나, 파라미터의 rate가 nil이 아닌 경우엔 최근 환율정보를 저장하므로 객체 변경
        var object: any Entityable = entity.favorite
        if rate != nil { object = entity.lastExchangeItem }
        
        guard let entity = NSEntityDescription.entity(forEntityName: object.name,
                                                      in: container.viewContext)
        else {
            return false
        }
        let newItems = NSManagedObject(entity: entity, insertInto: container.viewContext)
        
        newItems.setValue(currency, forKey: object.key.currency)
        if let rate = rate,
           let updateTime = updateTime,
           let changeRate = changeRate {
            newItems.setValue(rate, forKey: object.key.rate)
            newItems.setValue(updateTime, forKey: object.key.updateTime)
            newItems.setValue(changeRate, forKey: object.key.changeRate)
        }
        
        do {
            try container.viewContext.save()
            return true
        } catch {
            return false
        }
    }
    
    // Favorite CoreData Remove
    mutating func removeFavorite(_ currency: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        let fetchRequest = FavoriteExchange.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "currency == %@", currency)
        
        do {
            let result = try container.viewContext.fetch(fetchRequest)
            
            for data in result as [NSManagedObject] {
                container.viewContext.delete(data)
            }
            return true
        } catch {
            return false
        }
    }
    
    // LastExchangeItem CoreData Update
    mutating func updateLastExchangeItem(entity: Entity,
                                         currency: String,
                                         rate: Double,
                                         updateTime: String,
                                         changeRate: Double) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        let fetchRequest = LastExchange.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "currency = %@", currency)
        let object: any Entityable = entity.lastExchangeItem
        
        do {
            let result = try container.viewContext.fetch(fetchRequest)
            
            for data in result as [NSManagedObject] {
                data.setValue(rate, forKey: object.key.rate)
                data.setValue(updateTime, forKey: object.key.updateTime)
                data.setValue(changeRate, forKey: object.key.changeRate)
            }
            return true
        } catch {
            return false
        }
        
    }
}
