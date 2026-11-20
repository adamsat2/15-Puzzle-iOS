//
//  LevelPickerView.swift
//  15-Puzzle
//

import SwiftUI

struct PopoverBubbleShape: Shape {
    var cornerRadius: CGFloat = 16
    var tailWidth: CGFloat = 16
    var tailHeight: CGFloat = 9
    var tailCenterFromTrailing: CGFloat = 24
    
    func path(in rect: CGRect) -> Path {
        let bodyRect = CGRect(
            x: rect.minX,
            y: rect.minY + tailHeight,
            width: rect.width,
            height: rect.height - tailHeight
        )
        
        let tailCenterX = min(
            max(bodyRect.maxX - tailCenterFromTrailing, bodyRect.minX + cornerRadius + tailWidth / 2),
            bodyRect.maxX - cornerRadius - tailWidth / 2
        )
        let tailLeftX = tailCenterX - tailWidth / 2
        let tailRightX = tailCenterX + tailWidth / 2
        
        var path = Path()
        
        // Start at top-left after corner
        path.move(to: CGPoint(x: bodyRect.minX + cornerRadius, y: bodyRect.minY))
        
        // Nub/tail connected to the level selector button
        path.addLine(to: CGPoint(x: tailLeftX, y: bodyRect.minY))
        path.addLine(to: CGPoint(x: tailCenterX, y: rect.minY))
        path.addLine(to: CGPoint(x: tailRightX, y: bodyRect.minY))
        
        // Top-right corner
        path.addArc(
            tangent1End: CGPoint(x: bodyRect.maxX, y: bodyRect.minY),
            tangent2End: CGPoint(x: bodyRect.maxX, y: bodyRect.minY + cornerRadius),
            radius: cornerRadius
        )
        
        // Bottom-right corner
        path.addArc(
            tangent1End: CGPoint(x: bodyRect.maxX, y: bodyRect.maxY),
            tangent2End: CGPoint(x: bodyRect.maxX - cornerRadius, y: bodyRect.maxY),
            radius: cornerRadius
        )
        
        // Bottom-left corner
        path.addArc(
            tangent1End: CGPoint(x: bodyRect.minX, y: bodyRect.maxY),
            tangent2End: CGPoint(x: bodyRect.minX, y: bodyRect.maxY - cornerRadius),
            radius: cornerRadius
        )
        
        // Top-left corner
        path.addArc(
            tangent1End: CGPoint(x: bodyRect.minX, y: bodyRect.minY),
            tangent2End: CGPoint(x: bodyRect.minX + cornerRadius, y: bodyRect.minY),
            radius: cornerRadius
        )
        
        path.closeSubpath()
        return path
    }
}

struct LevelPickerView: View {
    @Bindable var viewModel: GameViewModel
    var tailCenterFromTrailing: CGFloat = 143
    let onSelectUnlockedLevel: (GameLevel) -> Void
    
    @State private var lockedHintMessage: String? = nil
    @State private var hintDismissTask: Task<Void, Never>? = nil
    
    private let rows = [GridItem(.fixed(90))]
    private let tailHeight: CGFloat = 9
    static let popoverWidth: CGFloat = 286
    
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
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 12) {
                        ForEach(GameLevel.allCases) { level in
                            let isUnlocked = viewModel.isLevelUnlocked(level)
                            LevelCardView(
                                level: level,
                                isSelected: viewModel.selectedLevel == level,
                                isCompleted: viewModel.isLevelCompleted(level),
                                isUnlocked: isUnlocked
                            )
                            .id(level)
                            .onTapGesture {
                                SoundManager.shared.playSound(soundName: "tap")
                                if isUnlocked {
                                    onSelectUnlockedLevel(level)
                                } else if let hint = viewModel.lockHintMessage(for: level) {
                                    showLockedHint(hint)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
                .onAppear {
                    proxy.scrollTo(viewModel.selectedLevel, anchor: .center)
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            proxy.scrollTo(viewModel.selectedLevel, anchor: .center)
                        }
                    }
                }
            }
            .padding(.top, tailHeight)
            .frame(width: Self.popoverWidth, height: 114 + tailHeight)
            .background(
                bubbleShape
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
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
                        .foregroundStyle(Color.mint)
                    
                    Text(message)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(.systemBackground))
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

private struct LevelCardView: View {
    let level: GameLevel
    let isSelected: Bool
    let isCompleted: Bool
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                MiniMatrixPreview(
                    dimension: level.dimension,
                    isUnlocked: isUnlocked
                )
                .frame(width: 38, height: 38)
                .opacity(isUnlocked ? 1 : 0.6)
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(level.title)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(titleColor)
                .opacity(isUnlocked ? 1 : 0.6)
        }
        .frame(width: 78, height: 86)
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(Color(.systemGray6))
        )
        .overlay(alignment: .bottomTrailing) {
            if isCompleted {
                ZStack {
                    Circle()
                        .fill(Color.mint)
                        .frame(width: 17, height: 17)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(5)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(isSelected ? Color.mint : Color.clear, lineWidth: 2)
        )
        .shadow(
            color: isSelected ? Color.mint : Color.clear,
            radius: isSelected ? 4 : 0,
            x: 0,
            y: 0
        )
    }
    
    private var titleColor: Color {
        if !isUnlocked {
            return .secondary
        }
        return isSelected ? .mint : .primary
    }
}

private struct MiniMatrixPreview: View {
    let dimension: Int
    let isUnlocked: Bool
    
    var body: some View {
        let spacing: CGFloat = dimension >= 5 ? 1.5 : 2
        VStack(spacing: spacing) {
            ForEach(0..<dimension, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<dimension, id: \.self) { col in
                        let isLast = (row == dimension - 1 && col == dimension - 1)
                        RoundedRectangle(cornerRadius: dimension >= 5 ? 1 : 2)
                            .fill(tileFill(isLast: isLast))
                    }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(.systemBackground))
        )
    }
    
    private func tileFill(isLast: Bool) -> Color {
        if isLast {
            return .clear
        }
        return isUnlocked ? .mint : Color(.systemGray3)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        LevelPickerView(viewModel: GameViewModel()) { _ in }
    }
}
