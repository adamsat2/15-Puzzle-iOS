//
//  TileView.swift
//  15-Puzzle
//

import SwiftUI

struct TileView: View {
    let number: Int
    
    var body: some View {
        ZStack {
            if number != 16 {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                
                Text("\(number)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.mint)
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.clear)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
#Preview {
    TileView(number: 3)
}
