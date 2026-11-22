//
//  ColorPalettePickerView.swift
//  15-Puzzle
//

import SwiftUI

struct ColorPalettePickerView: View {
    @Bindable var viewModel: GameViewModel
    var tailCenterFromTrailing: CGFloat = 143
    let onSelectPalette: (ColorPalette) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var lockedHintMessage: String? = nil
    @State private var hintDismissTask: Task<Void, Never>? = nil
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    private let tailHeight: CGFloat = 9
    static let popoverWidth: CGFloat = 286
    
    private var popoverSurface: Color {
        colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)
    }
    
    private var cardSurface: Color {
        colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.systemGray6)
    }
    
    private var bubbleShape: PopoverBubbleShape {
        PopoverBubbleShape(
            cornerRadius: 16,
            tailWidth: 16,
            tailHeight: tailHeight,
            tailCenterFromTrailing: tailCenterFromTrailing
        )
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(ColorPalette.allPalettes) { palette in
                    let isSelected = viewModel.selectedPalette == palette
                    PalettePreviewCardView(
                        palette: palette,
                        isSelected: isSelected,
                        cardSurface: cardSurface
                    )
                    .onTapGesture {
                        SoundManager.shared.playSound(soundName: "tap")
                        if palette.isUnlocked {
                            onSelectPalette(palette)
                        } else if let hint = palette.lockState.lockHintMessage {
                            showLockedHint(hint)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12 + tailHeight)
            .padding(.bottom, 14)
            .frame(width: Self.popoverWidth)
            .background(
                bubbleShape
                    .fill(popoverSurface)
                    .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 6)
            )
            .clipShape(bubbleShape)
            .overlay(
                bubbleShape
                    .stroke(Color(.separator), lineWidth: 1)
            )
            
            if let message = lockedHintMessage {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(viewModel.selectedPalette.primary)
                    
                    Text(message)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(popoverSurface)
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    Capsule()
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onDisappear {
            hintDismissTask?.cancel()
        }
    }
    
    private func showLockedHint(_ message: String) {
        hintDismissTask?.cancel()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            lockedHintMessage = message
        }
        hintDismissTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                lockedHintMessage = nil
            }
        }
    }
}

private struct PalettePreviewCardView: View {
    let palette: ColorPalette
    let isSelected: Bool
    let cardSurface: Color
    
    var body: some View {
        ZStack {
            VStack(spacing: 6) {
                VStack(spacing: 1) {
                    Text("YOU WIN!")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundStyle(palette.winText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text("NEW RECORD!")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.recordText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 4)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.14), radius: 3, x: 0, y: 1.5)
                    
                    Text("15")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(width: 38, height: 38)
            }
            .opacity(palette.isUnlocked ? 1 : 0.55)
            
            if !palette.isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(cardSurface.opacity(0.9))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 86)
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(cardSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .fill(isSelected ? palette.primary.opacity(0.06) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(isSelected ? palette.primary : Color.clear, lineWidth: 2)
        )
        .shadow(
            color: isSelected ? palette.primary.opacity(0.15) : Color.clear,
            radius: isSelected ? 2 : 0,
            x: 0,
            y: 0
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(palette.name) color palette")
        .accessibilityValue(palette.isUnlocked ? (isSelected ? "Selected" : "") : "Locked")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        ColorPalettePickerView(viewModel: GameViewModel()) { _ in }
    }
}
