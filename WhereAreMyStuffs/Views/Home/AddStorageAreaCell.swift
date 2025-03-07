//
//  AddStorageAreaCell.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//


import SwiftUI

struct AddStorageAreaCell: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Add New Area")
                .font(.headline)
                .padding(.top, 8)
            
            Spacer()
        }
        .frame(height: 180)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                .padding(1)
        )
    }
}
