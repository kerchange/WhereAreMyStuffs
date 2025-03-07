//
//  RefreshManager.swift
//  WhereAreMyStuffs
//
//  Created by lws on 8/3/2025.
//

// RefreshManager.swift
import Foundation
import SwiftUI

class RefreshManager: ObservableObject {
    static let shared = RefreshManager()
    
    @Published var storagePointRefreshID = UUID()
    @Published var itemDetailRefreshID = UUID()
    
    func refreshStoragePoint() {
        storagePointRefreshID = UUID()
    }
    
    func refreshItemDetail() {
        itemDetailRefreshID = UUID()
    }
}
