//
//  ContentView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

// ContentView.swift - Using aDeleted attribute
import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showingDeleteAlert = false
    @State private var areaNameToDelete = ""
    @State private var areaIDToDelete: UUID?
    
    // Modified fetch request to exclude deleted items
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StorageArea.createdAt, ascending: false)],
        predicate: NSPredicate(format: "aDeleted == NO"),
        animation: .default)
    private var storageAreas: FetchedResults<StorageArea>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText, isSearching: $isSearching)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                
                if isSearching {
                    // Search Results View (pass the predicate to exclude deleted items)
                    SearchView(searchText: searchText, excludeDeleted: true)
                } else {
                    // Storage Areas Grid
                    ScrollView {
                        if storageAreas.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "house.circle")
                                    .font(.system(size: 80))
                                    .foregroundColor(.blue.opacity(0.8))
                                    .padding(.top, 40)
                                
                                Text("Welcome to WhereAreMyStuffs!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Add your first storage area to get started tracking your items")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 40)
                                
                                NavigationLink(destination: AddStorageAreaView()) {
                                    Text("Add Storage Area")
                                        .fontWeight(.semibold)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 24)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 10)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 50)
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(storageAreas) { area in
                                    NavigationLink(destination: StorageAreaDetailView(storageArea: area)) {
                                        StorageAreaCell(storageArea: area)
                                    }
                                    .contextMenu {
                                        Button(action: {
                                            areaIDToDelete = area.id
                                            areaNameToDelete = area.name
                                            showingDeleteAlert = true
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                                
                                // Add new storage area button
                                NavigationLink(destination: AddStorageAreaView()) {
                                    AddStorageAreaCell()
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("WhereAreMyStuffs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Storage Area"),
                    message: Text("Are you sure you want to delete '\(areaNameToDelete)'? This will delete all storage points and items within it."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let idToDelete = areaIDToDelete {
                            markStorageAreaAsDeleted(idToDelete)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                // Run cleanup on app start
                cleanupDeletedItems()
            }
        }
        .onChange(of: searchText) { newValue in
            // Auto-enable search mode when text is entered
            isSearching = !newValue.isEmpty
        }
    }
    
    // Mark as deleted by setting aDeleted to true
    private func markStorageAreaAsDeleted(_ id: UUID) {
        guard let areaToMark = storageAreas.first(where: { $0.id == id }) else {
            return
        }
        
        // Set the deleted flag
        areaToMark.aDeleted = true
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to mark storage area as deleted: \(error)")
        }
    }
    
    // Cleanup function to permanently delete items marked as deleted
    private func cleanupDeletedItems() {
        let fetchRequest = NSFetchRequest<StorageArea>(entityName: "StorageArea")
        fetchRequest.predicate = NSPredicate(format: "aDeleted == YES")
        
        do {
            let areasToDelete = try viewContext.fetch(fetchRequest)
            
            // If there are items to clean up, process them
            if !areasToDelete.isEmpty {
                print("Cleaning up \(areasToDelete.count) deleted storage areas")
                
                // Store file paths for deletion
                var imagePaths: [String] = []
                
                for area in areasToDelete {
                    var itemIDStrings: [String] = []
                    
                    // Collect data from storage points and items
                    if let points = area.storagePoints as? Set<StoragePoint> {
                        for point in points {
                            if let items = point.items as? Set<Item> {
                                for item in items {
                                    itemIDStrings.append(item.id.uuidString)
                                    
                                    // Handle receipt image deletion as before
                                    if let path = item.receiptPath, !path.isEmpty {
                                        // Add to paths for deletion
                                    }
                                }
                            }
                        }
                    }
                    
                    // Delete the storage area
                    viewContext.delete(area)
                    
                    // Save changes
                    try? viewContext.save()
                    
                    // Now cancel all notifications using the stored IDs
                    for idString in itemIDStrings {
                        NotificationManager.shared.removeExpiryNotificationByStringID(idString)
                    }
                }
                
                try viewContext.save()
                
                
                // Clean up files in background
                DispatchQueue.global(qos: .background).async {
                    let fileManager = FileManager.default
                    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    
                    for path in imagePaths {
                        let fileURL = documentsDirectory.appendingPathComponent(path)
                        try? fileManager.removeItem(at: fileURL)
                    }
                }
            }
        } catch {
            print("Error cleaning up deleted items: \(error)")
        }
    }
}
