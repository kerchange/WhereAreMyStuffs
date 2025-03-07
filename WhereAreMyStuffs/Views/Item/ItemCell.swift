//
//  ItemCell.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//
import SwiftUI

struct ItemCell: View {
    let item: Item
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                
                if let description = item.itemDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let expiryDate = item.expiryDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(isExpiringSoon(date: expiryDate) ? .orange : .gray)
                        
                        Text(expiryDateText(for: expiryDate))
                            .font(.caption)
                            .foregroundColor(isExpiringSoon(date: expiryDate) ? .orange : .gray)
                    }
                }
            }
            
            Spacer()
            
            if item.receiptPath != nil {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
            }
        }
    }
    
    private func expiryDateText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Expires: \(formatter.string(from: date))"
    }
    
    private func isExpiringSoon(date: Date) -> Bool {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return days >= 0 && days <= 30
    }
}
