//
//  GameViewModel.swift
//  15-Puzzle
//

import SwiftUI

@Observable
class GameViewModel {
    var board: [Int] = Array(1...16)
    var isGameWon: Bool = false
    var stepCount: Int = 0
    var isNewRecord: Bool = false
    
    private let timeManager = TimeManager()
    var elapsedTimeString: String = "00:00"
    private var uiTimer: Timer?
    
    // Storing the top record in UserDefaults instead of SwiftData because it's just one integer value
    var topRecord: Int {
        get { UserDefaults.standard.integer(forKey: "Top15PuzzleRecord") }
        set { UserDefaults.standard.set(newValue, forKey: "Top15PuzzleRecord") }
    }
    
    init() {
        startNewGame(animated: false)
    }
    
    func move(number: Int) {
        guard !isGameWon else { return }
        guard let tappedIndex = board.firstIndex(of: number),
              let blankIndex = board.firstIndex(of: 16) else { return }
        
        let tappedRow = tappedIndex / 4
        let tappedCol = tappedIndex % 4
        let blankRow = blankIndex / 4
        let blankCol = blankIndex % 4
        
        if tappedRow == blankRow || tappedCol == blankCol {
            
            let impactMed = UIImpactFeedbackGenerator(style: .light)
            impactMed.impactOccurred()
            
            stepCount += 1
            
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
                handleWinCondition()
            }
        }
    }
    
    private func handleWinCondition() {
        withAnimation {
            isGameWon = true
        }
        
        let currentRecord = topRecord
        
        if currentRecord == 0 || stepCount < currentRecord {
            topRecord = stepCount
            isNewRecord = true
            SoundManager.shared.playSound(soundName: "newrecord")
        } else {
            SoundManager.shared.playSound(soundName: "win")
        }
    }
    
    func startNewGame(animated: Bool = true) {
        isGameWon = false
        stepCount = 0
        isNewRecord = false
        
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
