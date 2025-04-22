import Foundation
import CoreData

extension FavoriteExchange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteExchange> {
        return NSFetchRequest<FavoriteExchange>(entityName: "FavoriteExchange")
    }

    @NSManaged public var currency: String?

}

extension FavoriteExchange : Identifiable {

}
