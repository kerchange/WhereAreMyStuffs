//
//  DetailRow.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    var iconColor: Color = .gray
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .padding(.trailing, 4)
            }
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}
