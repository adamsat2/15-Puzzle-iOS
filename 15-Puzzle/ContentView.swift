//
//  ContentView.swift
//  15-Puzzle
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()
    
    var body: some View {
        MainView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
