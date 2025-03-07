//
//  StorageAreaCell.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//


import SwiftUI
import CoreData


// StorageAreaCell.swift
struct StorageAreaCell: View {
    let storageArea: StorageArea
    @Environment(\.managedObjectContext) private var viewContext
    @State private var itemCount: Int = 0
    
    var body: some View {
        VStack {
            // Storage Area Image
            if let uiImage = loadImage(from: storageArea.imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .cornerRadius(10)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Storage Area Name
            Text(storageArea.name)
                .font(.headline)
                .lineLimit(1)
                .padding(.top, 4)
            
            // Item Count
            Text("\(itemCount) items")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            updateItemCount()
        }
        .onReceive(NotificationCenter.default.publisher(for: .itemsDidChange)) { _ in
            updateItemCount()
        }
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
    
    private func updateItemCount() {
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "storageArea.id == %@", storageArea.id as CVarArg)
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            itemCount = count
        } catch {
            print("Error counting items: \(error)")
        }
    }
}
