//
//  LastExchange+CoreDataProperties.swift
//  ExchangeCalculateApp
//
//  Created by main on 4/24/25.
//
//

import Foundation
import CoreData


extension LastExchange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastExchange> {
        return NSFetchRequest<LastExchange>(entityName: "LastExchange")
    }

    @NSManaged public var changeRate: Double
    @NSManaged public var currency: String?
    @NSManaged public var rate: Double
    @NSManaged public var updateTime: Int32

}

extension LastExchange : Identifiable {

}
