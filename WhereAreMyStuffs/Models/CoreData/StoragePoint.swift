//
//  StoragePoint.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import Foundation
import CoreData

@objc(StoragePoint)
public class StoragePoint: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var xCoordinate: Double
    @NSManaged public var yCoordinate: Double
    @NSManaged public var label: String
    @NSManaged public var createdAt: Date
    @NSManaged public var storageArea: StorageArea
    @NSManaged public var items: NSSet?
    
    public var itemsArray: [Item] {
        let set = items as? Set<Item> ?? []
        return set.sorted { $0.name < $1.name }
    }
}
