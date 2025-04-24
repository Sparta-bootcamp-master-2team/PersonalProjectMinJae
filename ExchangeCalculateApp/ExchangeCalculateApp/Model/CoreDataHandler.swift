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
                           let updateTime = item.value(forKey: object.key.updateTime) as? Int,
                           let changeRate = item.value(forKey: object.key.changeRate) as? Double {
                            result.append(LastExchangeItem(currency: currency,
                                                           rate: rate,
                                                           updateTime: updateTime,
                                                           change: changeRate))
                        }
                    }
                }
            }
            
            if case .lastCurrency = entity {
                let object = entity.lastCurrency
                let type = object.type
                let datas = try container.viewContext.fetch(type.fetchRequest())
                
                if let lastCurrency = datas as? [NSManagedObject] {
                    for item in lastCurrency {
                        if let currency = item.value(forKey: object.key.currency) as? String {
                            result.append(currency)
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
                               updateTime: Int? = nil,
                               changeRate: Double? = nil) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        // 기본으로 즐겨찾기 엔티티로 설정하나, 파라미터의 rate가 nil이 아닌 경우엔 최근 환율정보를 저장하므로 객체 변경
        var object: any Entityable = entity.favorite
        if case .lastExchangeItem = entity { object = entity.lastExchangeItem }
        if case .lastCurrency = entity { object = entity.lastCurrency }
        
        guard let setEntity = NSEntityDescription.entity(forEntityName: object.name,
                                                      in: container.viewContext)
        else {
            return false
        }
        let newItems = NSManagedObject(entity: setEntity, insertInto: container.viewContext)
        
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
            let result = self.fetchCoreData(entity: entity)
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
    
    // CoreData에 저장된 마지막 통화 문자열 삭제
    func removeLastCurrency() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        let fetchRequest = LastCurrency.fetchRequest()
        
        do {
            let result = try container.viewContext.fetch(fetchRequest)
            
            for data in result as [NSManagedObject] {
                container.viewContext.delete(data)
            }
            print("removeLastCurrency success")
        } catch {
            print("removeLastCurrency failed")
        }
    }
    
    // LastExchangeItem CoreData Update
    mutating func updateLastExchangeItem(entity: Entity,
                                         currency: String,
                                         rate: Double,
                                         updateTime: Int,
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
