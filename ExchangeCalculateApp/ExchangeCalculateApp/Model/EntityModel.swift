import Foundation
import CoreData

// CoreDataEntity Protocol
protocol Entityable {
    associatedtype ObjectType: NSManagedObject
    var type: ObjectType.Type { get }
    var name: String { get }
    var key: Key { get }
}

// Entity 열거형
enum Entity {
    case favorite
    case lastExchangeItem
    case lastCurrency
    
    var favorite: some Entityable {
        return FavoriteEntity(key: .setUpFavoriteKeys())
    }
    var lastExchangeItem: some Entityable {
        return LastExchangeEntity(key: .setUpLastExchangeKeys())
    }
    var lastCurrency: some Entityable {
        return LastCurrencyEntity(key: .setUpLastCurrencyKeys())
    }
}

// Protocol을 실체화 하기 위한 래핑객체 Favorite
struct FavoriteEntity: Entityable {
    typealias ObjectType = FavoriteExchange
    var type = FavoriteExchange.self
    var name: String = "FavoriteExchange"
    var key: Key
}

// Protocol을 실체화 하기 위한 래핑객체 LastExchange
struct LastExchangeEntity: Entityable {
    typealias ObjectType = LastExchange
    var type = LastExchange.self
    var name: String = "LastExchange"
    var key: Key
}

struct LastCurrencyEntity: Entityable {
    typealias ObjectType = LastCurrency
    var type = LastCurrency.self
    var name: String = "LastCurrency"
    var key: Key
}

// Entity Key
struct Key {
    var currency: String = ""
    var rate: String = ""
    var updateTime: String = ""
    var changeRate: String = ""
    
    static func setUpFavoriteKeys() -> Key {
        return Key(currency: "currency")
    }
    static func setUpLastExchangeKeys() -> Key {
        return Key(currency: "currency",
                   rate: "rate",
                   updateTime: "updateTime",
                   changeRate: "changeRate")
    }
    static func setUpLastCurrencyKeys() -> Key {
        return Key(currency: "currency")
    }
}
