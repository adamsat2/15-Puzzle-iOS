//
//  ContentView.swift
//  15-Puzzle
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MainView(viewModel: GameViewModel())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
