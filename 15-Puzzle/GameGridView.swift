//
//  GameGridView.swift
//  15-Puzzle
//

import SwiftUI

struct GameGridView: View {
    @Binding var board: [Int]
    @Binding var isGameWon: Bool
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(board, id: \.self) { number in
                TileView(number: number)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                            move(number: number)
                        }
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: board)
    }
    
    private func move(number: Int) {
        guard !isGameWon else { return }
        guard let tappedIndex = board.firstIndex(of: number),
              let blankIndex = board.firstIndex(of: 16) else { return }
        
        let tappedRow = tappedIndex / 4
        let tappedCol = tappedIndex % 4
        let blankRow = blankIndex / 4
        let blankCol = blankIndex % 4
        
        if tappedRow == blankRow || tappedCol == blankCol {
            
            // Determine the direction to shift items
            let step: Int
            if tappedRow == blankRow {
                step = tappedIndex < blankIndex ? -1 : 1
            } else {
                step = tappedIndex < blankIndex ? -4 : 4
            }
            
            var curr = blankIndex
            while curr != tappedIndex {
                let next = curr + step
                board.swapAt(curr, next)
                curr = next
            }
            
            if board == Array(1...16) {
                withAnimation {
                    isGameWon = true
                }
            }
        }
    }
    
}

#Preview {
    @Previewable @State var board: [Int] = Array(1...16)
    @Previewable @State var isGameWon: Bool = true
    GameGridView(board: $board, isGameWon: $isGameWon)
}
