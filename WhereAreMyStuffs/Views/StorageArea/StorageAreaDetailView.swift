//
//  StorageAreaDetailView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

// StorageAreaDetailView.swift
import SwiftUI
import CoreData

struct StorageAreaDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    let storageArea: StorageArea
    
    @State private var isAddingStoragePoint = false
    @State private var tappedPosition: CGPoint?
    @State private var showingShareSheet = false
    
    @State private var storagePointToDelete: StoragePoint? = nil
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Storage Area Image with Storage Points
                StorageAreaImageView(
                    imagePath: storageArea.imagePath,
                    storagePoints: storageArea.storagePointsArray,
                    isAddingStoragePoint: $isAddingStoragePoint,
                    tappedPosition: $tappedPosition
                )
                .frame(height: 350) // Increase height to give more space
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Storage Points List
                Text("Storage Points")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                
                if storageArea.storagePointsArray.isEmpty {
                    Text("Tap + to add storage points to this area")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(storageArea.storagePointsArray) { point in
                        NavigationLink(destination: StoragePointDetailView(storagePoint: point)) {
                            StoragePointCell(storagePoint: point)
                        }
                        .contextMenu {
                            Button(action: {
                                storagePointToDelete = point
                                showingDeleteAlert = true
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(storageArea.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isAddingStoragePoint.toggle()
                }) {
                    Image(systemName: isAddingStoragePoint ? "xmark.circle.fill" : "plus.circle")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheetView(storageArea: storageArea)
        }
        .sheet(isPresented: Binding(
            get: { tappedPosition != nil },
            set: { if !$0 { tappedPosition = nil } }
        )) {
            if let position = tappedPosition {
                AddStoragePointView(
                    storageArea: storageArea,
                    position: position,
                    onDismiss: {
                        tappedPosition = nil
                        isAddingStoragePoint = false
                    }
                )
            }
        }
        .onChange(of: tappedPosition) { newPosition in
            print("Tapped position changed to: \(String(describing: newPosition))")
        }
        .onChange(of: isAddingStoragePoint) { isAdding in
            if !isAdding {
                tappedPosition = nil
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Storage Point"),
                message: Text("Are you sure you want to delete '\(storagePointToDelete?.label ?? "")'? This will delete all items within it."),
                primaryButton: .destructive(Text("Delete")) {
                    if let point = storagePointToDelete {
                        deleteStoragePoint(point)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func deleteStoragePoint(_ storagePoint: StoragePoint) {
        // First, get all items in this storage point
        let itemsToDelete = storagePoint.itemsArray
        let itemIDStrings = storagePoint.itemsArray.map { $0.id.uuidString }
        
        // Delete receipt images and cancel notifications for all items
        for item in itemsToDelete {
            // Remove notifications
            NotificationManager.shared.removeExpiryNotification(for: item)
            
            // Delete receipt image if it exists
            if let receiptPath = item.receiptPath, !receiptPath.isEmpty {
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsDirectory.appendingPathComponent(receiptPath)
                try? fileManager.removeItem(at: fileURL)
            }
            
            // Delete the item from Core Data
            viewContext.delete(item)
        }
        
        // Delete the storage point from Core Data
        viewContext.delete(storagePoint)
        
        // Save the changes
        do {
            try viewContext.save()
            for idString in itemIDStrings {
                NotificationManager.shared.removeExpiryNotificationByStringID(idString)
            }
        } catch {
            let nsError = error as NSError
            print("Error deleting storage point: \(nsError)")
        }
    }
}
