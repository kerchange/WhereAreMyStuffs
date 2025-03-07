//
//  AddStorageAreaView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

// AddStorageAreaView.swift
import SwiftUI

struct AddStorageAreaView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var showingImagePicker = false
    @State private var showingPhotoOptions = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var inputImage: UIImage?
    @State private var imagePath: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Storage Area Details")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Storage Area Photo")) {
                    if let inputImage = inputImage {
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .padding()
                    }
                    
                    Button(action: {
                        showingPhotoOptions = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text(inputImage == nil ? "Add Photo" : "Change Photo")
                        }
                    }
                }
                
                Section {
                    Button(action: saveStorageArea) {
                        Text("Save Storage Area")
                    }
                    .disabled(name.isEmpty || inputImage == nil)
                }
            }
            .navigationTitle("Add Storage Area")
            .actionSheet(isPresented: $showingPhotoOptions) {
                ActionSheet(
                    title: Text("Select Photo"),
                    message: Text("Choose a source for your storage area photo"),
                    buttons: [
                        .default(Text("Camera")) {
                            sourceType = .camera
                            showingImagePicker = true
                        },
                        .default(Text("Photo Library")) {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage, sourceType: sourceType)
            }
        }
    }
    
    private func saveStorageArea() {
        guard let image = inputImage else { return }
        
        // Save image to document directory
        let imagePath = UUID().uuidString + ".jpg"
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            // Create directory if not exists
            let fileManager = FileManager.default
            if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(imagePath)
                try? jpegData.write(to: fileURL)
                
                // Create the storage area
                let newStorageArea = StorageArea(context: viewContext)
                newStorageArea.id = UUID()
                newStorageArea.name = name
                newStorageArea.imagePath = imagePath
                newStorageArea.createdAt = Date()
                newStorageArea.aDeleted = false
                
                do {
                    try viewContext.save()
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    let nsError = error as NSError
                    print("Error saving storage area: \(nsError)")
                }
            }
        }
    }
}
