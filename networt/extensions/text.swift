//
//  text.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import Foundation

extension Double {
    func money(_ currency: String) -> String {
        formatted(.currency(code: currency.uppercased()))
    }

    /// Parses user input in the current locale ("1,234.5" or "1.234,5"), falling back to a plain decimal point.
    static func parse(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return (try? Double(trimmed, format: .number)) ?? Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }
}
