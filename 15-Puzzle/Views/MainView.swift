//
//  MainView.swift
//  15-Puzzle
//

import SwiftUI

struct MainView: View {
    @Bindable var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            HeaderView()
                .padding(.top, 30)
            
            ZStack {
                if viewModel.isGameWon {
                    VStack(spacing: 4) {
                        Text("YOU WIN!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                        
                        if viewModel.isNewRecord {
                            Text("New Record!")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.pink)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 20)
            
            TabView {
                HStack(spacing: 20) {
                    StatBoxView(title: "STEPS", value: "\(viewModel.stepCount)")
                    StatBoxView(title: "BEST", value: viewModel.topRecord == 0 ? "--" : "\(viewModel.topRecord)")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
                
                HStack(spacing: 20) {
                    StatBoxView(title: "TIME", value: viewModel.elapsedTimeString)
                    StatBoxView(title: "BEST", value: viewModel.bestTimeString)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always)) // Ensures the dots are clearly visible against any background
            .frame(minHeight: 120, idealHeight: 130, maxHeight: 150)
            
            GameGridView(viewModel: viewModel)
            
            Spacer()
            
            Button(action: {
                SoundManager.shared.playSound(soundName: "tap")
                viewModel.startNewGame()
            }) {
                Text(viewModel.isGameWon ? "Play Again" : "Restart Game")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Color.mint
                    )
                    .clipShape(.capsule)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .onAppear {
            viewModel.startNewGame(animated: false)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var viewModel = GameViewModel()
        
        var body: some View {
            MainView(viewModel: viewModel)
        }
    }
    
    return PreviewWrapper()
}
