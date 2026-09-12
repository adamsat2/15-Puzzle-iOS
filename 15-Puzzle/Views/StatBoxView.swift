//
//  StatBoxView.swift
//  15-Puzzle
//

import SwiftUI

struct StatBoxView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .tracking(1.5)
            
            Text(value)
                .font(.title2)
                .fontWeight(.heavy)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
        }
        .frame(minWidth: 80)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    StatBoxView(title: "STEPS", value: "42")
}
