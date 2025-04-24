//
//  LastCurrency+CoreDataProperties.swift
//  ExchangeCalculateApp
//
//  Created by main on 4/24/25.
//
//

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
