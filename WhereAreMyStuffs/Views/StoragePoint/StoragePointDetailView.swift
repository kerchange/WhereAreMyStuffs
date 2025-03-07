//
//  StoragePointDetailView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

// StoragePointDetailView.swift
import SwiftUI
import CoreData

struct StoragePointDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    let storagePoint: StoragePoint
    
    @StateObject private var refreshManager = RefreshManager.shared
    @State private var items: [Item] = []
    
    @State private var showingAddItem = false
    @State private var itemToDelete: Item? = nil
    @State private var showingDeleteAlert = false
    @State private var isProcessingDelete = false
    
    var body: some View {
        List {
            Section(header: Text("Items")) {
                if items.isEmpty {
                    Text("No items stored here yet")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(items) { item in
                        if !isProcessingDelete || itemToDelete?.id != item.id {
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                ItemCell(item: item)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    itemToDelete = item
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(storagePoint.label)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddItem = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(storagePoint: storagePoint, storageArea: storagePoint.storageArea)
        }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Item"),
                    message: Text("Are you sure you want to delete '\(itemToDelete?.name ?? "")'? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let item = itemToDelete {
                            deleteItem(item)
                        }
                    },
                    secondaryButton: .cancel() {
                        itemToDelete = nil
                    }
                )
            }
            .disabled(isProcessingDelete)
            .onAppear {
                refreshItemsList()
            }
            .onChange(of: refreshManager.storagePointRefreshID) { _ in
                refreshItemsList()
            }
        }
    
    private func refreshItemsList() {
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "storagePoint.id == %@", storagePoint.id as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.name, ascending: true)]
        
        do {
            items = try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching items: \(error)")
        }
    }
    
    private func deleteItem(_ item: Item) {
        // Mark that we're processing a deletion
        isProcessingDelete = true
        
        // Store needed properties before deletion
        let receiptPath = item.receiptPath
        let itemId = item.id
        
        // Remove any scheduled notifications
        NotificationManager.shared.removeExpiryNotification(for: item)
        
        // Delete the item
        viewContext.delete(item)
        
        // Save the changes
        do {
            try viewContext.save()
            
            // Clean up receipt image if it exists
            if let path = receiptPath, !path.isEmpty {
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsDirectory.appendingPathComponent(path)
                try? fileManager.removeItem(at: fileURL)
            }
            
            // Reset state after a short delay to allow Core Data to update
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                itemToDelete = nil
                isProcessingDelete = false
            }
        } catch {
            let nsError = error as NSError
            print("Error deleting item: \(nsError)")
            // Reset state on error as well
            isProcessingDelete = false
            itemToDelete = nil
        }
    }
}
