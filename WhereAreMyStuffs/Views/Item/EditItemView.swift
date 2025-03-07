//
//  EditItemView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 6/3/2025.
//

// EditItemView.swift
import SwiftUI

struct EditItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // Original item to edit
    let item: Item
    let storagePoint: StoragePoint
    let storageArea: StorageArea
    
    // State for edited values
    @State private var name: String
    @State private var itemDescription: String
    @State private var hasExpiryDate: Bool
    @State private var expiryDate: Date
    @State private var showingReceiptPicker = false
    @State private var showingPhotoOptions = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var receiptImage: UIImage?
    @State private var originalReceiptPath: String?
    
    // Initialize with item's current values
    init(item: Item) {
        self.item = item
        self.storagePoint = item.storagePoint
        self.storageArea = item.storageArea
        
        // Set initial state values from the item
        _name = State(initialValue: item.name)
        _itemDescription = State(initialValue: item.itemDescription ?? "")
        _hasExpiryDate = State(initialValue: item.expiryDate != nil)
        _expiryDate = State(initialValue: item.expiryDate ?? Date())
        _originalReceiptPath = State(initialValue: item.receiptPath)
        
        // Load the receipt image if it exists
        if let receiptPath = item.receiptPath, !receiptPath.isEmpty {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent(receiptPath)
            
            if fileManager.fileExists(atPath: fileURL.path) {
                _receiptImage = State(initialValue: UIImage(contentsOfFile: fileURL.path))
            }
        }
    }
    
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
                    
                    if receiptImage != nil {
                        Button(action: {
                            receiptImage = nil
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Remove Receipt Photo")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: saveItem) {
                        Text("Save Changes")
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
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
            .sheet(isPresented: $showingReceiptPicker) {
                ImagePicker(image: $receiptImage, sourceType: sourceType)
            }
        }
    }
    
    private func saveItem() {
        // Update the item with edited values
        item.name = name
        item.itemDescription = itemDescription.isEmpty ? nil : itemDescription
        item.expiryDate = hasExpiryDate ? expiryDate : nil
        
        // Handle receipt image changes
        if receiptImage != nil && receiptImage != UIImage(contentsOfFile: originalReceiptPath ?? "") {
            // Delete old receipt if there was one
            if let oldPath = originalReceiptPath, !oldPath.isEmpty {
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let oldFileURL = documentsDirectory.appendingPathComponent(oldPath)
                try? fileManager.removeItem(at: oldFileURL)
            }
            
            // Save new receipt image
            let receiptPath = UUID().uuidString + ".jpg"
            if let jpegData = receiptImage?.jpegData(compressionQuality: 0.8) {
                let fileManager = FileManager.default
                if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsDirectory.appendingPathComponent(receiptPath)
                    try? jpegData.write(to: fileURL)
                    item.receiptPath = receiptPath
                }
            }
        } else if receiptImage == nil {
            // Remove receipt if it was deleted
            if let oldPath = originalReceiptPath, !oldPath.isEmpty {
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let oldFileURL = documentsDirectory.appendingPathComponent(oldPath)
                try? fileManager.removeItem(at: oldFileURL)
            }
            item.receiptPath = nil
        }
        
        // Update notifications if expiry date changed
        NotificationManager.shared.removeExpiryNotification(for: item)
        if hasExpiryDate {
            NotificationManager.shared.scheduleExpiryNotification(for: item)
        }
        
        // Save changes
        do {
            try viewContext.save()
            
            // Notify that items have changed
            NotificationCenter.default.post(name: .itemsDidChange, object: nil)
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error updating item: \(nsError)")
        }
    }
}
