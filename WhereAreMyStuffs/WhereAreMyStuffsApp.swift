//
//  WhereAreMyStuffsApp.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

@main
struct WhereAreMyStuffsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
