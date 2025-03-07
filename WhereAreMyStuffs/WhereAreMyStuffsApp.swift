//
//  WhereAreMyStuffsApp.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

@main
struct WhereAreMyStuffsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
        }
    }
}
