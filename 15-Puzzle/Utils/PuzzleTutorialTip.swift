//
//  PuzzleTutorialTip.swift
//  15-Puzzle
//

import SwiftUI
import TipKit

struct PuzzleTutorialTip: Tip {
    @Parameter
    static var isShowingTutorialLevel: Bool = false
    
    var title: Text {
        Text("How to Play")
    }
    
    var message: Text? {
        Text("Tap or slide tiles into the empty space to order them left-to-right, top-to-bottom (1, 2 on top, then 3 below).")
    }
    
    var image: Image? {
        Image(systemName: "hand.tap.fill")
    }
    
    var rules: [Rule] {
        #Rule(Self.$isShowingTutorialLevel) {
            $0 == true
        }
    }
    
    var options: [any Option] {
        IgnoresDisplayFrequency(true)
    }
}
