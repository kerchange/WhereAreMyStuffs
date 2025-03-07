//
//  StorageAreaHighlightView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

struct StorageAreaHighlightView: View {
    let item: Item
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                if let uiImage = loadImage(from: item.storageArea.imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit) // Changed to .fit to show entire image
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                // Highlight the storage point containing the item
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .position(
                        x: item.storagePoint.xCoordinate * geometry.size.width,
                        y: item.storagePoint.yCoordinate * geometry.size.height
                    )
                
                // Storage Point Marker
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                    
                    Text(item.storagePoint.label.prefix(1).uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .position(
                    x: item.storagePoint.xCoordinate * geometry.size.width,
                    y: item.storagePoint.yCoordinate * geometry.size.height
                )
            }
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
}
