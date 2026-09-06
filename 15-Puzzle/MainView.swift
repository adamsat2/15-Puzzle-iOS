//
//  MainView.swift
//  15-Puzzle
//

import SwiftUI

struct MainView: View {
    @State var board: [Int] = Array(1...16)
    @State private var isGameWon: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            HeaderView()
                .padding(.top, 20)
            
            ZStack {
                if isGameWon {
                    Text("YOU WIN!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 30)
            
            GameGridView(board: $board, isGameWon: $isGameWon)
            
            Spacer()
            
            Button(action: {
                startNewGame()
            }) {
                Text(isGameWon ? "Play Again" : "Restart Game")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Color.mint
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .onAppear {
            startNewGame(animated: false)
        }
    }
    
    
    // Helper functions
    
    private func startNewGame(animated: Bool = true) {
        isGameWon = false
        
        var tempBoard = Array(1...16)
        var currentBlankIndex = 15
        
        // Simulate random legal moves to ensure the puzzle is solvable
        for _ in 0..<150 {
            let possibleMoves = getValidMoves(for: currentBlankIndex)
            if let randomMove = possibleMoves.randomElement() {
                tempBoard.swapAt(currentBlankIndex, randomMove)
                currentBlankIndex = randomMove
            }
        }
        
        if animated {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.board = tempBoard
            }
        } else {
            self.board = tempBoard
        }
    }
    
    private func getValidMoves(for blankIndex: Int) -> [Int] {
        var moves: [Int] = []
        let row = blankIndex / 4
        let col = blankIndex % 4
        
        if row > 0 { moves.append(blankIndex - 4) } // up
        if row < 3 { moves.append(blankIndex + 4) } // down
        if col > 0 { moves.append(blankIndex - 1) } // left
        if col < 3 { moves.append(blankIndex + 1) } // right
        
        return moves
    }
}

#Preview {
    MainView()
}
