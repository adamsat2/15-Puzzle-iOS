//
//  GameGridView.swift
//  15-Puzzle
//

import SwiftUI

struct GameGridView: View {
    @Bindable var viewModel: GameViewModel
    @State private var activeSwipeTile: Int? = nil
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.board, id: \.self) { number in
                TileView(number: number)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                            viewModel.move(number: number)
                        }
                    }
                    // swipe
                    .gesture(
                        DragGesture(minimumDistance: 15)
                            .onChanged { _ in
                                if activeSwipeTile != number {
                                    activeSwipeTile = number
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                                        viewModel.move(number: number)
                                    }
                                }
                            }
                            .onEnded { _ in
                                activeSwipeTile = nil
                            }
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.board)
    }
    
}

#Preview {
    GameGridView(viewModel: GameViewModel())
}
