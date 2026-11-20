//
//  _5_PuzzleApp.swift
//  15-Puzzle
//

import SwiftUI
import TipKit

@main
struct _5_PuzzleApp: App {
    init() {
        try? Tips.configure([
            .displayFrequency(.immediate)
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
