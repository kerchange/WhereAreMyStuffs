//
//  ShareSheetView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//
import SwiftUI

struct ShareSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    let storageArea: StorageArea
    
    @State private var email = ""
    @State private var isSharing = false
    @State private var shareStatus: ShareStatus = .notStarted
    
    enum ShareStatus {
        case notStarted
        case processing
        case success
        case failure(String)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Local Storage Only")) {
                    Text("Sharing is only available with a paid Apple Developer account and CloudKit integration.")
                        .foregroundColor(.secondary)
                    
                    // Optional: Keep a simplified UI for future implementation
                    TextField("Email Address (Disabled)", text: $email)
                        .disabled(true)
                }
                
                Section {
                    Button(action: {
                        // Show a message explaining the limitation
                        shareStatus = .failure("Sharing requires CloudKit, which is not currently enabled")
                    }) {
                        Text("Share (Disabled)")
                    }
                    .disabled(true)
                }
                
                if case .failure(let error) = shareStatus {
                    Section {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text(error)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Share Storage Area")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
