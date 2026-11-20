//
//  GameGridView.swift
//  15-Puzzle
//

import SwiftUI

struct GameGridView: View {
    @Bindable var viewModel: GameViewModel
    @State private var activeSwipeTile: Int? = nil
    
    static let standardBoardWidth: CGFloat = 360
    
    private var spacing: CGFloat {
        switch viewModel.dimension {
        case 2: return 14
        case 3, 4: return 12
        case 5: return 10
        default: return 8
        }
    }
    
    private var innerPadding: CGFloat {
        switch viewModel.dimension {
        case 2, 3, 4: return 16
        case 5: return 14
        default: return 12
        }
    }
    
    private var maxGridWidth: CGFloat {
        switch viewModel.dimension {
        case 2: return 200
        case 3: return 260
        default: return Self.standardBoardWidth
        }
    }
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: viewModel.dimension)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(viewModel.board, id: \.self) { number in
                TileView(number: number, dimension: viewModel.dimension)
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
        .padding(innerPadding)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
        .frame(maxWidth: maxGridWidth)
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.board)
    }
}

#Preview {
    GameGridView(viewModel: GameViewModel())
}
