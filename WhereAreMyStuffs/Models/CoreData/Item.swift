//
//  Item.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var itemDescription: String?
    @NSManaged public var expiryDate: Date?
    @NSManaged public var receiptPath: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var storagePoint: StoragePoint
    @NSManaged public var storageArea: StorageArea
}
