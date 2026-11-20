//
//  BoardToolbarView.swift
//  15-Puzzle
//

import SwiftUI

struct BoardToolbarView: View {
    let isGameWon: Bool
    let coordinateSpaceName: String
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
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isGameWon ? Color.mint : Color.clear, lineWidth: 1.5)
                    )
            }
            .accessibilityLabel(isGameWon ? "Play Again" : "Restart Game")
            
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
                }
                .accessibilityLabel("Select Level")
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

#Preview {
    BoardToolbarView(
        isGameWon: false,
        coordinateSpaceName: "PreviewSpace",
        onRestartTapped: {},
        onLevelPickerTapped: {},
        onColorPaletteTapped: {},
        onNumberSystemTapped: {},
        onLevelButtonFrameChange: { _ in }
    )
    .padding()
}
