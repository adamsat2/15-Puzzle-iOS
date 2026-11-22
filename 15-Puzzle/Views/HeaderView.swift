//
//  HeaderView.swift
//  15-Puzzle
//

import SwiftUI

struct HeaderView: View {
    var primaryColor: Color = .mint
    
    var body: some View {
        VStack(spacing: 6) {
            Text("15 Puzzle")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(primaryColor)
            
            Text("Based on the original Mac desk accessory\ncreated by Andy Hertzfeld in 1984.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    HeaderView()
}
