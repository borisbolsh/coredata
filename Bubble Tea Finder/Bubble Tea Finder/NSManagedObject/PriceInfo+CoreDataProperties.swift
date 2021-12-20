//
//  PriceInfo+CoreDataProperties.swift
//  Bubble Tea Finder
//
//

import Foundation
import CoreData

extension PriceInfo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceInfo> {
        return NSFetchRequest<PriceInfo>(entityName: "PriceInfo")
    }
    
    @NSManaged public var priceCategory: String?
    @NSManaged public var venue: Venue?
    
}
