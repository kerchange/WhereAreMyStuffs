//
//  AddItemView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let storagePoint: StoragePoint
    let storageArea: StorageArea
    
    @State private var name = ""
    @State private var itemDescription = ""
    @State private var hasExpiryDate = false
    @State private var expiryDate = Date()
    @State private var showingReceiptPicker = false
    @State private var receiptImage: UIImage?
    @State private var showingPhotoOptions = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $itemDescription)
                }
                
                Section(header: Text("Expiry Date")) {
                    Toggle("Has Expiry Date", isOn: $hasExpiryDate)
                    
                    if hasExpiryDate {
                        DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Receipt")) {
                    if let receiptImage = receiptImage {
                        Image(uiImage: receiptImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .padding()
                    }
                    
                    Button(action: {
                        showingPhotoOptions = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text(receiptImage == nil ? "Add Receipt Photo" : "Change Receipt Photo")
                        }
                    }
                }
                
                Section {
                    Button(action: saveItem) {
                        Text("Save Item")
                    }
                    .disabled(name.isEmpty)
                }
            }
            .actionSheet(isPresented: $showingPhotoOptions) {
                ActionSheet(
                    title: Text("Select Receipt Photo"),
                    message: Text("Choose a source for your receipt photo"),
                    buttons: [
                        .default(Text("Camera")) {
                            sourceType = .camera
                            showingReceiptPicker = true
                        },
                        .default(Text("Photo Library")) {
                            sourceType = .photoLibrary
                            showingReceiptPicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .navigationTitle("Add Item")
            .sheet(isPresented: $showingReceiptPicker) {
                ImagePicker(image: $receiptImage, sourceType: sourceType)
            }
        }
    }
    
    private func saveItem() {
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = name
        newItem.itemDescription = itemDescription.isEmpty ? nil : itemDescription
        newItem.expiryDate = hasExpiryDate ? expiryDate : nil
        newItem.createdAt = Date()
        newItem.storagePoint = storagePoint
        newItem.storageArea = storageArea
        
        // Save receipt image if available
        if let image = receiptImage {
            let receiptPath = UUID().uuidString + ".jpg"
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                let fileManager = FileManager.default
                if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsDirectory.appendingPathComponent(receiptPath)
                    try? jpegData.write(to: fileURL)
                    newItem.receiptPath = receiptPath
                }
            }
        }
        
        do {
            try viewContext.save()
                    
            // Post notification that items changed
            NotificationCenter.default.post(name: .itemsDidChange, object: nil)
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving item: \(nsError)")
        }
    }
}
