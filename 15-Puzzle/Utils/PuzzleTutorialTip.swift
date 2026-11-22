//
//  PuzzleTutorialTip.swift
//  15-Puzzle
//

import SwiftUI
import TipKit

struct PuzzleTutorialTip: Tip {
    static let tutorialCompleted = Tips.Event(id: "tutorialCompleted")
    
    var title: Text {
        Text("How to Play")
    }
    
    var message: Text? {
        Text("Tap or slide tiles into the empty space to order them left-to-right, top-to-bottom (1, 2 on top, then 3 below).")
    }
    
    var image: Image? {
        Image(systemName: "hand.tap.fill")
    }
    
    var options: [any Option] {
        IgnoresDisplayFrequency(true)
    }
}

struct ReplayTip: Tip {
    var title: Text {
        Text("Play Again")
    }
    
    var message: Text? {
        Text("Tap here anytime to start a new round or reshuffle the board.")
    }
    
    var image: Image? {
        Image(systemName: "arrow.counterclockwise")
    }
    
    var rules: [Rule] {
        #Rule(PuzzleTutorialTip.tutorialCompleted) {
            $0.donations.count >= 1
        }
    }
    
    var options: [any Option] {
        IgnoresDisplayFrequency(true)
    }
}

struct LevelSelectionTip: Tip {
    var title: Text {
        Text("Choose a Grid Size")
    }
    
    var message: Text? {
        Text("Tap here to try 3×3 or 4×4, and complete them to unlock 5×5 and 6×6.")
    }
    
    var image: Image? {
        Image(systemName: "square.grid.2x2.fill")
    }
    
    var rules: [Rule] {
        #Rule(PuzzleTutorialTip.tutorialCompleted) {
            $0.donations.count >= 1
        }
    }
    
    var options: [any Option] {
        IgnoresDisplayFrequency(true)
    }
}
