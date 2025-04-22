import Foundation
import CoreData


extension LastExchange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastExchange> {
        return NSFetchRequest<LastExchange>(entityName: "LastExchange")
    }

    @NSManaged public var currency: String?
    @NSManaged public var rate: Double
    @NSManaged public var updatedTime: String?

}

extension LastExchange : Identifiable {

}
