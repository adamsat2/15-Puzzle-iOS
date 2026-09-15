//
//  ContentView.swift
//  15-Puzzle
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()
    
    var body: some View {
        VStack {
            MainView(viewModel: viewModel)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
