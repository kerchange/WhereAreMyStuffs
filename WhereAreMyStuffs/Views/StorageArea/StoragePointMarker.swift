//
//  StoragePointMarker.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI

struct StoragePointMarker: View {
    let storagePoint: StoragePoint
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 30, height: 30)
            
            Text(storagePoint.label.prefix(1).uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}
