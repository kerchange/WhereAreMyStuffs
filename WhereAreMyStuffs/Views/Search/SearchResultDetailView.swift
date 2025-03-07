//
//  SearchResultDetailView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

struct SearchResultDetailView: View {
    let item: Item
    
    var body: some View {
        VStack {
            // Storage Area Image with a pin at item location
            StorageAreaHighlightView(item: item)
                .frame(height: 350) // Increase height to give more space
                .cornerRadius(12)
                .padding()
            
            // Item details
            List {
                Section(header: Text("Item Details")) {
                    DetailRow(label: "Name", value: item.name)
                    
                    if let description = item.itemDescription, !description.isEmpty {
                        DetailRow(label: "Description", value: description)
                    }
                    
                    if let expiryDate = item.expiryDate {
                        DetailRow(
                            label: "Expires",
                            value: formatDate(expiryDate),
                            icon: "calendar"
                        )
                    }
                }
                
                Section(header: Text("Location")) {
                    DetailRow(label: "Storage Area", value: item.storageArea.name)
                    DetailRow(label: "Storage Point", value: item.storagePoint.label)
                    
                    NavigationLink(destination: StorageAreaDetailView(storageArea: item.storageArea)) {
                        Label("View Storage Area", systemImage: "arrow.right")
                    }
                }
            }
        }
        .navigationTitle(item.name)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
