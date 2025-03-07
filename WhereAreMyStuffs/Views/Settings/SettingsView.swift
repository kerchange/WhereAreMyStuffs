//
//  SettingsView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("daysBeforeExpiry") private var daysBeforeExpiry = 3
    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled = true
    
    @State private var showingLogoutAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("User Profile")) {
                TextField("Your Name", text: $username)
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Enable Expiry Notifications", isOn: $notificationsEnabled)
                
                if notificationsEnabled {
                    Stepper(value: $daysBeforeExpiry, in: 1...14) {
                        Text("Notify \(daysBeforeExpiry) days before expiry")
                    }
                }
                
                Button("Test Notification") {
                    sendTestNotification()
                }
                .disabled(!notificationsEnabled)
            }
            
            Section(header: Text("Storage")) {
                // Comment out or disable CloudKit toggle
                // Toggle("Enable iCloud Sync", isOn: $cloudSyncEnabled)
                Text("iCloud sync requires a paid Apple Developer account")
                    .foregroundColor(.secondary)
                
                Button("Clear Image Cache") {
                    clearImageCache()
                }
                .foregroundColor(.orange)
            }
            
            Section(header: Text("Account")) {
                Button("Log Out") {
                    showingLogoutAlert = true
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("Log Out"),
                message: Text("Are you sure you want to log out? Your data will remain synced to your iCloud account."),
                primaryButton: .destructive(Text("Log Out")) {
                    // In a real app, this would implement actual logout logic
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from WhereAreMyStuffs"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error)")
            }
        }
    }
    
    private func clearImageCache() {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
                for fileURL in fileURLs where fileURL.pathExtension == "jpg" {
                    try fileManager.removeItem(at: fileURL)
                }
            } catch {
                print("Error clearing image cache: \(error)")
            }
        }
    }
}
