//
//  ItemDetailView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

// ItemDetailView.swift
import SwiftUI
import CoreData

struct ItemDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    let item: Item
    
    @StateObject private var refreshManager = RefreshManager.shared
    @State private var currentItem: Item?
    
    @State private var showingDeleteAlert = false
    @State private var isDeleted = false
    @State private var showingEditSheet = false
    
    var body: some View {
        Group {
            if let displayItem = currentItem, !isDeleted {
                List {
                    Section(header: Text("Details")) {
                        DetailRow(label: "Name", value: displayItem.name)
                        
                        if let description = displayItem.itemDescription, !description.isEmpty {
                            DetailRow(label: "Description", value: description)
                        }
                        
                        DetailRow(label: "Storage Area", value: displayItem.storageArea.name)
                        DetailRow(label: "Storage Point", value: displayItem.storagePoint.label)
                        
                        if let expiryDate = displayItem.expiryDate {
                            DetailRow(
                                label: "Expires",
                                value: formatDate(expiryDate),
                                icon: "calendar",
                                iconColor: isExpiringSoon(date: expiryDate) ? .orange : .gray
                            )
                        }
                        
                        DetailRow(
                            label: "Added",
                            value: formatDate(displayItem.createdAt),
                            icon: "clock"
                        )
                    }
                    
                    if let receiptPath = displayItem.receiptPath {
                        Section(header: Text("Receipt")) {
                            if let receiptImage = loadImage(from: receiptPath) {
                                Image(uiImage: receiptImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 300)
                                    .padding()
                            } else {
                                Text("Receipt image not available")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle(displayItem.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .sheet(isPresented: $showingEditSheet) {
                    EditItemView(item: item)
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete Item"),
                        message: Text("Are you sure you want to delete '\(displayItem.name)'? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteItem()
                        },
                        secondaryButton: .cancel()
                    )
                }
            } else {
                // Empty view for deleted items
                EmptyView()
            }
        }
        .onAppear {
            refreshItemDetails()
        }
        .onChange(of: refreshManager.itemDetailRefreshID) { _ in
            refreshItemDetails()
        }
    }
    
    private func refreshItemDetails() {
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let refreshedItem = results.first {
                currentItem = refreshedItem
            } else {
                // Item might have been deleted
                isDeleted = true
            }
        } catch {
            print("Error fetching item: \(error)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func isExpiringSoon(date: Date) -> Bool {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return days >= 0 && days <= 30
    }
    
    private func loadImage(from path: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(path)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }
        
        return nil
    }
    
    private func deleteItem() {
        // Store receipt path before deletion
        let receiptPathToDelete = item.receiptPath
        
        // Mark as deleted immediately to prevent UI updates
        isDeleted = true
        
        // Delete the item from Core Data
        viewContext.delete(item)
        
        // Try to save immediately
        do {
            try viewContext.save()
        } catch {
            print("Error during deletion: \(error)")
        }
        
        // Clean up the receipt file if it exists
        if let receiptPath = receiptPathToDelete, !receiptPath.isEmpty {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent(receiptPath)
            try? fileManager.removeItem(at: fileURL)
        }
        
        // Remove notifications
        NotificationManager.shared.removeExpiryNotification(for: item)
        
        // Trigger a refresh of the storage point view
        RefreshManager.shared.refreshStoragePoint()
        
        // Go back after a short delay to ensure everything is processed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
