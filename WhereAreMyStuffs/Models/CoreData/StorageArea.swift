//
//  StorageArea.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

// StorageArea.swift
import Foundation
import CoreData
import CloudKit

@objc(StorageArea)
public class StorageArea: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var imagePath: String
    @NSManaged public var createdAt: Date
    @NSManaged public var storagePoints: NSSet?
    @NSManaged public var items: NSSet?
    @NSManaged public var isShared: Bool
    @NSManaged public var aDeleted: Bool
    
    public var storagePointsArray: [StoragePoint] {
        let set = storagePoints as? Set<StoragePoint> ?? []
        return set.sorted { $0.createdAt < $1.createdAt }
    }
    
    public var itemsArray: [Item] {
        let set = items as? Set<Item> ?? []
        return set.sorted { $0.name < $1.name }
    }
}
