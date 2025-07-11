//
//  userdefaults.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import Foundation
import SwiftUICore

extension UserDefaults {
    private static let fontDesignKey = "savedFontDesign"

    static func saveFontDesign(_ design: Font.Design) {
        
        let designString: String
        
        switch design {
            case .default: designString = "default"
            case .serif: designString = "serif"
            case .monospaced: designString = "monospaced"
            case .rounded: designString = "rounded"
            default: designString = "default"
        }
        
        UserDefaults.standard.set(designString, forKey: Self.fontDesignKey)
        
    }

    static func loadFontDesign() -> Font.Design {
        
        let designString = UserDefaults.standard.string(forKey: Self.fontDesignKey) ?? "default"
        
        switch designString {
            case "serif": return .serif
            case "monospaced": return .monospaced
            case "rounded": return .rounded
            default: return .default
        }
        
    }
}
