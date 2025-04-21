import Foundation
import CoreData

@objc(FavoriteExchange)
public class FavoriteExchange: NSManagedObject {
    public static let entityName: String = "FavoriteExchange"
    public enum Key {
        static let currency = "currency"
    }
}
