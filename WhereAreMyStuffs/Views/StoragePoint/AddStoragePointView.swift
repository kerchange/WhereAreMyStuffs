//
//  AddStoragePointView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

struct AddStoragePointView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let storageArea: StorageArea
    let position: CGPoint
    let onDismiss: () -> Void
    
    @State private var label = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Storage Point Details")) {
                    TextField("Label (e.g. Top Drawer, Kitchen Cabinet)", text: $label)
                }
                
                Section {
                    Button(action: saveStoragePoint) {
                        Text("Save Storage Point")
                    }
                    .disabled(label.isEmpty)
                }
            }
            .navigationTitle("Add Storage Point")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private func saveStoragePoint() {
        let newStoragePoint = StoragePoint(context: viewContext)
        newStoragePoint.id = UUID()
        newStoragePoint.label = label
        newStoragePoint.xCoordinate = Double(position.x)
        newStoragePoint.yCoordinate = Double(position.y)
        newStoragePoint.createdAt = Date()
        newStoragePoint.storageArea = storageArea
        
        do {
            try viewContext.save()
            onDismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving storage point: \(nsError)")
        }
    }
}
