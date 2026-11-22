//
//  BoardToolbarView.swift
//  15-Puzzle
//

import SwiftUI
import TipKit

struct BoardToolbarView: View {
    let isGameWon: Bool
    let isHexMode: Bool
    let isHexAvailable: Bool
    let primaryColor: Color
    let coordinateSpaceName: String
    let replayTip: ReplayTip?
    let levelSelectionTip: LevelSelectionTip?
    let replayHighlightTrigger: Int
    let levelPickerHighlightTrigger: Int
    let onRestartTapped: () -> Void
    let onLevelPickerTapped: () -> Void
    let onColorPaletteTapped: () -> Void
    let onHexToggleTapped: () -> Void
    let onLevelButtonFrameChange: (CGRect) -> Void
    let onPaletteButtonFrameChange: (CGRect) -> Void
    
    private static let pillButtonWidth: CGFloat = 42
    private static let pillButtonHeight: CGFloat = 44
    private static let pillButtonSpacing: CGFloat = 4
    private static let pillHorizontalPadding: CGFloat = 6
    
    private var isHexBadgeActive: Bool {
        isHexAvailable && isHexMode
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Group 1: Standalone Restart Action
            Button {
                SoundManager.shared.playSound(soundName: "tap")
                onRestartTapped()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(primaryColor)
                    .frame(width: Self.pillButtonHeight, height: Self.pillButtonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        MovingAccentHighlightOverlay(
                            trigger: replayHighlightTrigger,
                            cornerRadius: 12,
                            accentColor: primaryColor
                        )
                    )
            }
            .accessibilityLabel(isGameWon ? "Play Again" : "Restart Game")
            .popoverTip(replayTip, arrowEdge: .top)
            .tipImageStyle(primaryColor)
            
            // Group 2: Grouped Customization Pill
            // Slots: [Level Selector] [Color Palette] [HEX Toggle]
            HStack(spacing: Self.pillButtonSpacing) {
                Button {
                    SoundManager.shared.playSound(soundName: "tap")
                    onLevelPickerTapped()
                } label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(primaryColor)
                        .frame(width: Self.pillButtonWidth, height: Self.pillButtonHeight)
                        .contentShape(Rectangle())
                        .overlay(
                            MovingAccentHighlightOverlay(
                                trigger: levelPickerHighlightTrigger,
                                cornerRadius: 10,
                                accentColor: primaryColor
                            )
                            .padding(.vertical, 2)
                        )
                }
                .accessibilityLabel("Select Level")
                .popoverTip(levelSelectionTip, arrowEdge: .top)
                .tipImageStyle(primaryColor)
                .onGeometryChange(for: CGRect.self) { proxy in
                    proxy.frame(in: .named(coordinateSpaceName))
                } action: { newFrame in
                    onLevelButtonFrameChange(newFrame)
                }
                
                Button {
                    SoundManager.shared.playSound(soundName: "tap")
                    onColorPaletteTapped()
                } label: {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(primaryColor)
                        .frame(width: Self.pillButtonWidth, height: Self.pillButtonHeight)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Color Palette")
                .onGeometryChange(for: CGRect.self) { proxy in
                    proxy.frame(in: .named(coordinateSpaceName))
                } action: { newFrame in
                    onPaletteButtonFrameChange(newFrame)
                }
                
                Button {
                    SoundManager.shared.playSound(soundName: "tap")
                    onHexToggleTapped()
                } label: {
                    HexToggleIcon(
                        isActive: isHexBadgeActive,
                        isAvailable: isHexAvailable,
                        primaryColor: primaryColor
                    )
                    .frame(width: Self.pillButtonWidth, height: Self.pillButtonHeight)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel("Hexadecimal Numbers")
                .accessibilityValue(
                    !isHexAvailable
                        ? "Unavailable on this grid size"
                        : (isHexMode ? "On" : "Off")
                )
                .accessibilityHint(
                    isHexAvailable
                        ? "Toggles tile labels between decimal and hexadecimal"
                        : "Available on 4 by 4 and larger grids"
                )
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

private struct HexToggleIcon: View {
    let isActive: Bool
    let isAvailable: Bool
    let primaryColor: Color
    
    private var foregroundColor: Color {
        if !isAvailable {
            return .secondary
        }
        return isActive ? Color(.systemBackground) : primaryColor
    }
    
    private var borderColor: Color {
        isAvailable ? primaryColor : Color(.tertiaryLabel)
    }
    
    var body: some View {
        Text("HEX")
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .fixedSize()
            .foregroundStyle(foregroundColor)
            .frame(width: 32, height: 22)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isActive ? primaryColor : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.2), value: isActive)
            .animation(.easeInOut(duration: 0.2), value: isAvailable)
    }
}

private struct MovingAccentHighlightOverlay: View {
    let trigger: Int
    let cornerRadius: CGFloat
    let accentColor: Color
    
    @State private var trimStart: CGFloat = 0
    @State private var trimEnd: CGFloat = 0
    @State private var isAnimating: Bool = false
    @State private var animationTask: Task<Void, Never>? = nil
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .trim(from: trimStart, to: trimEnd)
            .stroke(
                accentColor,
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
    VStack(spacing: 16) {
        BoardToolbarView(
            isGameWon: false,
            isHexMode: false,
            isHexAvailable: false,
            primaryColor: .mint,
            coordinateSpaceName: "PreviewSpace1",
            replayTip: nil,
            levelSelectionTip: nil,
            replayHighlightTrigger: 0,
            levelPickerHighlightTrigger: 0,
            onRestartTapped: {},
            onLevelPickerTapped: {},
            onColorPaletteTapped: {},
            onHexToggleTapped: {},
            onLevelButtonFrameChange: { _ in },
            onPaletteButtonFrameChange: { _ in }
        )
        BoardToolbarView(
            isGameWon: false,
            isHexMode: true,
            isHexAvailable: true,
            primaryColor: .purple,
            coordinateSpaceName: "PreviewSpace2",
            replayTip: nil,
            levelSelectionTip: nil,
            replayHighlightTrigger: 0,
            levelPickerHighlightTrigger: 0,
            onRestartTapped: {},
            onLevelPickerTapped: {},
            onColorPaletteTapped: {},
            onHexToggleTapped: {},
            onLevelButtonFrameChange: { _ in },
            onPaletteButtonFrameChange: { _ in }
        )
    }
    .padding()
}
