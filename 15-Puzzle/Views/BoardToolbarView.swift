//
//  BoardToolbarView.swift
//  15-Puzzle
//

import SwiftUI
import TipKit

struct BoardToolbarView: View {
    let isGameWon: Bool
    let coordinateSpaceName: String
    let replayTip: ReplayTip?
    let levelSelectionTip: LevelSelectionTip?
    let replayHighlightTrigger: Int
    let levelPickerHighlightTrigger: Int
    let onRestartTapped: () -> Void
    let onLevelPickerTapped: () -> Void
    let onColorPaletteTapped: () -> Void
    let onNumberSystemTapped: () -> Void
    let onLevelButtonFrameChange: (CGRect) -> Void
    
    private static let pillButtonWidth: CGFloat = 42
    private static let pillButtonHeight: CGFloat = 44
    private static let pillButtonSpacing: CGFloat = 4
    private static let pillHorizontalPadding: CGFloat = 6
    
    var body: some View {
        HStack(spacing: 12) {
            // Group 1: Standalone Restart Action
            Button {
                SoundManager.shared.playSound(soundName: "tap")
                onRestartTapped()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(Color.mint)
                    .frame(width: Self.pillButtonHeight, height: Self.pillButtonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        MovingMintHighlightOverlay(
                            trigger: replayHighlightTrigger,
                            cornerRadius: 12
                        )
                    )
            }
            .accessibilityLabel(isGameWon ? "Play Again" : "Restart Game")
            .popoverTip(replayTip, arrowEdge: .top)
            .tipImageStyle(Color.mint)
            
            // Group 2: Grouped Customization Pill
            // Slots: [Level Selector] [Color Palette (placeholder)] [Number System Toggle (placeholder)]
            HStack(spacing: Self.pillButtonSpacing) {
                Button {
                    SoundManager.shared.playSound(soundName: "tap")
                    onLevelPickerTapped()
                } label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.mint)
                        .frame(width: Self.pillButtonWidth, height: Self.pillButtonHeight)
                        .contentShape(Rectangle())
                        .overlay(
                            MovingMintHighlightOverlay(
                                trigger: levelPickerHighlightTrigger,
                                cornerRadius: 10
                            )
                            .padding(.vertical, 2)
                        )
                }
                .accessibilityLabel("Select Level")
                .popoverTip(levelSelectionTip, arrowEdge: .top)
                .tipImageStyle(Color.mint)
                .onGeometryChange(for: CGRect.self) { proxy in
                    proxy.frame(in: .named(coordinateSpaceName))
                } action: { newFrame in
                    onLevelButtonFrameChange(newFrame)
                }
                
                Button {
                    SoundManager.shared.playSound(soundName: "tap")
                    onColorPaletteTapped()
                } label: {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.mint)
                        .frame(width: Self.pillButtonWidth, height: Self.pillButtonHeight)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Color Palette")
                
                Button {
                    SoundManager.shared.playSound(soundName: "tap")
                    onNumberSystemTapped()
                } label: {
                    Image(systemName: "textformat.123")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mint)
                        .frame(width: Self.pillButtonWidth, height: Self.pillButtonHeight)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Number System")
            }
            .padding(.horizontal, Self.pillHorizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct MovingMintHighlightOverlay: View {
    let trigger: Int
    let cornerRadius: CGFloat
    
    @State private var trimStart: CGFloat = 0
    @State private var trimEnd: CGFloat = 0
    @State private var isAnimating: Bool = false
    @State private var animationTask: Task<Void, Never>? = nil
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .trim(from: trimStart, to: trimEnd)
            .stroke(
                Color.mint,
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
            .opacity(isAnimating ? 1 : 0)
            .allowsHitTesting(false)
            .onChange(of: trigger) { _, newValue in
                guard newValue > 0 else { return }
                playAnimation()
            }
            .onDisappear {
                animationTask?.cancel()
            }
    }
    
    private func playAnimation() {
        animationTask?.cancel()
        trimStart = 0
        trimEnd = 0
        isAnimating = true
        
        animationTask = Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.65)) {
                trimEnd = 1
            }
            
            try? await Task.sleep(for: .milliseconds(180))
            guard !Task.isCancelled else { return }
            
            withAnimation(.easeInOut(duration: 0.65)) {
                trimStart = 1
            }
            
            try? await Task.sleep(for: .milliseconds(680))
            guard !Task.isCancelled else { return }
            
            isAnimating = false
            trimStart = 0
            trimEnd = 0
        }
    }
}

#Preview {
    BoardToolbarView(
        isGameWon: false,
        coordinateSpaceName: "PreviewSpace",
        replayTip: nil,
        levelSelectionTip: nil,
        replayHighlightTrigger: 0,
        levelPickerHighlightTrigger: 0,
        onRestartTapped: {},
        onLevelPickerTapped: {},
        onColorPaletteTapped: {},
        onNumberSystemTapped: {},
        onLevelButtonFrameChange: { _ in }
    )
    .padding()
}
