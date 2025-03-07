//
//  NotificationManager.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

// NotificationManager.swift
import Foundation
import UserNotifications
import CoreData

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleExpiryNotification(for item: Item) {
        guard let expiryDate = item.expiryDate else { return }
        
        // Create a notification 3 days before expiry
        let calendar = Calendar.current
        guard let notificationDate = calendar.date(byAdding: .day, value: -3, to: expiryDate) else { return }
        
        // Only schedule if the notification date is in the future
        if notificationDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Item Expiring Soon"
            content.body = "\(item.name) in \(item.storageArea.name) (\(item.storagePoint.label)) will expire in 3 days."
            content.sound = .default
            
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Store the ID as a string first
            let idString = item.id.uuidString
            let request = UNNotificationRequest(identifier: "expiry-\(idString)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    // New method that takes a UUID directly
    func removeExpiryNotificationByID(_ itemID: UUID) {
        let notificationID = "expiry-\(itemID.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
    
    // Keep this method for convenience, but extract the ID immediately
    func removeExpiryNotification(for item: Item) {
        let itemID = item.id
        removeExpiryNotificationByID(itemID)
    }
    
    func removeExpiryNotificationByStringID(_ idString: String) {
        let notificationID = "expiry-\(idString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
    
    func scheduleNotificationsForAllItems() {
        // Get all items with expiry dates from Core Data
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "expiryDate != nil")
        
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                scheduleExpiryNotification(for: item)
            }
        } catch {
            print("Error fetching items for notifications: \(error)")
        }
    }
}
