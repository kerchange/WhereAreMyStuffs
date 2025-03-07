//
//  StorageAreaImageView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

// StorageAreaImageView.swift
import SwiftUI
import CoreData

struct StorageAreaImageView: View {
    let imagePath: String
    let storagePoints: [StoragePoint]
    @Binding var isAddingStoragePoint: Bool
    @Binding var tappedPosition: CGPoint?
    @State private var imageSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                if let uiImage = loadImage(from: imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit) // Changed to .fit to show entire image
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onAppear {
                            imageSize = geometry.size
                        }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                // Storage Points Markers
                ForEach(storagePoints) { point in
                    StoragePointMarker(storagePoint: point)
                        .position(
                            x: point.xCoordinate * geometry.size.width,
                            y: point.yCoordinate * geometry.size.height
                        )
                }
                
                // Add Mode Overlay
                if isAddingStoragePoint {
                    Color.black.opacity(0.2)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .overlay(
                            Text("Tap to add storage point")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                        )
                        .contentShape(Rectangle()) // Make sure the entire area is tappable
                        .onTapGesture { location in
                            // Convert the tap coordinates to relative values (0.0-1.0)
                            let relativeX = location.x / geometry.size.width
                            let relativeY = location.y / geometry.size.height
                            
                            tappedPosition = CGPoint(x: relativeX, y: relativeY)
                            print("Tap detected at \(location), relative: \(tappedPosition!)")
                        }
                }
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
