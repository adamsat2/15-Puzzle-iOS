//
//  MainView.swift
//  15-Puzzle
//

import SwiftUI
import TipKit

struct MainView: View {
    @Bindable var viewModel: GameViewModel
    
    @State private var isShowingLevelPicker: Bool = false
    @State private var isShowingRestartAlert: Bool = false
    @State private var pendingLevelSwitch: GameLevel? = nil
    @State private var levelButtonFrame: CGRect = .zero
    @State private var containerWidth: CGFloat = 0
    @State private var replayHighlightTrigger: Int = 0
    @State private var levelPickerHighlightTrigger: Int = 0
    @State private var isShowingHexUnavailableHint: Bool = false
    @State private var hexHintDismissTask: Task<Void, Never>? = nil
    
    @State private var postTutorialTips = TipGroup(.ordered) {
        ReplayTip()
        LevelSelectionTip()
    }
    
    private let tutorialTip = PuzzleTutorialTip()
    private let coordinateSpaceName = "MainViewCoordinateSpace"
    
    private var isShowingLevelSwitchAlert: Binding<Bool> {
        Binding(
            get: { pendingLevelSwitch != nil },
            set: { if !$0 { pendingLevelSwitch = nil } }
        )
    }
    
    private var popoverOriginX: CGFloat {
        let width = LevelPickerView.popoverWidth
        guard containerWidth > 0 else { return 16 }
        // Keep the popover balanced horizontally around the Level Selector button without clipping edges
        let idealX = levelButtonFrame.midX - (width / 2)
        return min(max(16, idealX), max(16, containerWidth - width - 16))
    }
    
    private var popoverTailCenterFromTrailing: CGFloat {
        let popoverMaxX = popoverOriginX + LevelPickerView.popoverWidth
        return popoverMaxX - levelButtonFrame.midX
    }
    
    private var popoverScaleAnchor: UnitPoint {
        let width = LevelPickerView.popoverWidth
        let xFraction = (width - popoverTailCenterFromTrailing) / width
        return UnitPoint(x: min(max(xFraction, 0.1), 0.9), y: 0)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 12) {
                HeaderView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                
                // Reserved fixed headroom so "YOU WIN!" and "New Record!" never push the grid
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
                .frame(height: 44)
                
                TabView {
                    HStack(spacing: 20) {
                        StatBoxView(title: "STEPS", value: "\(viewModel.stepCount)")
                        StatBoxView(title: "BEST", value: viewModel.topRecord == 0 ? "--" : "\(viewModel.topRecord)")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 38)
                    
                    HStack(spacing: 20) {
                        StatBoxView(title: "TIME", value: viewModel.elapsedTimeString)
                        StatBoxView(title: "BEST", value: viewModel.bestTimeString)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 38)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 116)
                
                // Board console directly connected beneath the stats/timer, with leftover space at bottom
                VStack(spacing: 14) {
                    BoardToolbarView(
                        isGameWon: viewModel.isGameWon,
                        isHexMode: viewModel.isHexMode,
                        isHexAvailable: viewModel.isHexAvailable,
                        coordinateSpaceName: coordinateSpaceName,
                        replayTip: postTutorialTips.currentTip as? ReplayTip,
                        levelSelectionTip: postTutorialTips.currentTip as? LevelSelectionTip,
                        replayHighlightTrigger: replayHighlightTrigger,
                        levelPickerHighlightTrigger: levelPickerHighlightTrigger,
                        onRestartTapped: handleRestartTapped,
                        onLevelPickerTapped: handleLevelPickerTapped,
                        onColorPaletteTapped: {
                            // Placeholder slot for upcoming Color Palette selector
                        },
                        onHexToggleTapped: handleHexToggleTapped,
                        onLevelButtonFrameChange: { frame in
                            levelButtonFrame = frame
                        }
                    )
                    
                    GameGridView(viewModel: viewModel)
                    
                    if viewModel.selectedLevel == .twoByTwo {
                        TipView(tutorialTip, arrowEdge: .top)
                            .tipBackground(Color(.systemGray6))
                            .tipImageStyle(Color.mint)
                            .frame(maxWidth: GameGridView.standardBoardWidth)
                    }
                }
                
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Contextual hint when tapping HEX on 2×2 or 3×3 boards
            if isShowingHexUnavailableHint {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.mint)
                    
                    Text("Hex mode is available on 4×4 and larger")
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
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .offset(y: levelButtonFrame.maxY + 8)
                .allowsHitTesting(false)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(3)
            }
            
            // Subtle dimming layer so the rest of the app stays visible underneath
            if isShowingLevelPicker {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowingLevelPicker = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                
                LevelPickerView(
                    viewModel: viewModel,
                    tailCenterFromTrailing: popoverTailCenterFromTrailing,
                    onSelectUnlockedLevel: handleUnlockedLevelSelection
                )
                .offset(
                    x: popoverOriginX,
                    y: levelButtonFrame.maxY + 2
                )
                .transition(
                    .scale(scale: 0.88, anchor: popoverScaleAnchor)
                    .combined(with: .opacity)
                )
                .zIndex(2)
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            containerWidth = newWidth
        }
        .onChange(of: viewModel.selectedLevel) { _, _ in
            dismissHexUnavailableHint()
        }
        .onDisappear {
            hexHintDismissTask?.cancel()
        }
        .task {
            for await tip in postTutorialTips.currentTipUpdates {
                if tip is ReplayTip {
                    replayHighlightTrigger += 1
                } else if tip is LevelSelectionTip {
                    levelPickerHighlightTrigger += 1
                }
            }
        }
        .alert("Restart Game?", isPresented: $isShowingRestartAlert) {
            Button("Restart", role: .destructive) {
                viewModel.startNewGame()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current progress will be lost.")
        }
        .alert(
            "Switch to \(pendingLevelSwitch?.title ?? "")?",
            isPresented: isShowingLevelSwitchAlert
        ) {
            Button("Switch", role: .destructive) {
                if let level = pendingLevelSwitch {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectLevel(level)
                    }
                }
                pendingLevelSwitch = nil
            }
            Button("Cancel", role: .cancel) {
                pendingLevelSwitch = nil
            }
        } message: {
            Text("Your current progress will be lost.")
        }
    }
    
    private func handleRestartTapped() {
        dismissHexUnavailableHint()
        
        if viewModel.isLevelCompleted(.twoByTwo) {
            Task.detached(priority: .userInitiated) {
                ReplayTip().invalidate(reason: .actionPerformed)
            }
        }
        
        if isShowingLevelPicker {
            withAnimation(.easeInOut(duration: 0.2)) {
                isShowingLevelPicker = false
            }
        }
        
        if viewModel.hasActiveRun {
            isShowingRestartAlert = true
        } else {
            viewModel.startNewGame()
        }
    }
    
    private func handleLevelPickerTapped() {
        dismissHexUnavailableHint()
        
        Task.detached(priority: .userInitiated) {
            LevelSelectionTip().invalidate(reason: .actionPerformed)
        }
        
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            isShowingLevelPicker.toggle()
        }
    }
    
    private func handleHexToggleTapped() {
        if viewModel.isHexAvailable {
            dismissHexUnavailableHint()
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleHexMode()
            }
        } else {
            showHexUnavailableHint()
        }
    }
    
    private func showHexUnavailableHint() {
        hexHintDismissTask?.cancel()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            isShowingHexUnavailableHint = true
        }
        hexHintDismissTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                isShowingHexUnavailableHint = false
            }
        }
    }
    
    private func dismissHexUnavailableHint() {
        hexHintDismissTask?.cancel()
        guard isShowingHexUnavailableHint else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowingHexUnavailableHint = false
        }
    }
    
    private func handleUnlockedLevelSelection(_ level: GameLevel) {
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowingLevelPicker = false
        }
        
        guard level != viewModel.selectedLevel else { return }
        
        if viewModel.hasActiveRun {
            pendingLevelSwitch = level
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.selectLevel(level)
            }
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
