//
//  FavoriteExchange+CoreDataProperties.swift
//  ExchangeCalculateApp
//
//  Created by main on 4/24/25.
//
//

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
