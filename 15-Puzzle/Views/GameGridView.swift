//
//  GameGridView.swift
//  15-Puzzle
//

import SwiftUI

struct GameGridView: View {
    @Bindable var viewModel: GameViewModel
    
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
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                                    viewModel.move(number: number)
                                }
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
