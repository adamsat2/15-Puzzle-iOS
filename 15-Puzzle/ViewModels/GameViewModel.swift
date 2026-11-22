//
//  GameViewModel.swift
//  15-Puzzle
//

import SwiftUI
import TipKit

enum GameLevel: Int, CaseIterable, Identifiable {
    case twoByTwo = 2
    case threeByThree = 3
    case fourByFour = 4
    case fiveByFive = 5
    case sixBySix = 6
    
    var id: Int { rawValue }
    var dimension: Int { rawValue }
    var totalTiles: Int { dimension * dimension }
    var title: String { "\(dimension)×\(dimension)" }
    var tileRangeDescription: String { "1 - \(totalTiles - 1)" }
    var supportsHexMode: Bool { dimension >= 4 }
    
    var stepRecordKey: String {
        dimension == 4 ? "Top15PuzzleRecord" : "Top15PuzzleRecord_\(dimension)x\(dimension)"
    }
    
    var timeRecordKey: String {
        dimension == 4 ? "Best15PuzzleTime" : "Best15PuzzleTime_\(dimension)x\(dimension)"
    }
}

@Observable
class GameViewModel {
    private static let lastSelectedLevelKey = "LastSelectedPuzzleLevel"
    private static let isHexModeKey = "IsHexModeEnabled"
    
    var selectedLevel: GameLevel = .twoByTwo
    var board: [Int] = Array(1...4)
    var isGameWon: Bool = false
    var stepCount: Int = 0
    var isNewRecord: Bool = false
    var isHexMode: Bool = false {
        didSet {
            UserDefaults.standard.set(isHexMode, forKey: Self.isHexModeKey)
        }
    }
    
    private let timeManager = TimeManager()
    var elapsedTimeString: String = "00:00"
    private var uiTimer: Timer?
    private var recordsUpdateTrigger: Int = 0
    
    var dimension: Int {
        selectedLevel.dimension
    }
    
    var totalTiles: Int {
        selectedLevel.totalTiles
    }
    
    var isHexAvailable: Bool {
        selectedLevel.supportsHexMode
    }
    
    var isHexActiveOnBoard: Bool {
        isHexMode && isHexAvailable
    }
    
    var hasActiveRun: Bool {
        stepCount > 0 && !isGameWon
    }
    
    // Storing the top record in UserDefaults per level
    var topRecord: Int {
        get {
            _ = recordsUpdateTrigger
            return UserDefaults.standard.integer(forKey: selectedLevel.stepRecordKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedLevel.stepRecordKey)
            recordsUpdateTrigger += 1
        }
    }
    
    var bestTimeRecord: TimeInterval {
        get {
            _ = recordsUpdateTrigger
            return UserDefaults.standard.double(forKey: selectedLevel.timeRecordKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedLevel.timeRecordKey)
            recordsUpdateTrigger += 1
        }
    }
    
    var bestTimeString: String {
        bestTimeRecord == 0 ? "--:--" : formatTime(bestTimeRecord)
    }
    
    init() {
        isHexMode = UserDefaults.standard.bool(forKey: Self.isHexModeKey)
        selectedLevel = Self.initialLevel()
        startNewGame(animated: false)
    }
    
    func toggleHexMode() {
        guard isHexAvailable else { return }
        isHexMode.toggle()
    }
    
    private static func initialLevel() -> GameLevel {
        let savedRaw = UserDefaults.standard.integer(forKey: lastSelectedLevelKey)
        if let savedLevel = GameLevel(rawValue: savedRaw), isLevelUnlockedStatic(savedLevel) {
            return savedLevel
        }
        // First launch starts on the 2×2 tutorial level
        return .twoByTwo
    }
    
    private static func isLevelCompletedStatic(_ level: GameLevel) -> Bool {
        UserDefaults.standard.integer(forKey: level.stepRecordKey) > 0
            || UserDefaults.standard.double(forKey: level.timeRecordKey) > 0
    }
    
    private static func isLevelUnlockedStatic(_ level: GameLevel) -> Bool {
        switch level {
        case .twoByTwo, .threeByThree, .fourByFour:
            return true
        case .fiveByFive:
            return isLevelCompletedStatic(.twoByTwo)
                && isLevelCompletedStatic(.threeByThree)
                && isLevelCompletedStatic(.fourByFour)
        case .sixBySix:
            return isLevelUnlockedStatic(.fiveByFive)
                && isLevelCompletedStatic(.fiveByFive)
        }
    }
    
    func topRecord(for level: GameLevel) -> Int {
        _ = recordsUpdateTrigger
        return UserDefaults.standard.integer(forKey: level.stepRecordKey)
    }
    
    func bestTimeRecord(for level: GameLevel) -> TimeInterval {
        _ = recordsUpdateTrigger
        return UserDefaults.standard.double(forKey: level.timeRecordKey)
    }
    
    func bestTimeString(for level: GameLevel) -> String {
        let time = bestTimeRecord(for: level)
        return time == 0 ? "--:--" : formatTime(time)
    }
    
    func isLevelCompleted(_ level: GameLevel) -> Bool {
        topRecord(for: level) > 0 || bestTimeRecord(for: level) > 0
    }
    
    func isLevelUnlocked(_ level: GameLevel) -> Bool {
        switch level {
        case .twoByTwo, .threeByThree, .fourByFour:
            return true
        case .fiveByFive:
            return isLevelCompleted(.twoByTwo)
                && isLevelCompleted(.threeByThree)
                && isLevelCompleted(.fourByFour)
        case .sixBySix:
            return isLevelUnlocked(.fiveByFive) && isLevelCompleted(.fiveByFive)
        }
    }
    
    func lockHintMessage(for level: GameLevel) -> String? {
        guard !isLevelUnlocked(level) else { return nil }
        
        switch level {
        case .fiveByFive:
            let required: [GameLevel] = [.twoByTwo, .threeByThree, .fourByFour]
            let remaining = required.filter { !isLevelCompleted($0) }.map(\.title)
            let formattedList: String
            switch remaining.count {
            case 1:
                formattedList = remaining[0]
            case 2:
                formattedList = "\(remaining[0]) & \(remaining[1])"
            default:
                formattedList = "\(remaining[0]), \(remaining[1]) & \(remaining[2])"
            }
            return "Complete \(formattedList) to unlock 5×5"
        case .sixBySix:
            return "Complete 5×5 to unlock 6×6"
        default:
            return nil
        }
    }
    
    func selectLevel(_ level: GameLevel) {
        guard isLevelUnlocked(level), level != selectedLevel else { return }
        selectedLevel = level
        UserDefaults.standard.set(level.rawValue, forKey: Self.lastSelectedLevelKey)
        startNewGame(animated: false)
    }
    
    func move(number: Int) {
        guard !isGameWon else { return }
        
        if !timeManager.isRunning && stepCount == 0 {
            timeManager.startTimer()
            startUITimer()
        }
        
        let dim = dimension
        let blankTile = totalTiles
        
        guard let tappedIndex = board.firstIndex(of: number),
              let blankIndex = board.firstIndex(of: blankTile) else { return }
        
        let tappedRow = tappedIndex / dim
        let tappedCol = tappedIndex % dim
        let blankRow = blankIndex / dim
        let blankCol = blankIndex % dim
        
        if tappedRow == blankRow || tappedCol == blankCol {
            let impactMed = UIImpactFeedbackGenerator(style: .light)
            impactMed.impactOccurred()
            
            stepCount += 1
            
            // Determine the direction to shift items
            let step: Int
            if tappedRow == blankRow {
                step = tappedIndex < blankIndex ? -1 : 1
            } else {
                step = tappedIndex < blankIndex ? -dim : dim
            }
            
            var curr = blankIndex
            while curr != tappedIndex {
                let next = curr + step
                board.swapAt(curr, next)
                curr = next
            }
            
            if board == Array(1...blankTile) {
                handleWinCondition()
            }
        }
    }
    
    private func handleWinCondition() {
        timeManager.pauseTimer()
        uiTimer?.invalidate()
        
        withAnimation {
            isGameWon = true
        }
        
        let wonTutorialLevel = (selectedLevel == .twoByTwo)
        
        let currentStepRecord = topRecord
        let currentTimeRecord = bestTimeRecord
        let finalTime = timeManager.totalElapsedTime
        
        var brokeRecord = false
        
        if currentStepRecord == 0 || stepCount < currentStepRecord {
            topRecord = stepCount
            brokeRecord = true
        }
        if currentTimeRecord == 0 || finalTime < currentTimeRecord {
            bestTimeRecord = finalTime
            brokeRecord = true
        }
        
        if brokeRecord {
            isNewRecord = true
            SoundManager.shared.playSound(soundName: "newrecord")
        } else {
            SoundManager.shared.playSound(soundName: "win")
        }
        
        if wonTutorialLevel {
            // Defer TipKit datastore updates until after the winning tile animation lands
            // and stagger inline TipView dismissal before presenting the Replay popover tip.
            Task.detached(priority: .userInitiated) {
                try? await Task.sleep(for: .milliseconds(350))
                PuzzleTutorialTip().invalidate(reason: .actionPerformed)
                try? await Task.sleep(for: .milliseconds(150))
                await PuzzleTutorialTip.tutorialCompleted.donate()
            }
        }
    }
    
    func startNewGame(animated: Bool = true) {
        isGameWon = false
        stepCount = 0
        isNewRecord = false
        
        timeManager.stopAndResetTimer()
        uiTimer?.invalidate()
        elapsedTimeString = "00:00"
        
        let total = totalTiles
        let solvedBoard = Array(1...total)
        var tempBoard = solvedBoard
        var currentBlankIndex = total - 1
        let shuffleMoves = max(150, total * 12)
        
        // Simulate random legal moves to ensure the puzzle is solvable
        for _ in 0..<shuffleMoves {
            let possibleMoves = getValidMoves(for: currentBlankIndex)
            if let randomMove = possibleMoves.randomElement() {
                tempBoard.swapAt(currentBlankIndex, randomMove)
                currentBlankIndex = randomMove
            }
        }
        
        // Ensure the shuffled board doesn't accidentally end up already solved
        if tempBoard == solvedBoard {
            var previousBlankIndex = -1
            for _ in 0..<2 {
                let possibleMoves = getValidMoves(for: currentBlankIndex).filter { $0 != previousBlankIndex }
                if let nextMove = possibleMoves.randomElement() {
                    tempBoard.swapAt(currentBlankIndex, nextMove)
                    previousBlankIndex = currentBlankIndex
                    currentBlankIndex = nextMove
                }
            }
        }
        
        if animated {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.board = tempBoard
            }
        } else {
            self.board = tempBoard
        }
    }
    
    private func getValidMoves(for blankIndex: Int) -> [Int] {
        var moves: [Int] = []
        let dim = dimension
        let row = blankIndex / dim
        let col = blankIndex % dim
        
        if row > 0 { moves.append(blankIndex - dim) } // up
        if row < dim - 1 { moves.append(blankIndex + dim) } // down
        if col > 0 { moves.append(blankIndex - 1) } // left
        if col < dim - 1 { moves.append(blankIndex + 1) } // right
        
        return moves
    }
    
    private func startUITimer() {
        uiTimer?.invalidate()
        uiTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }
    
    private func updateElapsedTime() {
        let elapsed = timeManager.totalElapsedTime
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        elapsedTimeString = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
