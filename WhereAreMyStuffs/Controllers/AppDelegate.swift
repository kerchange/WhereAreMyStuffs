//
//  AppDelegate.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import UIKit
import UserNotifications
import CoreData

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request notification permission
        NotificationManager.shared.requestAuthorization()
        
        // Set the app as notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Schedule notifications for all items with expiry dates
        NotificationManager.shared.scheduleNotificationsForAllItems()
        
        // Clean up items marked for deletion on app launch
        cleanupDeletedItems()
        
        return true
    }
    
    // Add a cleanup function here too, for redundancy
    private func cleanupDeletedItems() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<StorageArea>(entityName: "StorageArea")
        fetchRequest.predicate = NSPredicate(format: "aDeleted == YES")
        
        do {
            let areasToDelete = try context.fetch(fetchRequest)
            
            if !areasToDelete.isEmpty {
                print("App launch cleaning up \(areasToDelete.count) deleted storage areas")
                
                for area in areasToDelete {
                    context.delete(area)
                }
                
                try context.save()
            }
        } catch {
            print("Error cleaning up deleted items: \(error)")
        }
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // Handle user tapping on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // In a real app, you'd navigate to the relevant item detail view
        completionHandler()
    }
}
