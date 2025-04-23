import Foundation
import CoreData


extension LastCurrency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastCurrency> {
        return NSFetchRequest<LastCurrency>(entityName: "LastCurrency")
    }

    @NSManaged public var currency: String?

}

extension LastCurrency : Identifiable {

}
