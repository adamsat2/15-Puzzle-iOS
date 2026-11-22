//
//  ColorPalette.swift
//  15-Puzzle
//

import SwiftUI

enum PaletteLockState: Equatable {
    case unlocked
    case progressionLocked(requirement: String)
    case purchasable
    
    var isUnlocked: Bool {
        if case .unlocked = self { return true }
        return false
    }
    
    var lockHintMessage: String? {
        switch self {
        case .unlocked:
            return nil
        case .progressionLocked(let requirement):
            return requirement
        case .purchasable:
            return "Unlock this color palette in the store"
        }
    }
}

struct ColorPalette: Identifiable, Equatable {
    let id: String
    let name: String
    let primary: Color
    let winText: Color
    let recordText: Color
    let lockState: PaletteLockState
    
    var isUnlocked: Bool {
        lockState.isUnlocked
    }
    
    static let themeYellow = Color("ThemeYellow")
    
    static let mint = ColorPalette(
        id: "mint",
        name: "Mint",
        primary: .mint,
        winText: .orange,
        recordText: .pink,
        lockState: .unlocked
    )
    
    static let allPalettes: [ColorPalette] = [
        .mint,
        ColorPalette(
            id: "red",
            name: "Red",
            primary: .red,
            winText: .orange,
            recordText: .mint,
            lockState: .unlocked
        ),
        ColorPalette(
            id: "blue",
            name: "Blue",
            primary: .blue,
            winText: .cyan,
            recordText: .mint,
            lockState: .unlocked
        ),
        ColorPalette(
            id: "green",
            name: "Green",
            primary: .green,
            winText: .mint,
            recordText: .orange,
            lockState: .unlocked
        ),
        ColorPalette(
            id: "purple",
            name: "Purple",
            primary: .purple,
            winText: .pink,
            recordText: .cyan,
            lockState: .unlocked
        ),
        ColorPalette(
            id: "orange",
            name: "Orange",
            primary: .orange,
            winText: .red,
            recordText: .mint,
            lockState: .unlocked
        ),
        ColorPalette(
            id: "yellow",
            name: "Yellow",
            primary: themeYellow,
            winText: .orange,
            recordText: .red,
            lockState: .unlocked
        ),
        ColorPalette(
            id: "indigo",
            name: "Indigo",
            primary: .indigo,
            winText: .cyan,
            recordText: .pink,
            lockState: .unlocked
        ),
        ColorPalette(
            id: "cyan",
            name: "Cyan",
            primary: .cyan,
            winText: .blue,
            recordText: .purple,
            lockState: .unlocked
        )
    ]
    
    /// Resolves a persisted palette ID, falling back to Mint.
    static func palette(forID id: String?) -> ColorPalette {
        guard let id, let match = allPalettes.first(where: { $0.id == id && $0.isUnlocked }) else {
            return .mint
        }
        return match
    }
}
