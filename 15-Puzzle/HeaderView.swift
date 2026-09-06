//
//  HeaderView.swift
//  15-Puzzle
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("15 Puzzle")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    Color.mint
                )
            
            Text("Based on the original Mac desk accessory\ncreated by Andy Hertzfeld in 1984.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    HeaderView()
}
