//
//  TileView.swift
//  15-Puzzle
//

import SwiftUI

struct TileView: View {
    let number: Int
    var dimension: Int = 4
    
    private var isBlank: Bool {
        number == dimension * dimension
    }
    
    private var cornerRadius: CGFloat {
        switch dimension {
        case 2: return 16
        case 3, 4: return 14
        case 5: return 11
        default: return 8
        }
    }
    
    private var fontSize: CGFloat {
        switch dimension {
        case 2: return 40
        case 3, 4: return 32
        case 5: return 24
        default: return 18
        }
    }
    
    var body: some View {
        ZStack {
            if !isBlank {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                
                Text("\(number)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(.mint)
                    .padding(4)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    TileView(number: 3, dimension: 4)
}
