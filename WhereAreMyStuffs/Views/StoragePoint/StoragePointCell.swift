//
//  StoragePointCell.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

struct StoragePointCell: View {
    let storagePoint: StoragePoint
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(storagePoint.label.prefix(1).uppercased())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading) {
                Text(storagePoint.label)
                    .font(.headline)
                
                Text("\(storagePoint.itemsArray.count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
